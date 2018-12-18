class openstack::compute_nova inherits openstack {
 $packages = ['openstack-nova-compute', 'libguestfs-tools']
 package { $packages:
  ensure  => $ensure_package,
  require => Package['centos-release-openstack-queens'],
 }


 service { 'openstack-nova-compute.service':
  ensure => running,
  enable => true,
 }

 service { 'libvirtd.service':
  ensure => running,
  enable => true,
 }

 file { '/etc/nova/nova.conf':
  content => epp(
   'openstack/compute_nova.epp',
   {
    'node_admin_ip'                => "${node_admin_ip}",
    'controller_ip'                => "${controller_ip}",
    'db_password_nova'             => "${db_password_nova}",
    'db_password_nova_api'         => "${db_password_nova_api}",
    'dbname_nova_api'              => "${dbname_nova_api}",
    'dbname_nova'                  => "${dbname_nova}",
    'rabbit_password'              => "${rabbit_password}",
    'os_region_id'                 => "${os_region_id}",
    'metadata_proxy_shared_secret' => "${metadata_proxy_shared_secret}",
    'user_password_neutron'        => "${user_password_neutron}",
    'user_password_nova'           => "${user_password_nova}",
    'user_password_placement'      => "${user_password_placement}",
    'os_public_name'               => "${os_public_name}",
   }
  )
 }


 Package[$packages] -> File['/etc/nova/nova.conf'] -> Service['openstack-nova-compute.service'] -> Service['libvirtd.service']

}