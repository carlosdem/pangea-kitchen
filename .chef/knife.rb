cookbook_path    ["#{__dir__}/../cookbooks", "#{__dir__}/../site-cookbooks"]
node_path        "#{__dir__}/../nodes"
role_path        "#{__dir__}/../roles"
environment_path "#{__dir__}/../environments"
data_bag_path    "#{__dir__}/../data_bags"
#encrypted_data_bag_secret "#{__dir__}/../data_bag_key"

# NOTE: these values are injected into the server-side /etc/chef/client.rb
#   on BOOTSTRAP !!!. convering will not pass these values. To apply them to
#   future converges you need to bootstrap the server again (possibly with
#   --no-converge if no converge should happen).
knife[:automatic_attribute_whitelist] = %w[
  fqdn
  os
  os_version
  hostname
  ipaddress
  roles
  ipaddress
  platform
  platform_version
  cloud
  cloud_v2
  chef_packages
  current_user
]
knife[:default_attribute_whitelist] = []

cookbook_license 'gplv3'
cookbook_copyright ENV['DEBFULLNAME'] if ENV.include?('DEBFULLNAME')
cookbook_email ENV['DEBEMAIL'] if ENV.include?('DEBEMAIL')

if chefdk.generator # Chef 13 fully ditches knife for chef-dk.
  chefdk.generator.license = 'gplv3'
  chefdk.generator.copyright_holder = ENV['DEBFULLNAME'] if ENV.include?('DEBFULLNAME')
  chefdk.generator.email = ENV['DEBEMAIL'] if ENV.include?('DEBEMAIL')
end

# This is our default chef version. This only gets increased after testing!
knife[:bootstrap_version] = '18'
# Librarian compatibility.
knife[:berkshelf_path] = 'cookbooks'

def submod
  `git config --local --get include.path`
  unless $?.success?
    system('git submodule init') || raise
    system('git submodule update --remote') || raise
    system('git config --local include.path ../.gitconfig') || raise
    system('git fetch --verbose') || raise
  end
  system('git submodule update --remote --recursive') || raise
  cupboard_dir = "#{__dir__}/../data_bags/cupboard"
  puts 'Calling git secret reveal!'
  puts "#{cupboard_dir}"
  system('git-secret reveal -f', chdir: cupboard_dir) || raise
end
submod unless ENV.include?('NO_CUPBOARD')
