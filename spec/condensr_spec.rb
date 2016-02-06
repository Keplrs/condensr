require "aws-sdk"
require "gcloud"
require "condensr"
require "dotenv"
Dotenv.load

describe Condensr do
  let (:client_options) { {
      aws: {
          access_key_id: ENV["ACCESS_KEY_ID"],
          secret_access_key: ENV["SECRET_ACCESS_KEY"],
          region: ENV["AWS_REGION"],
          bucket: ENV["AWS_BUCKET"]
      },
      gcloud: {
          project_id: ENV["PROJECT_ID"],
          key_file: ENV["KEY_FILE"],
          bucket: ENV["GCLOUD_BUCKET"]
      }
  } }
  let (:s3_options) { {acl: ENV["ACL_TYPE"], file_url: ENV["TEST_FILE_URL"], destination_name: ENV["DESTINATION_NAME"], upload_type: "s3"} }
  let (:gcloud_options) { {file_url: ENV["TEST_FILE_URL"], destination_name: ENV["DESTINATION_NAME"], upload_type: "gcloud"} }

  context "when client options are given" do

    context "when required options are supplied" do
      context "when upload type is s3" do
        before do
          Condensr.new(client_options).condense(s3_options)
          Aws.config.update({access_key_id: client_options[:aws][:access_key_id], secret_access_key: client_options[:aws][:secret_access_key]})
        end

        it "saves to s3 bucket" do
          s3 = Aws::S3::Resource.new(region: client_options[:aws][:region])

          expect(s3.bucket(client_options[:aws][:bucket]).object(s3_options[:destination_name]).exists?).to be true
        end
      end

      context "when upload type is gcloud" do
        before do
          Condensr.new(client_options).condense(gcloud_options)
        end

        it "saves to gcloud bucket" do
          key_file = Condensr.expand_file_path(client_options[:gcloud][:key_file])
          gcloud = Gcloud.new(client_options[:gcloud][:project_id], key_file)
          bucket = gcloud.storage.bucket(client_options[:gcloud][:bucket])
          file = bucket.file(gcloud_options[:destination_name])

          expect(file).to_not be_nil
        end
      end
    end

    context "when required options are not supplied" do
      it "returns an argument error" do
        expect { Condensr.new(client_options).condense({}) }.to raise_error(ArgumentError, "Required options not supplied")
      end
    end
  end

  context "when client options are not supplied" do
    it "returns an argument error" do
      expect { Condensr.new({}) }.to raise_error(ArgumentError, "client options are missing")
    end
  end
end
