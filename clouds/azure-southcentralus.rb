name "azure-southcentralus"
description "Microsoft Azure"
auth "023A7F18-72BA-4369-BED9-9E341DF5B7C9"

image_map = '{
      "centos-6.6":"OpenLogic:CentOS:6.6:latest",
      "centos-7.0":"OpenLogic:CentOS:7.0:latest",
      "ubuntu-14.04":"canonical:ubuntuserver:14.04.3-LTS:14.04.201508050"
    }'

repo_map = '{
      "centos-6.6":"sudo yum -d0 -e0 -y install rsync yum-utils; sudo yum -d0 -e0 -y install epel-release",
      "centos-7.0":"sudo yum -d0 -e0 -y install rsync yum-utils; sudo yum -d0 -e0 -y install epel-release"
}'

env_vars = '{ "rubygems":"https://rubygems.org/"}'

service "azure-southcentralus",
  :cookbook => 'azure',
  :provides => { :service => 'compute' },
  :source => [Chef::Config[:register], Chef::Config[:version].split(".").first].join('.'),
  :attributes => {
    :location => 'southcentralus',
    :ostype => 'centos-6.6',
    :imagemap => image_map,
    :repo_map => repo_map,
    :env_vars => env_vars
  }
