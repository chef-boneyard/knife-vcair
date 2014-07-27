Knife vCHS
===============

This is the official Chef Knife plugin VMware's vCloud Hybrid Service (vCHS). This plugin gives knife the ability to create, bootstrap and manage instances on vCHS-based public and private clouds.

Please refer to the [CHANGELOG](CHANGELOG.md) for version history and known issues.

# Installation #

## Current Source Build Instructions: ##

This plugin currently depends on the unreleased knife-cloud gem. To install it check out the source from https://github.com/opscode/knife-cloud. To install it, run:

    $ gem build knife-cloud.gemspec
    $ gem install knife-cloud-0.0.1.gem

Then build and install this gem, run:

    $ gem build knife-vchs.gemspec
    $ gem install knife-vchs-0.1.0.gem

or if you are using the Chef Development Kit (Chef DK), to install it run:

    $ chef gem install knife-vchs-0.1.0.gem

## Future Rubygems Instructions: ##

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-vchs

If you are using the Chef Development Kit (Chef DK), to install it run:

    $ chef gem install knife-vchs

# Configuration #

In order to communicate with an vCHS API you will need to tell Knife your vCHS API endpoint, username, password and organization. The easiest way to accomplish this is to create these entries in your `knife.rb` file:

    knife[:vchs_api_url] = 'vchs.example.com'
    knife[:vchs_username] = 'Your vCHS username'
    knife[:vchs_password] = 'Your vCHS password'
    knife[:vchs_org] = 'Your vCHS organization'

If your knife.rb file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables.

    knife[:vchs_api_url] = "#{ENV['VCHS_API_URL']}"
    knife[:vchs_username] = "#{ENV['VCHS_USERNAME']}"
    knife[:vchs_password] = "#{ENV['VCHS_PASSWORD']}"
    knife[:vchs_org] = "#{ENV['VCHS_ORG']}"

## VMware's vCHS ##

If you are using VMware's hosted vCHS the API URL is found by logging into the https://vchs.vmware.com, and clicking on your Dashboard's Virtual Data Center. On the right under "Related Links" click on the "vCloud Director API URL" and copy that value. It should look something like `https://p3v11-vcd.vchs.vmware.com:443/cloud/org/M511664989-4904/` From this we will take our base API URL `p3v11-vcd.vchs.vmware.com` and get our organization `M511664989-4904` that is appended to our https://vchs.vmware.com login, giving us the values:

    knife[:vchs_api_url] = 'p3v11-vcd.vchs.vmware.com'
    knife[:vchs_username] = 'user@somedomain.com
    knife[:vchs_password] = 'VCHSSECRET'
    knife[:vchs_org] = 'M511664989-4904'

# knife vchs subcommands #

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` option.

## knife vchs server create OR knife vchs vm create ##

**TODO** Provisions a new vCHS server and bootstraps it with Chef. `knife vchs vm create` is the same command if the term 'vm' is preferred over 'server'.

## knife vchs server delete OR knife vchs vm delete ##

Delete a vCHS vAPP. `knife vchs vm delete` is the same command if the term 'vm' is preferred over 'server'. **PLEASE NOTE** - this does not delete the associated node and client objects from the Chef server without using the `-P` option to purge the client.

## knife vchs server list OR knife vchs vm list ##

List the currently deployed vCHS servers by their vAPP. `knife vchs vm list` is the same command if the term 'vm' is preferred over 'server'.

## knife vchs image list OR knife vchs template list ##

List the available vCHS templates or images that may be used for deploying VMs.

## knife vchs network list ##

Lists the networks available to the current vCHS organization.

## knife vchs nat list ##

**TODO** List the Network Address Translation (NAT) rules modifying the source/destination IP Addresses or packets arriving to and leaving from the vCHS organization network.

## knife vchs firewall list ##

**TODO** The list of firewall rules configured for the current vCHS organization network.

## knife vchs ip list ##

**TODO** The list of public IP Addresses provided and allocated for the current vCHS organization network.

# License #

Author:: Matt Ray (<matt@getchef.com>)

Author:: Seth Thomas (<sthomas@getchef.com>)

Copyright:: Copyright (c) 2014 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
