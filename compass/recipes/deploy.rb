include_recipe "github-auth"

# Checkout Compass, this might go in jb_deploy
git node['compass']['path'] do
  ssh_wrapper node['github-auth']['wrapper_path'] + "/compass_wrapper.sh"
  repository node['compass']['git-url']
  revision node['compass']['branch']
  user 'root'
  action :sync
end

execute "chown-data-www" do
  command "chown -R #{node['compass']['user']}:#{node['compass']['user']} #{node['compass']['path']}"
  user "root"
  action :run
end