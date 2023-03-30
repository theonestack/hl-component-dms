require 'yaml'

describe 'compiled component dms' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/dms.compiled.yaml") }
  
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
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
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
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
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
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
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
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
  end

end