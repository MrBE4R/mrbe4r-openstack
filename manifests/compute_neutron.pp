class openstack::compute_neutron inherits openstack {
 $packages = ['openstack-neutron-linuxbridge', 'ebtables', 'ipset']
 package { $packages:
  ensure  => $ensure_package,
  require => Package['centos-release-openstack-rocky'],
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
   'openstack/compute_neutron.conf.epp',
   {
    'db_password_neutron'          => $db_password_neutron,
    'node_admin_ip'                => $node_admin_ip,
    'controller_ip'                => $controller_ip,
    'dbname_neutron'               => $dbname_neutron,
    'user_password_neutron'        => $user_password_neutron,
    'user_password_nova'           => $user_password_nova,
    'os_region_id'                 => $os_region_id,
    'rabbit_password'              => $rabbit_password,
    'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret
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
 service { 'neutron-linuxbridge-agent.service':
  ensure => running,
  enable => true,
 }
}