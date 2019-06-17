# Class: openstack
# ===========================
#
# Parameters
# ----------
#
# Variables
# ----------
# [ensure_package]
#   Use this to define if puppet should update openstack package to the
#   latest version in this release.
#   Values :
#     present : ensure package is installed
#     latest  : ensure package is installed and at the latest version available
#
# Examples
# --------
#
# Authors
# -------
#
# Jean-François GUILLAUME <jean-francois.guillaume@univ-nantes.fr>
#
# Copyright
# ---------
#
# Copyright 2018 BiRD, unless otherwise noted.
#

class openstack (
    $ensure_package               = 'present',

    $node_type                    = '',
    $https                        = false,
    $reset                        = '/usr/bin/false',
    $self_signed                  = true,

    $controller_ip                = '',

    $node_admin_ip                = '',
    $node_public_ip               = '',

    $os_region_id                 = '',

    $rabbit_password              = 'ChangeMe123',

    $os_public_name               = 'os-bird.univ-nantes.fr',

    $dbname_keystone              = 'keystone',
    $db_password_keystone         = 'ChangeMe123',
    $user_password_keystone       = 'ChangeMe123',
    $public_url_keystone          = "https://${os_public_name}/identity/v3",

    $dbname_nova                  = 'nova',
    $db_password_nova             = 'ChangeMe123',
    $user_password_nova           = 'ChangeMe123',
    $public_url_nova              = "https://${os_public_name}/compute/v2.1",

    $dbname_nova_api              = 'nova_api',
    $db_password_nova_api         = 'ChangeMe123',
    $user_password_nova_api       = 'ChangeMe123',
    $public_url_nova_api          = "https://${os_public_name}/nova_api/",

    $dbname_nova_cell             = 'nova_cell0',
    $db_password_nova_cell        = 'ChangeMe123',
    $user_password_nova_cell      = 'ChangeMe123',
    $public_url_nova_cell         = "https://${os_public_name}/nova_cell/",

    $dbname_horizon               = 'horizon',
    $db_password_horizon          = 'ChangeMe123',
    $user_password_horizon        = 'ChangeMe123',
    $public_url_horizon           = "https://${os_public_name}/dashboard/",

    $dbname_glance                = 'glance',
    $db_password_glance           = 'ChangeMe123',
    $user_password_glance         = 'ChangeMe123',
    $public_url_glance            = "https://${os_public_name}/glance/",

    $dbname_cinder                = 'cinder',
    $db_password_cinder           = 'ChangeMe123',
    $user_password_cinder         = 'ChangeMe123',
    $public_url_cinder            = "https://${os_public_name}/volume/",

    $dbname_neutron               = 'neutron',
    $db_password_neutron          = 'ChangeMe123',
    $user_password_neutron        = 'ChangeMe123',
    $public_url_neutron           = "https://${os_public_name}/network/",
    $provider_interface           = '',
    $provider_ip                  = '',

    $dbname_placement             = '',
    $db_password_placement        = 'ChangeMe123',
    $user_password_placement      = 'ChangeMe123',
    $public_url_placement         = "https://${os_public_name}/placement/",

    $metadata_proxy_shared_secret = 'ChangeMe123',

    $user_password_demo           = 'demo',
    $user_password_admin          = 'admin',

    $os_cli_options               = "--os-domain-name Default --os-project-name admin --os-username admin --os-password ${user_password_admin} --os-auth-url http://${node_admin_ip}:5000/v3 --os-identity-api-version 3"
) {}
