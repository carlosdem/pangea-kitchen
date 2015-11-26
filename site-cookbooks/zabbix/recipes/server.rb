#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'zabbix'

package 'Install Zabbix Server' do
  package_name %w(zabbix-server-mysql zabbix-frontend-php)
end

%w(apache2 mysql zabbix-server).each do |service_name|
  service service_name do
    action :nothing
  end
end

# mysql2_chef_gem 'default' do
#   action :install
# end
#
# mysql_database_user 'zabbix' do
#   connection host: '127.0.0.1',
#              username: 'root',
#              password: ''
#   password 'zabbix'
#   action :create
# end

config_d = '/etc/zabbix/zabbix_server.conf.d/'

directory config_d do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

ruby_block 'Twiddle server include' do
  block do
    file = Chef::Util::FileEdit.new('/etc/zabbix/zabbix_server.conf')
    file.search_file_replace_line(/# Include=.*conf\.d.*/,
                                  "Include=#{config_d}")
    file.write_file
  end
  notifies :restart, 'service[zabbix-server]', :delayed
end

# This is the amount of pollers zabbix starts. We want this to be roughly
# equal to the amount of hosts we montior. Once we run out of RAM, push
# notification needs to be investigated.
file "#{config_d}/StartPollers.conf" do
  content 'StartPollers=16'
  mode '0600'
  owner 'root'
  group 'root'
  notifies :restart, 'service[zabbix-server]', :delayed
end

# Increase connection limit. Servers are meant to exclusively run zabbix, so
# we can give it a reasonable amount of connections.
file '/etc/mysql/conf.d/max_connections' do
  content 'max_connections = 512'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[mysql]', :delayed
end

ruby_block 'Twiddle timezone' do
  block do
    file = Chef::Util::FileEdit.new('/etc/apache2/conf-available/zabbix.conf')
    file.search_file_replace_line(/.*php_value date.timezone.*/,
                                  '    php_value date.timezone UTC')
    file.write_file
  end
  notifies :restart, 'service[apache2]', :delayed
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'zabbix.conf.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  notifies :restart, 'service[zabbix-agent]', :delayed
end