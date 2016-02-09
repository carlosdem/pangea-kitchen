#
# Cookbook Name:: images-nci2
# Recipe:: default
#
# Copyright 2016, Jonathan Riddell
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

# Apache
web_app 'images.neon' do
  server_name 'images.neon.kde.org.uk'
  server_aliases ['images.neon.kde.org.uk']
  server_port 80
  docroot '/var/www/images'
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  cookbook 'apache2'
end

cookbook_file 'prune-images' do
  path '/usr/bin/prune-images'
  action :create
  mode 0777
end

cron 'noop' do
  hour '5'
  minute '0'
  command '/usr/bin/prune-images'
  mailto 'jr@jriddell.org'
end