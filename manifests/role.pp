class openstack::role::controller inherits openstack {
    stage { 'package_installation': }
    stage { 'service_configuration': }
    stage { 'controller_installation': }

    Stage['package_installation'] -> Stage['service_configuration'] -> Stage['controller_installation']

    class { 'openstack::role::controller::install_packages':
            stage => package_installation
    }

    class { 'openstack::role::controller::config_service':
            stage => service_configuration,
    }
}

class openstack::role::controller::install_packages inherits openstack {
    $packages = [ 'etcd', 'python2-PyMySQL', 'rabbitmq-server', 'memcached', 'python-memcached', 'mariadb', 'mariadb-server' ]
    package { $packages:
            ensure  => $ensure_package,
            require => Package['centos-release-openstack-rocky'],
    }
    ->
    file { '/etc/sysconfig/memcached':
            content => epp(
                'openstack/memcached.epp',
            )
    }
    ->
    service { 'mariadb':
            ensure => 'running',
            enable => true
    }
    ->
    service { 'memcached':
            ensure => 'running',
            enable => true
    }
    ->
    service { 'rabbitmq-server':
            ensure => 'running',
            enable => true
    }
    ->
    exec { 'add_rabbit_os_user':
            command => "/usr/sbin/rabbitmqctl add_user openstack ${rabbit_password}",
            unless  => "/usr/sbin/rabbitmqctl list_users | /usr/bin/grep openstack"
    }
    ->
    exec { 'set_rabbit_os_perm':
            command => '/usr/sbin/rabbitmqctl set_permissions openstack ".*" ".*" ".*"',
            unless  => '/usr/sbin/rabbitmqctl'
    }
}

class openstack::role::controller::config_service inherits openstack {
    file { '/etc/my.cnf.d/openstack.cnf':
            content => epp(
                'openstack/openstack_mycnf.epp',
                { 'node_admin_ip' => $node_admin_ip }
            ),
            notify  => Exec['init_restart_mysql']
    }
    exec { 'init_restart_mysql':
            command   => "/usr/bin/systemctl restart mariadb",
            subscribe => File['/etc/my.cnf.d/openstack.cnf'],
            unless    => '/usr/sbin/ss -tln | /usr/bin/grep 3306 | /usr/bin/grep -E "(\*|\:\:\:)"'
    }

    file { '/etc/etcd/etcd.conf':
            content => epp(
                'openstack/etcd.conf.epp',
                { 'node_admin_ip' => $node_admin_ip }
            ),
            notify  => Exec['init_restart_etcd']
    }
    exec { 'init_restart_etcd':
            command   => "/usr/bin/systemctl restart etcd",
            subscribe => File['/etc/etcd/etcd.conf'],
            unless    => [
                "/usr/sbin/ss -tln | /usr/bin/grep 2379 | /usr/bin/grep -E '(${node_admin_ip})'",
                "/usr/sbin/ss -tln | /usr/bin/grep 2380 | /usr/bin/grep -E '(${node_admin_ip})'"
            ]
    }
}



class openstack::role::compute inherits openstack {
}

class openstack::role::ceph inherits openstack {
    #
    # TODO
    #
}