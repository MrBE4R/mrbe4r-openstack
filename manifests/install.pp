class openstack::install inherits openstack {
    package { 'centos-release-openstack-rocky':
            ensure => $ensure_package,
    }
    package { 'python-openstackclient':
            ensure  => $ensure_package,
            require => Package['centos-release-openstack-rocky'],
    }
    package { 'openstack-selinux':
            ensure  => $ensure_package,
            require => Package['centos-release-openstack-rocky'],
    }

    case $node_type {
        'controller': {
            include openstack::role::controller
            include openstack::controller_keystone
            include openstack::controller_glance
            include openstack::controller_nova
            include openstack::controller_neutron
            include openstack::controller_cinder
            include openstack::horizon
        }
        'compute': {
            include openstack::role::compute
            include openstack::compute_nova
            include openstack::compute_neutron
        }
        'ceph': { include openstack::role::ceph }
    }
}
