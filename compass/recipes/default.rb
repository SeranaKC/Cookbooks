include_recipe "web-server";
include_recipe "nginx";
include_recipe "nodejs";

# Check /var/www symlink

include_recipe "compass::deploy";

# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

apt_package 'build-essential' do
    action :install
end

# Install NPM things
execute "install npm things" do
    command "cd #{node['compass']['path']} &&
            npm -g install npm@latest &&
            npm install &&
            npm install gulp-file &&
            npm -g install gulp"
    user 'root'
end

execute "chown-data-www" do
  command "chown -R #{node['compass']['user']}:#{node['compass']['user']} #{node['compass']['path']}"
  user "root"
  action :run
end

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['compass']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['compass']['hostname']

template virtualhost do
  source    "nginx/compass.erb"
  variables ({
    "hostname"  => node['compass']['hostname'],
    "path"      => "#{node['compass']['path']}/public"
  })
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end

link virtualhost_link do
  to virtualhost
  notifies :reload, "service[nginx]"
end