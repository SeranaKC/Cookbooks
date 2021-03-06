include_recipe "phalcon"
include_recipe "nginx"
include_recipe "jb_deploy::core"

# Creates the nginx virtual host
virtualhost         = '/etc/nginx/sites-available/' + node['jbx']['api']['hostname']
virtualhost_link    = '/etc/nginx/sites-enabled/' + node['jbx']['api']['hostname']

template virtualhost do
  source    "nginx/api.erb"
  variables ({
    "hostname"  => node['jbx']['api']['hostname'],
    "path"      => "#{node['jbx']['core']['path']}/public"
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