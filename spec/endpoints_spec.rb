require 'yaml'

describe 'compiled component dms' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/endpoints.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/endpoints/dms.compiled.yaml") }
  
  context "Resource" do

    
    context "Role" do
      let(:resource) { template["Resources"]["Role"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"dms.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property ManagedPolicyArns" do
          expect(resource["Properties"]["ManagedPolicyArns"]).to eq(["arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "SecurityGroup" do
      let(:resource) { template["Resources"]["SecurityGroup"] }

      it "is of type AWS::EC2::SecurityGroup" do
          expect(resource["Type"]).to eq("AWS::EC2::SecurityGroup")
      end
      
      it "to have property GroupDescription" do
          expect(resource["Properties"]["GroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName} DMS tasks"})
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VpcId"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "ReplicationSubnetGroup" do
      let(:resource) { template["Resources"]["ReplicationSubnetGroup"] }

      it "is of type AWS::DMS::ReplicationSubnetGroup" do
          expect(resource["Type"]).to eq("AWS::DMS::ReplicationSubnetGroup")
      end
      
      it "to have property ReplicationSubnetGroupDescription" do
          expect(resource["Properties"]["ReplicationSubnetGroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName} subnets available for DMS"})
      end
      
      it "to have property SubnetIds" do
          expect(resource["Properties"]["SubnetIds"]).to eq({"Ref"=>"SubnetIds"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "ReplicationInstance" do
      let(:resource) { template["Resources"]["ReplicationInstance"] }

      it "is of type AWS::DMS::ReplicationInstance" do
          expect(resource["Type"]).to eq("AWS::DMS::ReplicationInstance")
      end
      
      it "to have property MultiAZ" do
          expect(resource["Properties"]["MultiAZ"]).to eq({"Ref"=>"MultiAz"})
      end
      
      it "to have property PubliclyAccessible" do
          expect(resource["Properties"]["PubliclyAccessible"]).to eq(false)
      end
      
      it "to have property ReplicationInstanceClass" do
          expect(resource["Properties"]["ReplicationInstanceClass"]).to eq({"Ref"=>"ReplicationInstanceClass"})
      end
      
      it "to have property ReplicationSubnetGroupIdentifier" do
          expect(resource["Properties"]["ReplicationSubnetGroupIdentifier"]).to eq({"Ref"=>"ReplicationSubnetGroup"})
      end
      
      it "to have property VpcSecurityGroupIds" do
          expect(resource["Properties"]["VpcSecurityGroupIds"]).to eq([{"Ref"=>"SecurityGroup"}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "s3bucketEndpointRole" do
      let(:resource) { template["Resources"]["s3bucketEndpointRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>{"Fn::Sub"=>"dms.${AWS::Region}.amazonaws.com"}}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"s3-write", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"s3write", "Action"=>["s3:PutObject", "s3:DeleteObject", "s3:GetObject"], "Resource"=>["*"], "Effect"=>"Allow"}]}}, {"PolicyName"=>"s3-list-bucket", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"s3listbucket", "Action"=>["s3:ListBucket"], "Resource"=>["*"], "Effect"=>"Allow"}]}}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "s3bucket" do
      let(:resource) { template["Resources"]["s3bucket"] }

      it "is of type AWS::DMS::Endpoint" do
          expect(resource["Type"]).to eq("AWS::DMS::Endpoint")
      end
      
      it "to have property EndpointType" do
          expect(resource["Properties"]["EndpointType"]).to eq("destination")
      end
      
      it "to have property EngineName" do
          expect(resource["Properties"]["EngineName"]).to eq("s3")
      end
      
      it "to have property S3Settings" do
          expect(resource["Properties"]["S3Settings"]).to eq({"BucketName"=>"my-s3-bucket", "ServiceAccessRoleArn"=>{"Fn::GetAtt"=>["s3bucketEndpointRole", "Arn"]}})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "redshiftEndpointRole" do
      let(:resource) { template["Resources"]["redshiftEndpointRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>{"Fn::Sub"=>"dms.${AWS::Region}.amazonaws.com"}}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"get-database-secret", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"getdatabasesecret", "Action"=>["secretsmanager:GetSecretValue"], "Resource"=>[{"Ref"=>"RedshiftecretManagerArn"}], "Effect"=>"Allow"}]}}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "redshift" do
      let(:resource) { template["Resources"]["redshift"] }

      it "is of type AWS::DMS::Endpoint" do
          expect(resource["Type"]).to eq("AWS::DMS::Endpoint")
      end
      
      it "to have property EndpointType" do
          expect(resource["Properties"]["EndpointType"]).to eq("target")
      end
      
      it "to have property EngineName" do
          expect(resource["Properties"]["EngineName"]).to eq("redshift")
      end
      
      it "to have property RedshiftSettings" do
          expect(resource["Properties"]["RedshiftSettings"]).to eq({"SecretsManagerAccessRoleArn"=>{"Fn::GetAtt"=>["redshiftEndpointRole", "Arn"]}, "SecretsManagerSecretId"=>{"Ref"=>"RedshiftecretManagerArn"}})
      end
      
      it "to have property DatabaseName" do
          expect(resource["Properties"]["DatabaseName"]).to eq({"Ref"=>"RedshiftHost"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "oracleEndpointRole" do
      let(:resource) { template["Resources"]["oracleEndpointRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>{"Fn::Sub"=>"dms.${AWS::Region}.amazonaws.com"}}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"get-database-secret", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"getdatabasesecret", "Action"=>["secretsmanager:GetSecretValue"], "Resource"=>[{"Ref"=>"OracleSecretManagerArn"}], "Effect"=>"Allow"}]}}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "oracle" do
      let(:resource) { template["Resources"]["oracle"] }

      it "is of type AWS::DMS::Endpoint" do
          expect(resource["Type"]).to eq("AWS::DMS::Endpoint")
      end
      
      it "to have property EndpointType" do
          expect(resource["Properties"]["EndpointType"]).to eq("source")
      end
      
      it "to have property EngineName" do
          expect(resource["Properties"]["EngineName"]).to eq("oracle")
      end
      
      it "to have property OracleSettings" do
          expect(resource["Properties"]["OracleSettings"]).to eq({"SecretsManagerAccessRoleArn"=>{"Fn::GetAtt"=>["oracleEndpointRole", "Arn"]}, "SecretsManagerSecretId"=>{"Ref"=>"OracleSecretManagerArn"}})
      end
      
      it "to have property DatabaseName" do
          expect(resource["Properties"]["DatabaseName"]).to eq({"Ref"=>"OracleHost"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "azuredbEndpointRole" do
      let(:resource) { template["Resources"]["azuredbEndpointRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>{"Fn::Sub"=>"dms.${AWS::Region}.amazonaws.com"}}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"get-database-secret", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"getdatabasesecret", "Action"=>["secretsmanager:GetSecretValue"], "Resource"=>[{"Ref"=>"AzureDBSecretManagerArn"}], "Effect"=>"Allow"}]}}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "azuredb" do
      let(:resource) { template["Resources"]["azuredb"] }

      it "is of type AWS::DMS::Endpoint" do
          expect(resource["Type"]).to eq("AWS::DMS::Endpoint")
      end
      
      it "to have property EndpointType" do
          expect(resource["Properties"]["EndpointType"]).to eq("source")
      end
      
      it "to have property EngineName" do
          expect(resource["Properties"]["EngineName"]).to eq("azuredb")
      end
      
      it "to have property MicrosoftSqlServerSettings" do
          expect(resource["Properties"]["MicrosoftSqlServerSettings"]).to eq({"SecretsManagerAccessRoleArn"=>{"Fn::GetAtt"=>["azuredbEndpointRole", "Arn"]}, "SecretsManagerSecretId"=>{"Ref"=>"AzureDBSecretManagerArn"}})
      end
      
      it "to have property DatabaseName" do
          expect(resource["Properties"]["DatabaseName"]).to eq({"Ref"=>"AzureDBHost"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "OracleTaskTask" do
      let(:resource) { template["Resources"]["OracleTaskTask"] }

      it "is of type AWS::DMS::ReplicationTask" do
          expect(resource["Type"]).to eq("AWS::DMS::ReplicationTask")
      end
      
      it "to have property MigrationType" do
          expect(resource["Properties"]["MigrationType"]).to eq("full-load-and-cdc")
      end
      
      it "to have property ReplicationInstanceArn" do
          expect(resource["Properties"]["ReplicationInstanceArn"]).to eq({"Ref"=>"ReplicationInstance"})
      end
      
      it "to have property SourceEndpointArn" do
          expect(resource["Properties"]["SourceEndpointArn"]).to eq({"Ref"=>"oracle"})
      end
      
      it "to have property TargetEndpointArn" do
          expect(resource["Properties"]["TargetEndpointArn"]).to eq({"Ref"=>"s3bucket"})
      end
      
      it "to have property ReplicationTaskSettings" do
          expect(resource["Properties"]["ReplicationTaskSettings"]).to eq({"Fn::Sub"=>"{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TASK_MANAGER\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]},\"ErrorBehavior\":{\"TableErrorEscalationPolicy\":\"STOP_TASK\",\"RecoverableErrorThrottlingMax\":1800,\"ApplyErrorDeletePolicy\":\"IGNORE_RECORD\",\"ApplyErrorEscalationPolicy\":\"LOG_ERROR\",\"ApplyErrorUpdatePolicy\":\"LOG_ERROR\",\"DataTruncationErrorPolicy\":\"LOG_ERROR\",\"RecoverableErrorInterval\":5,\"RecoverableErrorCount\":-1,\"FullLoadIgnoreConflicts\":true,\"DataErrorEscalationPolicy\":\"SUSPEND_TABLE\",\"ApplyErrorInsertPolicy\":\"LOG_ERROR\",\"ApplyErrorEscalationCount\":0,\"RecoverableErrorThrottling\":true,\"TableErrorEscalationCount\":0,\"TableErrorPolicy\":\"SUSPEND_TABLE\",\"DataErrorEscalationCount\":0,\"DataErrorPolicy\":\"LOG_ERROR\"}}"})
      end
      
      it "to have property TableMappings" do
          expect(resource["Properties"]["TableMappings"]).to eq('{"rules":[{"rule-type":"selection","rule-id":1,"rule-name":1,"object-locator":{"schema-name":"dms_test_sample","table-name":"some"},"rule-action":"include"},{"rule-type":"selection","rule-id":2,"rule-name":2,"object-locator":{"schema-name":"dms_test_sample","table-name":"some"},"lob-settings":{"mode":"limited","bulk-max-size":16}}]}')
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
    context "AzureToRedshiftTask" do
      let(:resource) { template["Resources"]["AzureToRedshiftTask"] }

      it "is of type AWS::DMS::ReplicationTask" do
          expect(resource["Type"]).to eq("AWS::DMS::ReplicationTask")
      end
      
      it "to have property MigrationType" do
          expect(resource["Properties"]["MigrationType"]).to eq("full-load-and-cdc")
      end
      
      it "to have property ReplicationInstanceArn" do
          expect(resource["Properties"]["ReplicationInstanceArn"]).to eq({"Ref"=>"ReplicationInstance"})
      end
      
      it "to have property SourceEndpointArn" do
          expect(resource["Properties"]["SourceEndpointArn"]).to eq({"Ref"=>"azuredb"})
      end
      
      it "to have property TargetEndpointArn" do
          expect(resource["Properties"]["TargetEndpointArn"]).to eq({"Ref"=>"redshift"})
      end
      
      it "to have property ReplicationTaskSettings" do
          expect(resource["Properties"]["ReplicationTaskSettings"]).to eq({"Fn::Sub"=>"{\"Logging\":{\"EnableLogging\":true,\"LogComponents\":[{\"Id\":\"SOURCE_UNLOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"SOURCE_CAPTURE\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_LOAD\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TARGET_APPLY\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"},{\"Id\":\"TASK_MANAGER\",\"Severity\":\"LOGGER_SEVERITY_DEFAULT\"}]},\"ErrorBehavior\":{\"TableErrorEscalationPolicy\":\"STOP_TASK\",\"RecoverableErrorThrottlingMax\":1800,\"ApplyErrorDeletePolicy\":\"IGNORE_RECORD\",\"ApplyErrorEscalationPolicy\":\"LOG_ERROR\",\"ApplyErrorUpdatePolicy\":\"LOG_ERROR\",\"DataTruncationErrorPolicy\":\"LOG_ERROR\",\"RecoverableErrorInterval\":5,\"RecoverableErrorCount\":-1,\"FullLoadIgnoreConflicts\":true,\"DataErrorEscalationPolicy\":\"SUSPEND_TABLE\",\"ApplyErrorInsertPolicy\":\"LOG_ERROR\",\"ApplyErrorEscalationCount\":0,\"RecoverableErrorThrottling\":true,\"TableErrorEscalationCount\":0,\"TableErrorPolicy\":\"SUSPEND_TABLE\",\"DataErrorEscalationCount\":0,\"DataErrorPolicy\":\"LOG_ERROR\"}}"})
      end
      
      it "to have property TableMappings" do
          expect(resource["Properties"]["TableMappings"]).to eq('{"rules":[{"rule-type":"selection","rule-id":1,"rule-name":1,"object-locator":{"schema-name":"test321","table-name":"test123"},"rule-action":"include","lob-settings":{"mode":"limited","bulk-max-size":12}}]}')
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>{"Fn::Sub"=>"Project"}, "Value"=>{"Fn::Sub"=>"DMStest"}}])
      end
      
    end
    
  end

end