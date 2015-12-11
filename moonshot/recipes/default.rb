include_recipe "rubix";
include_recipe "nginx";
include_recipe "nodejs";

# This will probably be Git
# Install Rubix
execute "install rubix" do
    command "cd #{node['rubix']['tmp_dir']} &&
            cp -r #{node['rubix']['source_dir']}/ #{node['moonshot']['path']}"
end

# Delete node_modules directory?

# Build Rubix
execute "build rubix" do
    command "cd #{node['moonshot']['path']} &&
            npm -g install npm@latest &&
            npm install &&
            npm install gulp-file &&
            npm -g install gulp"
    user 'root'
end

# Build Reactjs components

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['moonshot']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['moonshot']['hostname']

template virtualhost do
  source    "nginx/moonshot.erb"
  variables ({
    "hostname"  => node['moonshot']['hostname'],
    "path"      => "#{node['moonshot']['path']}/public"
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