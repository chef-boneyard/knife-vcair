Knife vcair
===============

This is the official Chef Knife plugin VMware's vCloud Hybrid Service (vcair). This plugin gives knife the ability to create, bootstrap and manage instances on vcair-based public and private clouds.

Please refer to the [CHANGELOG](CHANGELOG.md) for version history and known issues.

# Installation #

## Current Source Build Instructions: ##

Then build and install this gem, run:

    $ gem build knife-vcair.gemspec
    $ gem install knife-vcair-0.6.X.gem

or if you are using the Chef Development Kit (Chef DK), to install it run:

    $ chef gem install knife-vcair-0.X.0.gem

## Future Rubygems Instructions: ##

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-vcair

If you are using the Chef Development Kit (Chef DK), to install it run:

    $ chef gem install knife-vcair

# Configuration #

In order to communicate with an vcair API you will need to tell Knife
your vcair API endpoint, username, password and organization. The
easiest way to accomplish this is to create these entries in your
`knife.rb` file:

    knife[:vcair_api_url] = 'vcair.example.com'
    knife[:vcair_username] = 'Your vcair username'
    knife[:vcair_password] = 'Your vcair password'
    knife[:vcair_org] = 'Your vcair organization'

If your knife.rb file will be checked into a SCM system (ie readable
by others) you may want to read the values from environment variables.

    knife[:vcair_api_url] = "#{ENV['VCAIR_API_URL']}"
    knife[:vcair_username] = "#{ENV['VCAIR_USERNAME']}"
    knife[:vcair_password] = "#{ENV['VCAIR_PASSWORD']}"
    knife[:vcair_org] = "#{ENV['VCAIR_ORG']}"

## VMware's vcair ##

If you are using VMware's hosted vcair the API URL is found by logging
into the https://vchs.vmware.com, and clicking on your Dashboard's
Virtual Data Center. On the right under "Related Links" click on the
"vCloud Director API URL" and copy that value. It should look
something like
`https://p3v11-vcd.vchs.vmware.com:443/cloud/org/M511664989-4904/`
From this we will take our base API URL `p3v11-vcd.vchs.vmware.com`
and get our organization `M511664989-4904` that is appended to our
https://vchs.vmware.com login, giving us the values:

    knife[:vcair_api_url] = 'p3v11-vcd.vchs.vmware.com'
    knife[:vcair_username] = 'user@somedomain.com
    knife[:vcair_password] = 'VCAIRSECRET'
    knife[:vcair_org] = 'M511664989-4904'

# knife vcair subcommands #

This plugin provides the following Knife subcommands. Specific command
options can be found by invoking the subcommand with a `--help`
option.

## knife vcair server create OR knife vcair vm create ##

Instanciate a new VApp+VM from a Template from one of the available Catalogs.

Windows example:
```
knife vcair server create \
  --winrm-password Password1 \
  --image W2K12-STD-64BIT \
  --bootstrap-protocol winrm \
  --customization-script ./install-winrm-vcair.bat \
  --vcpus 4 \
  --memory 4096
```

The windows example requires a custom install script to setup winrm,
and set/change the initial password without using the web console.  A
working example
[./install-winrm-vcair-example.bat](https://github.com/vulk/knife-vcair/blob/server-create/install-winrm-vcair-example.bat)
is included in this repo.


Linux example:
```
knife vcair server create --ssh-password 'randompass' --image CentOS64-64bit
```

The Linux images require you pass the ssh-password. Ssh public keys
are not supported yet.

Assumptions:
 * each VApp will only contain one VM.
 * a routed network with a default SNAT rule allowing internet and DNS
 * a firewall rule allowing that network to reach internet

**TODO**
 * Allow specifying (possibly multiple) networks in server create
   - Rather than just searching for one that ends in 'routed'
 * Allow specifying nat setup / external IPs
 * Allow specifying catalog item by name OR id, public or private
 * Automatically image_os_type / bootstrap_protocol default basode on template default to linux/ssh
 * See if windows images can be updated to set password correctly when set via the vchs API
 * See if Linux images / API can be updated to use ssh keys
 * Add support for `admin_auto_logon_*` to fog, and get windows/linux images updated to respect
 * Support IP allocation modes other than DHCP, including manual

## knife vcair server delete OR knife vcair vm delete ##

Delete a vcair vAPP. `knife vcair vm delete` is the same command if
the term 'vm' is preferred over 'server'. **PLEASE NOTE** - this does
not delete the associated node and client objects from the Chef server
without using the `-P` option to purge the client.

## knife vcair server list OR knife vcair vm list ##

List the currently deployed vcair servers by their vAPP. `knife vcair vm list` is the same command if the term 'vm' is preferred over 'server'.

## knife vcair image list OR knife vcair template list ##

List the available vcair templates or images that may be used for deploying VMs.

## knife vcair network list ##

Lists the networks available to the current vcair organization.

## knife vcair nat list ##

**TODO** List the Network Address Translation (NAT) rules modifying the source/destination IP Addresses or packets arriving to and leaving from the vcair organization network.

## knife vcair firewall list ##

**TODO** The list of firewall rules configured for the current vcair organization network.

## knife vcair ip list ##

**TODO** The list of public IP Addresses provided and allocated for the current vcair organization network.


# Notes #

The 20140619 Ubuntu images seems to not use customizaton (script nor setting password) and default to not allowing ssh w/ password even if known.

```ruby
template = public_catalog.catalog_items.get_by_name('Ubuntu Server 12.04 LTS (amd64 20140619)'
```


# License #

Author:: Matt Ray (<matt@getchef.com>)

Author:: Seth Thomas (<sthomas@getchef.com>)

Author:: Chris McClimans (<c@vulk.co>)

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
