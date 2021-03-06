# Copyright 2016, Walmart Stores, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: fqdn
# Recipe:: remove_old_aliases
#
          
# ex) customer_domain: env.asm.org.oneops.com
customer_domain = node.customer_domain
if node.customer_domain !~ /^\./
  customer_domain = '.'+node.customer_domain
end

# skip in active (A/B update)
box = node[:workorder][:box][:ciAttributes]
if box.has_key?(:is_active) && box[:is_active] == "false"
  Chef::Log.info("skipping due to platform is_active false")
  exit 0
end

# entries Array of {name:String, values:Array}
entries = Array.new
aliases = Array.new
zone = node.designate_zone
ns = node.ns

if node.workorder.rfcCi.ciBaseAttributes.has_key?("aliases")
  aliases = JSON.parse(node.workorder.rfcCi.ciBaseAttributes.aliases)
end

if node.workorder.rfcCi.ciAttributes.has_key?("aliases")
  current_aliases = JSON.parse(node.workorder.rfcCi.ciAttributes.aliases)
end

current_aliases.each do |active_alias|
  aliases.delete(active_alias)
end  


aliases.each do |a|
  dns_name = a + customer_domain
  values = `dig +short #{dns_name} @#{ns}`.split("\n").first
  Chef::Log.info("alias dns_name: "+dns_name)
  if !values.nil? 
    entries.push({:name => dns_name, :values => [ values] })
  else
    Chef::Log.info("already removed: "+dns_name)    
  end
end  


def get_record_type (dns_values)
  record_type = "CNAME"
  ips = dns_values.grep(/\d+\.\d+\.\d+\.\d+/)
  if ips.size > 0
    record_type = "A"
  end     
  return record_type
end


#
# remove old aliases
#
entries.each do |entry|
  dns_match = false
  dns_type = get_record_type(entry[:values]) 
  dns_name = entry[:name]+'.'
  dns_values = entry[:values]
  
  existing_dns = `dig +short #{dns_name} @#{ns}`.split("\n")
  
  existing_ips = existing_dns.grep(/\d+\.\d+\.\d+\.\d+/)
  if dns_type == "CNAME" && existing_ips.size > 0 && existing_dns.size >1
    existing_ips.each do |ip|
       existing_dns.delete(ip)        
    end
  end
  
  existing_comparison = existing_dns.sort <=> dns_values.sort
  Chef::Log.info("remove existing:"+existing_dns.sort.to_s)
    
  if existing_dns.length > 0
    delete_type = get_record_type(existing_dns)
    Chef::Log.info("delete #{delete_type}: #{dns_name} to #{existing_dns.to_s}") 
=begin
    #record = zone.records.get(dns_name, delete_type)            
    if record == nil
      # downcase is needed because it will create a dns entry w/ CamelCase, but doesn't match on the get
      record = zone.records.get(dns_name.downcase, delete_type) 
      if record == nil
        Chef::Log.error("could not get record")
        exit 1
      end
    end
    record.destroy
=end

  end  
    
end
