class openstack::config inherits openstack {
    $node_type = Enum['controller','compute','ceph']
}