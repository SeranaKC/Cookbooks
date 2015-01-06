include_recipe "aws"
include_recipe "tags"
include_recipe "consul"
include_recipe "dnsmasq"

cron_path = node["consul"]["config_dir"]

# Turn off the existing consul service
service "consul" do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :stop
end

# Remove consul files
directory node['consul']['data_dir'] do
  recursive true
  action :delete
end

# Recreate the directory if necessary
directory node['consul']['data_dir'] do
  recursive true
  owner 'root'
  group 'root'
  action :create
end

# Reset AWS Tags
# If tag elements are present, and this is on EC2
if ( node.attribute?('ec2') && node[:ec2].attribute?('instance_id') && /(i|snap|vol)-[a-zA-Z0-9]+/.match(node[:ec2][:instance_id]) &&
        node.attribute?('aws') && node['aws'].attribute?('tags') )
    
    aws_resource_tag node['ec2']['instance_id'] do
        aws_access_key node['aws']['aws_access_key_id']
        aws_secret_access_key node['aws']['aws_secret_access_key']
        tags({
            "consul" => "bootstrap"
        })
        action :update
    end
end

# Turn consul back on
service "consul" do
  action :start
end

# Copy the mocked_stack script for non-production environments
ip = node[:network][:interfaces][node[:consul][:bind_interface]][:addresses].detect{|k,v| v[:family] == "inet" }.first
template "#{cron_path}/mocked_stack.json" do
    source "mocked_stack.json.erb"
    owner "root"
    group "root"
    variables({
        :ip          => ip,
        :environment => node['environment']
    })
end

#Copy the cron script to the consul configuration folder
template "#{cron_path}/consul_cron.php" do
    source "consul_cron.php.erb"
    owner "root"
    group "root"
end

#Run consul cron job
cron "Consul cron" do
  command "/usr/bin/php #{cron_path}/consul_cron.php"
  user "root"
  action :create
end
