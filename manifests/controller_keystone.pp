class openstack::controller_keystone inherits openstack {
 $packages = ['openstack-keystone', 'httpd', 'mod_wsgi']
 package { $packages:
  ensure  => $ensure_package,
  require => Package['centos-release-openstack-rocky'],
 }

 exec { 'keystone_database_c':
  command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_keystone};'",
  onlyif  => $reset
 }
 exec { 'keystone_database_gl':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_keystone}.* TO keystone@localhost IDENTIFIED BY \"${db_password_keystone}\";'",
  onlyif  => $reset
 }
 exec { 'keystone_database_ga':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_keystone}.* TO keystone@\"%\" IDENTIFIED BY \"${db_password_keystone}\";'",
  onlyif  => $reset
 }
 exec { 'keystone_database_ga2':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_keystone}.* TO keystone@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_keystone}\";'",
  onlyif  => $reset
 }
 exec { 'keystone_database_ga3':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_keystone}.* TO keystone@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_keystone}\";'",
  onlyif  => $reset
 }
 exec { 'keystone_database_ga4':
  command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_keystone}.* TO keystone@\"${::hostname}\" IDENTIFIED BY \"${db_password_keystone}\";'",
  onlyif  => $reset
 }

 service { 'httpd.service':
  ensure => running,
  enable => true,
 }

 exec { 'keystone_dbsync':
  command => "/usr/bin/keystone-manage db_sync",
  user    => "keystone",
  timeout => 600,
  notify  => Exec['keystone_fernet_setup']
 }

 exec { 'keystone_fernet_setup':
  command   => '/usr/bin/keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone',
  notify    => Exec['keystone_credential_setup'],
  subscribe => Exec['keystone_dbsync']
 }

 exec { 'keystone_credential_setup':
  command   => '/usr/bin/keystone-manage credential_setup --keystone-user keystone --keystone-group keystone',
  subscribe => Exec['keystone_fernet_setup'],
  notify    => Exec['keystone_bootstrap'],
 }

 exec { 'keystone_bootstrap':
  command   => "/usr/bin/keystone-manage bootstrap --bootstrap-password ${user_password_admin} --bootstrap-admin-url http://${node_admin_ip}:5000/v3/ --bootstrap-internal-url http://${node_admin_ip}:5000/v3/ --bootstrap-public-url ${public_url_keystone} --bootstrap-region-id ${os_region_id}",
  subscribe => Exec['keystone_credential_setup'],
 }

 exec { 'apache_keystone':
  command => '/usr/bin/ln -sf /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/',
  unless  => '/usr/bin/ls /etc/httpd/conf.d/wsgi-keystone.conf'
 }

 file { '/etc/keystone/keystone.conf':
  content => epp(
   'openstack/keystone.conf.epp',
   {
    'node_admin_ip'        => $node_admin_ip,
    'db_password_keystone' => $db_password_keystone,
    'dbname_keystone'      => $dbname_keystone,
   }
  ),
  owner   => 'keystone'
 }

 exec { 'restart_httpd':
  command => '/usr/bin/systemctl restart httpd.service',
 }

 exec { 'create_service_project':
  command => "/usr/bin/openstack ${os_cli_options} project create --domain default --description 'Service Project' service",
  unless  => "/usr/bin/openstack ${os_cli_options} project list | /usr/bin/grep service"
 }

 exec { 'create_role_user':
  command => "/usr/bin/openstack ${os_cli_options} role create user",
  unless  => "/usr/bin/openstack ${os_cli_options} role list | /usr/bin/grep user"
 }

 Package[$packages] -> Exec['keystone_database_c'] -> Exec['keystone_database_gl'] -> Exec['keystone_database_ga'] ->
 File['/etc/keystone/keystone.conf'] -> Exec['apache_keystone'] -> Service['httpd.service'] -> Exec['keystone_dbsync']
 -> Exec['keystone_fernet_setup'] -> Exec['keystone_credential_setup'] -> Exec['keystone_bootstrap'] -> Exec[
  'restart_httpd'] -> Exec['create_service_project'] -> Exec['create_role_user']
}