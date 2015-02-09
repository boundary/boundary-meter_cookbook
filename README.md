### The boundary-meter Cookbook

This cookbook is used to install and configure (via the Boundary API) the Boundary meter. To get things running, set your Boundary account's org id and API key in the attributes/default.rb and add boundary-meter::default to your host's run_list.

#### Dependencies

Dependencies and their requisite versions, when necessary, are specified in metadata.rb.

#### Configuration Options

##### API Keys

Setup your API keys in attributes/api.rb for Boundary Enterprise

```ruby
default['boundary_meter']['token'] = 'org_id:api_key'
```

or Boundary Premium

```ruby
default['boundary_meter']['token'] = 'api_token'
```

##### Boundary Meter Tags

By default, the cookbook sends the chef_environment as a meter tag to the Boundary service.

If your host is in EC2 or you are using Opsworks, it adds a few tags specific to those environments.

You can set more tags by manipulating the node['boundary_meter']['tags'] attribute.

##### Interfaces

The meter defaults to monitoring all interfaces. You can change this with the node['boundary_meter']['interfaces'] array:

```ruby
node['boundary_meter']['interfaces'] = [ 'eth0', 'eth2' ]
```

##### Hostname

The Boundary meter defaults to using `node['fqdn']` as the hostname. You can override this by setting `node['boundary_meter']['hostname']` with a higher precedence then default.

##### Sending to Multiple Orgs

If you would like to "multiplex" your meter traffic to multiple Boundary orgs, we support this using a special variable in the Boundary meter named `ALT_CONFIGS`.

These can be set via the attribute `node['boundary_meter']['alt_configs']` which is an array of hashes:

For Boundary Enterprise
```ruby
node['boundary_meter']['alt_configs'] = [{
                                            'name' => 'secondary',
                                            'token' => 'org_id:api_key'
                                          }
                                         ]
```

or Boundary Premium
```ruby
node['boundary_meter']['alt_configs'] = [{
                                            'name' => 'secondary',
                                            'token' => 'api_token'
                                          }
                                         ]
```

#### EC2

This cookbook includes automatic detection and tagging of your meter with various EC2 attributes such as security group and instance type.

#### OpsWorks

If you are using OpsWorks this cookbook should work out of the box (with the above dependencies). This cookbook also includes automatic detection and tagging of your meter with layers, stack name and applications if any exist.
