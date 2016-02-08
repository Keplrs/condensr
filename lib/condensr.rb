require "condensr/version"
require "condensr/helpers"
require "condensr/exceptions"
require "httparty"
require "aws-sdk"
require "gcloud"
require "pathname"

DEFAULT_ACL = 'private'

class Condensr
  def initialize(client_options)
    # for a rails application, we should have this config in initializers/condensr.rb as follows
    # CONDENSR = Condensr.new(  {
    # aws: {
    #     access_key_id: 'akid',
    #     secret_access_key: 'secret',
    #     region: 'us-west-1',
    #     bucket: bucket_name
    # },
    # gcloud: {
    #     project_id:project_Id,
    #     key_file: path to key.json  describe the particular key type needed,
    #     bucket: bucket_name
    # }
    # })
    # so we can call the object CONDENSR from any part of the application
    fail ArgumentError.new("client options are missing") if client_options.empty?
    @client_options = client_options
    if (@client_options[:aws])
      Aws.config.update({
                            region: @client_options[:aws][:region],
                            credentials: Aws::Credentials.new(@client_options[:aws][:access_key_id], @client_options[:aws][:secret_access_key])
                        })
    end

    if (@client_options[:gcloud])
      key_file = Condensr.expand_file_path(@client_options[:gcloud][:key_file])
      @gcloud = Gcloud.new(@client_options[:gcloud][:project_id], key_file)
    end
  end

  def condense(options)
    # options should be
    # {
    #     upload_type: 'aws' || 'gcloud',
    #     file_url: file_url,
    #     destination_name: destination_name
    #     acl: optional, 'public-read' as default in the list of aws canned acl (http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html)
    # }
    fail ArgumentError.new("Required options not supplied") if (!options[:upload_type] || !options[:file_url])

    options[:file_name] = Condensr.extract_file_name(options[:file_url])
    options[:destination_name] = options[:destination_name].empty? ? options[:file_name] : options[:destination_name]
    file_path = download(options)
    output = upload(options, file_path)
    clear_file(file_path)
    output
  end



  def download(options)
    fetch_object = HTTParty.get(options[:file_url])
    file_path = Pathname.pwd + options[:file_name]
    File.open(file_path, "wb") do |f|
      f.write(fetch_object.parsed_response)
    end if fetch_object
    file_path
  end

  protected

  def upload(options, file_path)
    if Condensr.method_defined?("#{options[:upload_type]}_upload".to_sym)
      self.send("#{options[:upload_type]}_upload", options, file_path)
    else
      Condensr::Error.new("This upload type  is not supported.")
    end
  end

  def s3_upload(options, file_path)
    s3 = Aws::S3::Resource.new(region: @client_options[:aws][:region])
    obj = s3.bucket(@client_options[:aws][:bucket]).object(options[:destination_name])
    obj.upload_file(file_path, acl: options[:acl]||DEFAULT_ACL)
    obj.public_url
  end

  def gcloud_upload(options, file_path)
    storage = @gcloud.storage
    bucket = storage.bucket(@client_options[:gcloud][:bucket])
    bucket.create_file(file_path, options[:destination_name])
  end

  def clear_file(file_path)
    File.delete(file_path)
  end
end
