# encoding: UTF-8
#
# Cookbook Name:: openstack-common
# Attributes:: default
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013-2014, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['common']['custom_template_banner'] = '
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
'

# version for python-openstackclient
default['openstack']['common']['client_version'] = '3.11.0'

# OpenStack services and their project names
default['openstack']['common']['services'] = {
  'bare-metal' => 'ironic',
  'block-storage' => 'cinder',
  'compute' => 'nova',
  'compute_api' => 'nova_api',
  'compute_cell0' => 'nova_cell0',
  'dashboard' => 'horizon',
  'database' => 'trove',
  'dns' => 'designate',
  'identity' => 'keystone',
  'image' => 'glance',
  'network' => 'neutron',
  'object-storage' => 'swift',
  'orchestration' => 'heat',
  'telemetry' => 'ceilometer',
  'telemetry-metric' => 'gnocchi',
  'application-catalog' => 'murano'
}

# Setting this to True means that database passwords and service user
# passwords for Keystone will be easy-to-remember values -- they will be
# the same value as the key. For instance, if a cookbook calls the
# ::Openstack::secret routine like so:
#
# pass = secret "passwords", "nova"
#
# The value of pass will be "nova"
#

# Use data bags for storing passwords
# Set this to false in order to get the passwords from attributes like:
# node['openstack']['secret'][key][type]
default['openstack']['use_databags'] = true

# Set databag type
# acceptable values 'encrypted', 'standard', 'vault'
# Set this to 'standard' in order to use regular databags.
# this is not recommended for anything other than dev/CI
# type environments.  Storing real secrets in plaintext = craycray.
# In addition to the encrypted data_bags which are an included
# feature of the official chef project, you can use 'vault' to
# encrypt your secrets with the method provided in the chef-vault gem.
default['openstack']['databag_type'] = 'encrypted'
default['openstack']['vault_gem_version'] = '~> 3.2'

# Default attributes when not using data bags (use_databags = false)
node['openstack']['common']['services'].each_key do |service|
  %w(user service db token).each do |type|
    default['openstack']['secret'][service][type] = "#{service}-#{type}"
  end
end

# The type of token signing to use (uuid or fernet)
default['openstack']['auth']['strategy'] = 'fernet'

# Set to true where using self-signed certs (in testing environments)
default['openstack']['auth']['validate_certs'] = true

# ========================= Encrypted Databag Setup ===========================
#
# The openstack-common cookbook's default library contains a `secret`
# routine that looks up the value of encrypted databag values. This routine
# uses the secret key file located at the following location to decrypt the
# values in the data bag.
default['openstack']['secret']['key_path'] = '/etc/chef/openstack_data_bag_secret'

# The name of the encrypted data bag that stores openstack secrets
default['openstack']['secret']['secrets_data_bag'] = 'secrets'

# The name of the encrypted data bag that stores service user passwords, with
# each key in the data bag corresponding to a named OpenStack service, like
# "nova", "cinder", etc.
default['openstack']['secret']['service_passwords_data_bag'] = 'service_passwords'

# The name of the encrypted data bag that stores DB passwords, with
# each key in the data bag corresponding to a named OpenStack database, like
# "nova", "cinder", etc.
default['openstack']['secret']['db_passwords_data_bag'] = 'db_passwords'

# The name of the encrypted data bag that stores Keystone user passwords, with
# each key in the data bag corresponding to a user (Keystone or otherwise).
default['openstack']['secret']['user_passwords_data_bag'] = 'user_passwords'

# ========================= Package and Repository Setup ======================
#
# Various Linux distributions provide OpenStack packages and repositories.
# The provide some sensible defaults, but feel free to override per your
# needs.

# The coordinated release of OpenStack codename
default['openstack']['release'] = 'ocata'

# The Ubuntu Cloud Archive has packages for multiple Ubuntu releases. For
# more information, see: https://wiki.ubuntu.com/ServerTeam/CloudArchive.
# In the component strings, %codename% will be replaced by the value of
# the node['lsb']['codename'] Ohai value and %release% will be replaced
# by the value of node['openstack']['release']
#
# Change ['openstack']['apt']['update_apt_cache'] to true if you would like
# have the cache automatically updated
default['openstack']['apt']['update_apt_cache'] = false
default['openstack']['apt']['live_updates_enabled'] = true
default['openstack']['apt']['uri'] = 'http://ubuntu-cloud.archive.canonical.com/ubuntu'
default['openstack']['apt']['components'] = ['main']

default['openstack']['yum']['update_yum_cache'] = false
default['openstack']['yum']['rdo_enabled'] = true
default['openstack']['yum']['uri'] = "http://mirror.centos.org/centos/$releasever/cloud/$basearch/openstack-#{node['openstack']['release']}"
default['openstack']['yum']['repo-key'] = "https://github.com/rdo-infra/rdo-release/raw/#{node['openstack']['release']}-rdo/RPM-GPG-KEY-CentOS-SIG-Cloud"
# Enforcing GnuPG signature check for RDO repo. Set this to false if you want to disable the check.
default['openstack']['yum']['gpgcheck'] = true
default['openstack']['endpoints']['family'] = 'inet'

# Set a default region that other regions are set to - such that changing the region for all services can be done in one place
default['openstack']['region'] = 'RegionOne'

# Set a default auth api version that other components use to interact with identity service.
# Allowed auth API versions: v2.0 or v3.0. By default, it is set to v3.0.
default['openstack']['api']['auth']['version'] = 'v3.0'

# Allow configured loggers in logging.conf
default['openstack']['logging']['loggers'] = {
  'root' => {
    'level' => 'NOTSET',
    'handlers' => 'devel'
  },
  'ceilometer' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'ceilometer'
  },
  'cinder' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'cinder'
  },
  'glance' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'glance'
  },
  'horizon' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'horizon'
  },
  'keystone' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'keystone'
  },
  'nova' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'nova'
  },
  'neutron' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'neutron'
  },
  'trove' => {
    'level' => 'DEBUG',
    'handlers' => 'prod,debug',
    'qualname' => 'trove'
  },
  'amqplib' => {
    'level' => 'WARNING',
    'handlers' => 'stderr',
    'qualname' => 'amqplib'
  },
  'sqlalchemy' => {
    'level' => 'WARNING',
    # "level' => 'INFO" logs SQL queries.
    # "level' => 'DEBUG" logs SQL queries and results.
    # "level' => 'WARNING" logs neither.  (Recommended for production systems.)
    'handlers' => 'stderr',
    'qualname' => 'sqlalchemy'
  },
  'boto' => {
    'level' => 'WARNING',
    'handlers' => 'stderr',
    'qualname' => 'boto'
  },
  'suds' => {
    'level' => 'INFO',
    'handlers' => 'stderr',
    'qualname' => 'suds'
  },
  'eventletwsgi' => {
    'level' => 'WARNING',
    'handlers' => 'stderr',
    'qualname' => 'eventlet.wsgi.server'
  },
  'nova_api_openstack_wsgi' => {
    'level' => 'WARNING',
    'handlers' => 'prod,debug',
    'qualname' => 'nova.api.openstack.wsgi'
  },
  'nova_osapi_compute_wsgi_server' => {
    'level' => 'WARNING',
    'handlers' => 'prod,debug',
    'qualname' => 'nova.osapi_compute.wsgi.server'
  }
}

# Allow configured formatters in logging.conf
default['openstack']['logging']['formatters'] = {
  'normal' => {
    'format' => '%(asctime)s %(levelname)s %(message)s'
  },
  'normal_with_name' => {
    'format' => '[%(name)s]: %(asctime)s %(levelname)s %(message)s'
  },
  'debug' => {
    'format' => '[%(name)s]: %(asctime)s %(levelname)s %(module)s.%(funcName)s %(message)s'
  },
  'syslog_with_name' => {
    'format' => '%(name)s: %(levelname)s %(message)s'
  },
  'syslog_debug' => {
    'format' => '%(name)s: %(levelname)s %(module)s.%(funcName)s %(message)s'
  }
}

# Allow configured logging handlers in logging.conf
default['openstack']['logging']['handlers'] = {
  'stderr' => {
    'args' => '(sys.stderr,)',
    'class' => 'StreamHandler',
    'formatter' => 'debug'
  },
  'devel' => {
    'args' => '(sys.stdout,)',
    'class' => 'StreamHandler',
    'formatter' => 'debug',
    'level' => 'NOTSET'
  },
  'prod' => {
    'args' => '((\'/dev/log\'), handlers.SysLogHandler.LOG_LOCAL0)',
    'class' => 'handlers.SysLogHandler',
    'formatter' => 'syslog_with_name',
    'level' => 'INFO'
  },
  'debug' => {
    'args' => '((\'/dev/log\'), handlers.SysLogHandler.LOG_LOCAL1)',
    'class' => 'handlers.SysLogHandler',
    'formatter' => 'syslog_debug',
    'level' => 'DEBUG'
  }
}

default['openstack']['memcached_servers'] = nil

# Default sysctl settings
default['openstack']['sysctl']['net.ipv4.conf.all.rp_filter'] = 0
default['openstack']['sysctl']['net.ipv4.conf.default.rp_filter'] = 0

case node['platform_family']
when 'rhel'
  default['openstack']['common']['platform'] = {
    'package_overrides' => ''
  }
when 'debian'
  default['openstack']['common']['platform'] = {
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end

# The name of the Chef role that installs the Keystone Service API
default['openstack']['identity_service_chef_role'] = 'os-identity'

# The name of the Chef role that sets up the compute worker
default['openstack']['compute_worker_chef_role'] = 'os-compute-worker'
