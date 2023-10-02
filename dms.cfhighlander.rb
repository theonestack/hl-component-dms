CfhighlanderTemplate do
  Name 'dms'
  Description "dms - #{component_version}"

  DependsOn 'lib-iam@0.2.0'
  DependsOn 'lib-ec2'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true

    ComponentParam 'VpcId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'SubnetIds', type: 'CommaDelimitedList'
    ComponentParam 'MultiAz', 'false', allowedValues: ['true', 'false']
    ComponentParam 'ReplicationInstanceClass', 'dms.t3.small'
  end

end
