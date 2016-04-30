# Condensr

Condensr helps grab a file from the internet and saves it on cloud storages like gcloud and aws s3.

## Installation

Add this line to your application's Gemfile:

```
gem 'condensr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install condensr

## Usage

For a Rails application, you should have a condensr.rb in the config/initializers folder and initialze the Condensr class with your storage credentials as follows;
```
CONDENSR = Condensr.new({
                          aws: {
                                access_key_id: foo,
                                secret_access_key: bar,
                                region: foo-foo,
                                bucket: foo-foo-bar
                                }
                          })
```

So that if you have a file, for example an picture.jpg, you can save this file on your s3 bucket simply by;

```
CONDENSR.condense({upload_type: 'aws' || 'gcloud',
                   file_url: 'picture.jpg',
                   destination_name: destination_name,
                   acl: optional})
```

The response is the new url of the file from your cloud storage.

There is support for gcloud and aws s3. Their respective config should be specified as belows;

| storage | config |
|:--------|:-------|
| aws s3  |    aws: { access_key_id: foo, secret_access_key: bar, region: foo-foo, bucket: foo-foo-bar } |
| gcloud  |    gcloud: { project_id:project_Id,  key_file: path to key.json relative from the present working dir or the key.json, bucket: bucket_name } |

## Development

After pulling hte repo, run `bundle install`. Run the tests with `rspec .`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Keplrs/condensr


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

