# Update apt
execute "apt-get-update-periodic" do
    command "apt-get update"
    user 'root'
end

# Install packages needed for Rubix installation
apt_package 'unzip' do
    action :install
end

apt_package 'build-essential' do
    action :install
end

# Lets just replace this entire thing with Git

# Create tmp directory
#directory node['rubix']['tmp_dir'] do
#  recursive true
#  owner 'vagrant'
#  group 'vagrant'
#  action :create
#end

# Download Rubix
#execute "download rubix" do
#    command "cd #{node['rubix']['tmp_dir']} &&
#            wget #{node['rubix']['source_url']}/#{node['rubix']['source_file']}"
#end

# Unzip
execute "unzip rubix" do
    command "cd #{node['rubix']['tmp_dir']} &&
            unzip -o #{node['rubix']['source_file']}"
end

# Copy Cory files
cookbook_file "#{node['rubix']['tmp_dir']}/default/rubix-3.0/packages.json" do
    source "packages.json"
    owner "vagrant"
    group "vagrant"
    mode "0644"
end

cookbook_file "#{node['rubix']['tmp_dir']}/default/rubix-3.0/gulpfile.js" do
    source "gulpfile.js"
    owner "vagrant"
    group "vagrant"
    mode "0644"
end