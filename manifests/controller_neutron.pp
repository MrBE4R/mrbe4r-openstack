class openstack::controller_neutron inherits openstack {
 $packages = ['openstack-neutron', 'openstack-neutron-ml2', 'openstack-neutron-linuxbridge', 'ebtables']
 package { $packages:
  ensure  => $ensure_package,
  require => Package['centos-release-openstack-rocky'],
 }
 ->
 exec { 'neutron_database_c':
  command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_neutron};'",
  require => Exec['keystone_database_c'],
 }
 ->
 exec { 'neutron_database_gl':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_neutron}.* TO \"neutron\"@\"localhost\" IDENTIFIED BY \"${db_password_neutron}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 ->
 exec { 'neutron_database_ga':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_neutron}.* TO \"neutron\"@\"%\" IDENTIFIED BY \"${db_password_neutron}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'neutron_database_ga2':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_neutron}.* TO \"neutron\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_neutron}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'neutron_database_ga3':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_neutron}.* TO \"neutron\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_neutron}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'neutron_database_ga4':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_neutron}.* TO \"neutron\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_neutron}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 ->
 exec { 'neutron_user':
  command => "/usr/bin/openstack ${os_cli_options} user create --domain default --password ${user_password_neutron} neutron",
  unless  => "/usr/bin/openstack ${os_cli_options} user show neutron",
 }
 ->
 exec { 'neutron_role':
  command => "/usr/bin/openstack ${os_cli_options} role add --project service --user neutron admin",
 }
 ->
 exec { 'neutron_service':
  command => "/usr/bin/openstack ${os_cli_options} service create --name neutron --description 'OpenStack Networking' network",
  unless  => "/usr/bin/openstack ${os_cli_options} service show neutron",
 }
 ->
 exec { 'neutron_api_endpoint_public':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} network public ${public_url_neutron}",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service neutron --interface public | /usr/bin/grep neutron",
 }
 ->
 exec { 'neutron_api_endpoint_internal':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} network internal http://${node_admin_ip}:9696",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service neutron --interface internal | /usr/bin/grep neutron",
 }
 ->
 exec { 'neutron_api_endpoint_admin':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} network admin http://${node_admin_ip}:9696",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service neutron --interface admin | /usr/bin/grep neutron",
 }
 ->
 exec { 'restart_nova_api_neutron':
  command => '/usr/bin/systemctl restart openstack-nova-api.service'
 }
 ->
 file { 'metadata_agent.ini':
  path    => '/etc/neutron/metadata_agent.ini',
  content => epp(
   'openstack/metadata_agent.ini.epp',
   {
    'node_admin_ip'                => $node_admin_ip,
    'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret
   }
  )
 }
 ->
 file { '/etc/neutron/neutron.conf':
  content => epp(
   'openstack/neutron.conf.epp',
   {
    'db_password_neutron'          => $db_password_neutron,
    'node_admin_ip'                => $node_admin_ip,
    'dbname_neutron'               => $dbname_neutron,
    'user_password_neutron'        => $user_password_neutron,
    'user_password_nova'           => $user_password_nova,
    'os_region_id'                 => $os_region_id,
    'rabbit_password'              => $rabbit_password,
    'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret,
    'controller_ip'                => $controller_ip
   }
  )
 }
 ->
 file { '/etc/neutron/plugins/ml2/ml2_conf.ini':
  content => epp(
   'openstack/ml2_conf.ini.epp',
  )
 }
 ->
 file { '/etc/neutron/plugins/ml2/linuxbridge_agent.ini':
  content => epp(
   'openstack/linuxbridge_agent.ini.epp',
   {
    'provider_interface' => $provider_interface,
    'provider_ip'        => $provider_ip,
   }
  )
 }
 ->
 file { '/etc/neutron/l3_agent.ini':
  content => epp(
   'openstack/l3_agent.ini.epp',
  )
 }
 ->
 file { '/etc/neutron/dhcp_agent.ini':
  content => epp(
   'openstack/dhcp_agent.ini.epp',
  )
 }
 ->
 file { '/etc/sysctl.d/iptables.conf':
  content => epp(
   'openstack/iptables.conf.epp',
  )
 }
 ->
 exec { 'apply_sysctl':
  command => '/usr/sbin/sysctl -p'
 }
 ->
 exec { 'neutron_ml2':
  command => '/usr/bin/ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini',
  unless  => '/usr/bin/ls /etc/neutron/plugin.ini'
 }
 ->
 exec { 'neutron_dbsync':
  command => '/usr/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head',
  user    => 'neutron'
 }
 ->
 service { 'neutron-server.service':
  ensure => running,
  enable => true,
 }
 ->
 service { 'neutron-linuxbridge-agent.service':
  ensure => running,
  enable => true,
 }
 ->
 service { 'neutron-dhcp-agent.service':
  ensure => running,
  enable => true,
 }
 ->
 service { 'neutron-metadata-agent.service':
  ensure => running,
  enable => true,
 }
 ->
 service { 'neutron-l3-agent.service':
  ensure => running,
  enable => true,
 }
 ->
 exec { 'neutron_public_network':
  command => "/usr/bin/openstack ${os_cli_options} network create --external --share --provider-physical-network public --provider-network-type flat public",
  unless  => "/usr/bin/openstack ${os_cli_options} network show public",
 }
}