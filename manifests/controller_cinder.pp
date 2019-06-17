class openstack::controller_cinder inherits openstack {
 $packages = ['openstack-cinder']
 package { $packages:
  ensure  => $ensure_package,
  require => Package['centos-release-openstack-rocky'],
 }
 ->
 exec { 'cinder_database_c':
  command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_cinder};'",
  require => Exec['keystone_database_c'],
 }
 ->
 exec { 'cinder_database_gl':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_cinder}.* TO \"cinder\"@\"localhost\" IDENTIFIED BY \"${db_password_cinder}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 ->
 exec { 'cinder_database_ga':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_cinder}.* TO \"cinder\"@\"%\" IDENTIFIED BY \"${db_password_cinder}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'cinder_database_ga2':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_cinder}.* TO \"cinder\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_cinder}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'cinder_database_ga3':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_cinder}.* TO \"cinder\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_cinder}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 exec { 'cinder_database_ga4':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_cinder}.* TO \"cinder\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_cinder}\";'",
  require => Exec['keystone_database_c'],
  onlyif  => $reset,
 }
 ->
 exec { 'cinder_user':
  command => "/usr/bin/openstack ${os_cli_options} user create --domain default --password ${user_password_cinder} cinder",
  unless  => "/usr/bin/openstack ${os_cli_options} user show cinder",
 }
 ->
 exec { 'cinder_role':
  command => "/usr/bin/openstack ${os_cli_options} role add --project service --user cinder admin",
 }
 ->
 exec { 'cinder_service_v2':
  command => "/usr/bin/openstack ${os_cli_options} service create --name cinderv2 --description 'OpenStack Block Storage' volumev2",
  unless  => "/usr/bin/openstack ${os_cli_options} service show cinderv2",
 }
 ->
 exec { 'cinder_service_v3':
  command => "/usr/bin/openstack ${os_cli_options} service create --name cinderv3 --description 'OpenStack Block Storage' volumev3",
  unless  => "/usr/bin/openstack ${os_cli_options} service show cinderv3",
 }
 ->
 exec { 'cinder_api_endpoint_public_v2':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev2 public ${public_url_cinder}v2/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv2 --interface public | /usr/bin/grep cinderv2",
 }
 ->
 exec { 'cinder_api_endpoint_internal_v2':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev2 internal http://${node_admin_ip}:8776/v2/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv2 --interface internal | /usr/bin/grep cinderv2",
 }
 ->
 exec { 'cinder_api_endpoint_admin_v2':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev2 admin http://${node_admin_ip}:8776/v2/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv2 --interface admin | /usr/bin/grep cinderv2",
 }
 ->
 exec { 'cinder_api_endpoint_public_v3':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev3 public ${public_url_cinder}v3/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv3 --interface public | /usr/bin/grep cinderv3",
 }
 ->
 exec { 'cinder_api_endpoint_internal_v3':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev3 internal http://${node_admin_ip}:8776/v3/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv3 --interface internal | /usr/bin/grep cinderv3",
 }
 ->
 exec { 'cinder_api_endpoint_admin_v3':
  command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} volumev3 admin http://${node_admin_ip}:8776/v3/%\(project_id\)s",
  unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service cinderv3 --interface admin | /usr/bin/grep cinderv3",
 }
 ->
 file { '/etc/cinder/cinder.conf':
  content => epp(
   'openstack/cinder.conf.epp',
   {
    'db_password_cinder'   => $db_password_cinder,
    'node_admin_ip'        => $node_admin_ip,
    'dbname_cinder'        => $dbname_cinder,
    'user_password_cinder' => $user_password_cinder,
    'os_region_id'         => $os_region_id,
    'rabbit_password'      => $rabbit_password,
    'controller_ip'        => $controller_ip,
   }
  )
 }
 ->
 exec { 'cinder_dbsync':
  command => '/usr/bin/cinder-manage db sync',
  user    => 'cinder'
 }
 ->
 service { 'openstack-cinder-api.service':
  ensure => running,
  enable => true,
 }
 ->
 service { 'openstack-cinder-scheduler.service':
  ensure => running,
  enable => true,
 }
}