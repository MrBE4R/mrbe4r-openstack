class openstack::controller_nova inherits openstack {
    $packages = ['openstack-nova-api', 'openstack-nova-conductor', 'openstack-nova-console', 'openstack-nova-novncproxy', 'openstack-nova-scheduler', 'openstack-nova-placement-api', 'fping']
    package { $packages:
            ensure  => $ensure_package,
            require => Package['centos-release-openstack-rocky'],
    }

    exec { 'nova_database_c':
            command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_nova};'",
            require => Exec['keystone_database_c'],
    }

    exec { 'nova_database_gl':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova}.* TO \"nova\"@\"localhost\" IDENTIFIED BY \"${db_password_nova}\";'",
            require => Exec['nova_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_database_ga':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova}.* TO \"nova\"@\"%\" IDENTIFIED BY \"${db_password_nova}\";'",
            require => Exec['nova_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_database_ga2':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova}.* TO \"nova\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_nova}\";'",
            require => Exec['nova_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_database_ga3':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova}.* TO \"nova\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_nova}\";'",
            require => Exec['nova_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_database_ga4':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova}.* TO \"nova\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_nova}\";'",
            require => Exec['nova_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_api_database_c':
            command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_nova_api};'",
            require => Exec['keystone_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_api_database_gl':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_api}.* TO \"nova\"@\"localhost\" IDENTIFIED BY \"${db_password_nova_api}\";'",
            require => Exec['nova_api_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_api_database_ga':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_api}.* TO \"nova\"@\"%\" IDENTIFIED BY \"${db_password_nova_api}\";'",
            require => Exec['nova_api_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_api_database_ga2':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_api}.* TO \"nova\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_nova_api}\";'",
            require => Exec['nova_api_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_api_database_ga3':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_api}.* TO \"nova\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_nova_api}\";'",
            require => Exec['nova_api_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_api_database_ga4':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_api}.* TO \"nova\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_nova_api}\";'",
            require => Exec['nova_api_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_cell_database_c':
            command => "/usr/bin/mysql -e 'CREATE DATABASE IF NOT EXISTS ${dbname_nova_cell};'",
            require => Exec['keystone_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_cell_database_gl':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_cell}.* TO \"nova\"@\"localhost\" IDENTIFIED BY \"${db_password_nova_cell}\";'",
            require => Exec['nova_cell_database_c'],
            onlyif  => $reset,
    }

    exec { 'nova_cell_database_ga':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_cell}.* TO \"nova\"@\"%\" IDENTIFIED BY \"${db_password_nova_cell}\";'",
            require => Exec['nova_cell_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_cell_database_ga2':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_cell}.* TO \"nova\"@\"${node_public_ip}\" IDENTIFIED BY \"${db_password_nova_cell}\";'",
            require => Exec['nova_cell_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_cell_database_ga3':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_cell}.* TO \"nova\"@\"${node_admin_ip}\" IDENTIFIED BY \"${db_password_nova_cell}\";'",
            require => Exec['nova_cell_database_c'],
            onlyif  => $reset,
    }
    ->
    exec { 'nova_cell_database_ga4':
            command => "/usr/bin/mysql -e 'GRANT ALL PRIVILEGES ON ${dbname_nova_cell}.* TO \"nova\"@\"${::hostname}\" IDENTIFIED BY \"${db_password_nova_cell}\";'",
            require => Exec['nova_cell_database_c'],
            onlyif  => $reset,
    }

    service { 'openstack-nova-api.service':
            ensure => running,
            enable => true,
    }

    service { 'openstack-nova-consoleauth.service':
            ensure => running,
            enable => true,
    }

    service { 'openstack-nova-scheduler.service':
            ensure => running,
            enable => true,
    }

    service { 'openstack-nova-conductor.service':
            ensure => running,
            enable => true,
    }

    service { 'openstack-nova-novncproxy.service':
            ensure => running,
            enable => true,
    }

    exec { 'nova_user':
            command => "/usr/bin/openstack ${os_cli_options} user create --domain default --password ${user_password_nova} nova",
            unless  => "/usr/bin/openstack ${os_cli_options} user show nova",
    }

    exec { 'nova_role':
            command => "/usr/bin/openstack ${os_cli_options} role add --project service --user nova admin",
    }

    exec { 'nova_service':
            command => "/usr/bin/openstack ${os_cli_options} service create --name nova --description 'OpenStack Compute' compute",
            unless  => "/usr/bin/openstack ${os_cli_options} service show nova",
    }

    exec { 'nova_api_endpoint_public':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} compute public ${public_url_nova}",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service nova --interface public | /usr/bin/grep nova",
    }

    exec { 'nova_api_endpoint_internal':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} compute internal http://${node_admin_ip}:8774/v2.1",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service nova --interface internal | /usr/bin/grep nova",
    }

    exec { 'nova_api_endpoint_admin':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} compute admin http://${node_admin_ip}:8774/v2.1",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service nova --interface admin | /usr/bin/grep nova",
    }

    exec { 'nova_plcmt_user':
            command => "/usr/bin/openstack ${os_cli_options} user create --domain default --password ${user_password_placement} placement",
            unless  => "/usr/bin/openstack ${os_cli_options} user show placement",
    }

    exec { 'nova_plcmt_role':
            command => "/usr/bin/openstack ${os_cli_options} role add --project service --user placement admin",
    }

    exec { 'nova_plcmt_service':
            command => "/usr/bin/openstack ${os_cli_options} service create --name placement --description 'Placement API' placement",
            unless  => "/usr/bin/openstack ${os_cli_options} service show placement",
    }

    exec { 'nova_plcmt_endpoint_public':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} placement public ${public_url_placement}",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service placement --interface public | /usr/bin/grep placement",
    }

    exec { 'nova_plcmt_endpoint_internal':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} placement internal http://${node_admin_ip}:8778",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service placement --interface internal | /usr/bin/grep placement",
    }

    exec { 'nova_plcmt_endpoint_admin':
            command => "/usr/bin/openstack ${os_cli_options} endpoint create --region ${os_region_id} placement admin http://${node_admin_ip}:8778",
            unless  => "/usr/bin/openstack ${os_cli_options} endpoint list --service placement --interface admin | /usr/bin/grep placement",
    }

    file { '/etc/nova/nova.conf':
            content => epp(
                'openstack/controller_nova.epp',
                {
                    'node_admin_ip'                => "${node_admin_ip}",
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

    file { '/etc/httpd/conf.d/00-nova-placement-api.conf':
            content => epp(
                'openstack/00-nova-placement-api.conf.epp',
                {
                    'node_admin_ip'    => "${node_admin_ip}",
                    'db_password_nova' => "${db_password_nova}",
                    'dbname_nova'      => "${dbname_nova}",
                }
            )
    }

    exec { 'restart_httpd_nova':
            command => '/usr/bin/systemctl restart httpd.service',
    }

    exec { 'nova_api_dbsync':
            command => '/usr/bin/nova-manage api_db sync',
            user    => 'nova'
    }

    exec { 'cell0':
            command => '/usr/bin/nova-manage cell_v2 map_cell0',
            user    => 'nova'
    }

    exec { 'cell1':
            command => '/usr/bin/nova-manage cell_v2 create_cell --name=cell1 --verbose',
            user    => 'nova',
            unless  => '/usr/bin/nova-manage cell_v2 list_cells | /usr/bin/grep cell1'
    }

    exec { 'nova_dbsync':
            command => '/usr/bin/nova-manage db sync',
            user    => 'nova'
    }

    exec { 'm1.tiny':
            command => "/usr/bin/openstack ${os_cli_options} flavor create --ram 512 --disk 20 --vcpus 1 m1.tiny",
            unless  => "/usr/bin/openstack ${os_cli_options} flavor show m1.tiny"
    }
    ->
    exec { 'm1.small':
            command => "/usr/bin/openstack ${os_cli_options} flavor create --ram 2048 --disk 20 --vcpus 1 m1.small",
            unless  => "/usr/bin/openstack ${os_cli_options} flavor show m1.small"
    }
    ->
    exec { 'm1.medium':
            command => "/usr/bin/openstack ${os_cli_options} flavor create --ram 4096 --disk 20 --vcpus 2 m1.medium",
            unless  => "/usr/bin/openstack ${os_cli_options} flavor show m1.medium"
    }
    ->
    exec { 'm1.large':
            command => "/usr/bin/openstack ${os_cli_options} flavor create --ram 8192 --disk 20 --vcpus 4 m1.large",
            unless  => "/usr/bin/openstack ${os_cli_options} flavor show m1.large"
    }
    ->
    exec { 'm1.xlarge':
            command => "/usr/bin/openstack ${os_cli_options} flavor create --ram 16384 --disk 20 --vcpus 8 m1.xlarge",
            unless  => "/usr/bin/openstack ${os_cli_options} flavor show m1.xlarge"
    }

    Package[$packages] -> Exec['nova_database_c'] -> Exec['nova_database_gl'] -> Exec['nova_database_ga'] -> Exec['nova_api_database_c'] -> Exec['nova_api_database_gl'] ->
    Exec['nova_api_database_ga'] -> Exec['nova_cell_database_c'] -> Exec['nova_cell_database_gl'] -> Exec['nova_cell_database_ga'] -> File['/etc/nova/nova.conf'] ->
    File['/etc/httpd/conf.d/00-nova-placement-api.conf'] -> Exec['restart_httpd_nova'] -> Exec['nova_user'] -> Exec['nova_role'] -> Exec['nova_service'] -> Exec['nova_api_endpoint_public'] ->
    Exec['nova_api_endpoint_internal'] -> Exec['nova_api_endpoint_admin'] -> Exec['nova_plcmt_user'] -> Exec['nova_plcmt_role'] -> Exec['nova_plcmt_service'] ->
    Exec['nova_plcmt_endpoint_public'] -> Exec['nova_plcmt_endpoint_internal'] -> Exec['nova_plcmt_endpoint_admin'] -> Exec['nova_api_dbsync'] -> Exec['cell0'] ->
    Exec['cell1'] -> Exec['nova_dbsync'] -> Service['openstack-nova-api.service'] -> Service['openstack-nova-consoleauth.service'] -> Service['openstack-nova-scheduler.service'] ->
    Service['openstack-nova-conductor.service'] -> Service['openstack-nova-novncproxy.service'] -> Exec['m1.tiny'] -> Exec['m1.small'] -> Exec['m1.medium'] -> Exec['m1.large'] -> Exec['m1.xlarge']

}