class openstack::controller_glance inherits openstack {
    $packages = ['openstack-glance']
    package { $packages:
            ensure  => $ensure_package,
            require => Package['centos-release-openstack-rocky'],
    }

    exec { 'glance_database_c':
            command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_glance};'",
            onlyif  => $reset
    }

    exec { 'glance_database_gl':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_glance}.* TO \"glance\"@\"localhost\" IDENTIFIED BY \"${db_password_glance}\";'",
            onlyif  => $reset
    }

    exec { 'glance_database_ga':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_glance}.* TO \"glance\"@\"%\" IDENTIFIED BY \"${db_password_glance}\";'",
            onlyif  => $reset
    }
    ->
    exec { 'glance_database_ga2':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_glance}.* TO \"glance\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_glance}\";'",
            onlyif  => $reset
    }
    ->
    exec { 'glance_database_ga3':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_glance}.* TO \"glance\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_glance}\";'",
            onlyif  => $reset
    }
    ->
    exec { 'glance_database_ga4':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_glance}.* TO \"glance\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_glance}\";'",
            onlyif  => $reset
    }

    service { 'openstack-glance-api.service':
            ensure => running,
            enable => true,
    }

    service { 'openstack-glance-registry.service':
            ensure => running,
            enable => true,
    }

    exec { 'glance_user':
            command => "/usr/bin/openstack ${os_cli_options} user create --domain default --password ${user_password_glance} glance",
            unless  => "/usr/bin/openstack ${os_cli_options} user show glance",
    }

    exec { 'glance_role':
            command => "/usr/bin/openstack ${os_cli_options} role add --project service --user glance admin",
    }

    exec { 'glance_service':
            command => "/usr/bin/openstack ${os_cli_options} service create --name glance --description 'OpenStack Image' image",
            unless  => "/usr/bin/openstack ${os_cli_options} service show glance",
    }

    exec { 'glance_endpoint_public':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} image public ${public_url_glance}",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service glance --interface public | /usr/bin/grep glance",
    }

    exec { 'glance_endpoint_internal':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} image internal http://${node_admin_ip}:9292/",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service glance --interface internal | /usr/bin/grep glance",
    }

    exec { 'glance_endpoint_admin':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} image admin http://${node_admin_ip}:9292/",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service glance --interface admin | /usr/bin/grep glance",
    }

    file { '/etc/glance/glance-api.conf':
            content => epp(
                'openstack/glance-api.conf.epp',
                {
                    'node_admin_ip'      => $node_admin_ip,
                    'db_password_glance' => $db_password_glance,
                    'dbname_glance'      => $dbname_glance,
                    'os_region_id'       => "${os_region_id}",
                }
            )
    }

    file { '/etc/glance/glance-registry.conf':
            content => epp(
                'openstack/glance-registry.conf.epp',
                {
                    'node_admin_ip'      => $node_admin_ip,
                    'db_password_glance' => $db_password_glance,
                    'dbname_glance'      => $dbname_glance,
                }
            )
    }

    exec { 'glance_dbsync':
            command => '/usr/bin/glance-manage db_sync',
            user    => 'glance'
    }

    Package[$packages] -> Exec['glance_database_c'] -> Exec['glance_database_gl'] -> Exec['glance_database_ga'] ->
    Exec['glance_user'] -> Exec['glance_role'] -> Exec['glance_service'] ->
    Exec['glance_endpoint_public'] -> Exec['glance_endpoint_internal'] -> Exec['glance_endpoint_admin'] ->
    File['/etc/glance/glance-api.conf'] -> File['/etc/glance/glance-registry.conf'] -> Exec['glance_dbsync'] ->
    Service['openstack-glance-api.service'] -> Service['openstack-glance-registry.service']
}