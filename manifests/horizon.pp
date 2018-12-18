class openstack::horizon inherits openstack {
 if str2bool($https) {
  $packages = ['openstack-dashboard', 'mod_ssl']
  package { $packages:
   ensure  => $ensure_package,
   require => Package['centos-release-openstack-queens'],
  }
  ->
  file { '/etc/openstack-dashboard/local_settings':
   content => epp(
    'openstack/horizon_local_settings.epp',
    {
     'node_admin_ip'                => $node_admin_ip,
     'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret
    }
   )
  }
  ->
  exec { 'generate_tls':
   command =>
    "/usr/bin/openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout /opt/openstack.key -out /opt/openstack.crt -subj \"/C=FR/ST=Pays de la Loire/L=Nantes/O=YamIT/OU=IT/CN=${os_public_name}\"",
   unless  => ["/usr/bin/ls /opt/openstack.crt", "/usr/bin/ls /opt/openstack.key"]
  }
  ->
  file { '/etc/httpd/conf.d/openstack-dashboard.conf':
   content => epp(
    'openstack/ssl-openstack-dashboard.conf.epp',
    {
     'node_admin_ip'                => $node_admin_ip,
     'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret,
     'os_public_name'               => $os_public_name,
     'public_url_keystone'          => "/identity/",
     'public_url_nova'              => "/compute/",
     'public_url_glance'            => "/glance/",
     'public_url_cinder'            => "/volume/",
     'public_url_neutron'           => "/network/",
     'public_url_placement'         => "/placement/",
    }
   )
  }
  ->
  exec { 'add_cert_to_trust_store':
   command => '/usr/bin/ln -s /opt/openstack.crt /etc/pki/ca-trust/source/anchors/openstack.crt',
   unless  => '/usr/bin/ls /etc/pki/ca-trust/source/anchors/openstack.crt'
  }
  ->
  exec { 'trust_certificate':
   command => '/usr/bin/update-ca-trust',
  }
  ->
  exec { 'restart_httpd_horizon':
   command => '/usr/bin/systemctl restart httpd'
  }
 }else {
  $packages = ['openstack-dashboard']
  package { $packages:
   ensure  => $ensure_package,
   require => Package['centos-release-openstack-queens'],
  }
  ->
  file { '/etc/openstack-dashboard/local_settings':
   content => epp(
    'openstack/horizon_local_settings.epp',
    {
     'node_admin_ip'                => $node_admin_ip,
     'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret
    }
   )
  }
  ->
  file { '/etc/httpd/conf.d/openstack-dashboard.conf':
   content => epp(
    'openstack/openstack-dashboard.conf.epp',
    {
     'node_admin_ip'                => $node_admin_ip,
     'metadata_proxy_shared_secret' => $metadata_proxy_shared_secret,
     'os_public_name'               => $os_public_name,
     'public_url_keystone'          => "/identity/",
     'public_url_nova'              => "/compute/",
     'public_url_glance'            => "/glance/",
     'public_url_cinder'            => "/volume/",
     'public_url_neutron'           => "/network/",
     'public_url_placement'         => "/placement/",
    }
   )
  }
  ->
  exec { 'restart_httpd_horizon':
   command => '/usr/bin/systemctl restart httpd'
  }
 }
}