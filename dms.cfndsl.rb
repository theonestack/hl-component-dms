CloudFormation do

  tags = external_parameters.fetch(:tags, {})
  dms_tags = []
  dms_tags.push({ Key: 'Environment', Value: Ref(:EnvironmentName) })
  dms_tags.push({ Key: 'EnvironmentType', Value: Ref(:EnvironmentType) })
  dms_tags.push(*tags.map {|k,v| {Key: FnSub(k), Value: FnSub(v)}})
  
  IAM_Role(:Role) {
    AssumeRolePolicyDocument service_assume_role_policy('dms')
    ManagedPolicyArns ["arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"]
    Tags dms_tags
  }

  security_group_rules = external_parameters.fetch(:security_group_rules, [])
  ip_blocks = external_parameters.fetch(:ip_blocks, [])
  EC2_SecurityGroup(:SecurityGroup) {
    GroupDescription FnSub("${EnvironmentName} DMS tasks")
    VpcId Ref(:VpcId)
    SecurityGroupIngress generate_security_group_rules(security_group_rules,ip_blocks) if (!security_group_rules.empty? && !ip_blocks.empty?)
    Tags dms_tags
  }

  DMS_ReplicationSubnetGroup(:ReplicationSubnetGroup) {
    ReplicationSubnetGroupDescription FnSub("${EnvironmentName} subnets available for DMS")
    SubnetIds Ref(:SubnetIds)
    Tags dms_tags
  }

  DMS_ReplicationInstance(:ReplicationInstance) {
    MultiAZ Ref(:MultiAz)
    PubliclyAccessible false
    ReplicationInstanceClass Ref(:ReplicationInstanceClass)
    ReplicationSubnetGroupIdentifier Ref(:ReplicationSubnetGroup)
    VpcSecurityGroupIds [Ref(:SecurityGroup)]
    Tags dms_tags
  }

  endpoints = external_parameters.fetch(:endpoints, {})
  endpoints.each do |endpoint_name, endpoint|
    safe_resource_name = endpoint_name.gsub(/[^0-9A-Za-z]/, '')
    policy = {}

    case endpoint['engine']
    when 'aurora-postgresql', 'postgres', 'redshift', 'azuredb', 'sqlserver', 'oracle'
      policy["get-database-secret"] = {
        "action" => [
          "secretsmanager:GetSecretValue"
        ],
        "resource" => [
          endpoint['secret']
        ]
      }
    when 's3'
      policy["s3-write"] = {
        "action" => [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ],
        "resource": [
          "arn:aws:s3:::#{endpoint['bucket']}/*"
        ]
      }
      policy["s3-list-bucket"] = {
        "action" => [
          "s3:ListBucket"
        ],
        "resource": [
          "arn:aws:s3:::#{endpoint['bucket']}"
        ]
      }
    end

    unless policy.empty?
      IAM_Role(:"#{safe_resource_name}EndpointRole") {
        AssumeRolePolicyDocument({
          Version: '2012-10-17',
          Statement: [
            {
              Effect: 'Allow',
              Principal: {
                Service: FnSub("dms.${AWS::Region}.amazonaws.com")
              },
              Action: 'sts:AssumeRole'
            }
          ]
        })
        Policies iam_role_policies(policy)
        Tags dms_tags
      }
    end

    settings = {}
    settings.merge!(endpoint['settings']) if endpoint.has_key?('settings') && !endpoint['settings'].nil?

    DMS_Endpoint(safe_resource_name) {
      EndpointType endpoint['type']
      EngineName endpoint['engine']

      case endpoint['engine']
      when 'aurora-postgresql', 'postgres'
        settings[:SecretsManagerAccessRoleArn] = FnGetAtt(:"#{safe_resource_name}EndpointRole", :Arn)
        settings[:SecretsManagerSecretId] = endpoint['secret']
        PostgreSqlSettings settings
      when 'redshift'
        settings[:SecretsManagerAccessRoleArn] = FnGetAtt(:"#{safe_resource_name}EndpointRole", :Arn)
        settings[:SecretsManagerSecretId] = endpoint['secret']
        RedshiftSettings settings
      when 'oracle'
        settings[:SecretsManagerAccessRoleArn] = FnGetAtt(:"#{safe_resource_name}EndpointRole", :Arn)
        settings[:SecretsManagerSecretId] = endpoint['secret']
        OracleSettings settings
      when 'azuredb', 'sqlserver'
        settings[:SecretsManagerAccessRoleArn] = FnGetAtt(:"#{safe_resource_name}EndpointRole", :Arn)
        settings[:SecretsManagerSecretId] = endpoint['secret']
        MicrosoftSqlServerSettings settings
      when 's3'
        settings[:BucketName] = endpoint['bucket']
        settings[:ServiceAccessRoleArn] = FnGetAtt(:"#{safe_resource_name}EndpointRole", :Arn)
        S3Settings settings
      else
        raise "unknown DMS endpoint engine type #{endpoint['engine']}"
      end

      if endpoint.has_key?('database_name')
        DatabaseName endpoint['database_name']
      end

      Tags dms_tags
    }
  end

  tasks = external_parameters.fetch(:tasks, {})
  tasks.each do |task_name, task|
    safe_resource_name = task_name.gsub(/[^0-9A-Za-z]/, '')
    
    settings = {
      Logging: {
        EnableLogging: true,
        LogComponents: [
          {
            Id: "SOURCE_UNLOAD",
            Severity: "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id: "SOURCE_CAPTURE",
            Severity: "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id: "TARGET_LOAD",
            Severity: "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id: "TARGET_APPLY",
            Severity: "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id: "TASK_MANAGER",
            Severity: "LOGGER_SEVERITY_DEFAULT"
          }
        ]
      }
    }
    settings.merge!(task.fetch('settings', {}))

    DMS_ReplicationTask(:"#{safe_resource_name}Task") {
      MigrationType task['type']
      ReplicationInstanceArn Ref(:ReplicationInstance)
      SourceEndpointArn Ref(task['source'].gsub(/[^0-9A-Za-z]/, ''))
      TargetEndpointArn Ref(task['target'].gsub(/[^0-9A-Za-z]/, ''))
      ReplicationTaskSettings FnSub(settings.to_json)
      TableMappings task['table_mappings'].to_json
      Tags dms_tags
    }
  end
end
