name             "S3"
description      "AWS S3"
version          "0.1"
maintainer       "OneOps"
maintainer_email "support@oneops.com"
license          "Apache License, Version 2.0"

grouping 'default',
  :access => "global",
  :packages => [ 'base', 'mgmt.cloud.service', 'cloud.service' ],
  :namespace => true

  
attribute 'key',
  :description => "Access Key",
  :required => "required",
  :default => "",
  :format => { 
    :help => 'Access key from the AWS security credentials page',
    :category => '1.Credentials',
    :order => 1
  }
  
attribute 'secret',
  :description => "Secret Key",
  :encrypted => true,
  :required => "required",
  :default => "",
  :format => {
    :help => 'Secret key from the AWS security credentials page', 
    :category => '1.Credentials',
    :order => 2
  }
  
  attribute 'server',
  :description => "S3 Object Storage Location",
  :required => "required",
  :default => "s3.amazonaws.com",
  :format => {
    :help => 'FQDN for S3 Object Storage, only change if leveraging a custom virtual hosted bucket or on-prem S3 compatible oject store.', 
    :category => '1.Credentials',
    :order => 3
  }
  
  
