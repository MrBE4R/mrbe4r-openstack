# mrbe4r-openstack

Puppet project to install a minimal openstack cluster.

I've choose to set the publics endpoint behind sub url in the apache configuration to avoid opening ports on the wild internet.

You will get two accounts : Admin and Demo.

By default openstack will use admin or internal endpoint to work.

When using https version, we create a key pair with predefined information. Check ```manifests/horizon.pp``` line 21 to change theses.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

This project has been tested on CentOS 7.x with Openstack Queens and Puppet 4.10.

### Installing

To get this up and running you just need to do the following :

* Install dependencies
```bash
puppet module install puppetlabs-stdlib
```
* Clone the repo inside puppet
```bash
cd /etc/puppetlabs/code/environments/production/modules
git clone https://github.com/MrBE4R/mrbe4r-openstack.git
```
* Add the roles to your nodes
```puppet
node 'os-controller' {
  class {'openstack':
    ensure_package     => 'latest',
    node_type          => 'controller',
    https              => true,
    reset              => '/bin/echo 0',
    self_signed        => true,
    node_admin_ip      => $::ipaddress_eth0,
    node_public_ip     => $::ipaddress_eth0,
    controller_ip      => $::ipaddress_eth0,
    os_region_id       => 'RegionOne',
    provider_interface => 'eth1',
    provider_ip        => $::ipaddress_eth1,
  }
  include openstack::install
}

node 'os-compute-001' {
  class {'openstack':
    ensure_package     => 'latest',
    node_type          => 'compute',
    self_signed        => true,
    controller_ip      => 'XXX.XXX.XXX.XXX',
    node_admin_ip      => $::ipaddress_eth0,
    node_public_ip     => $::ipaddress_eth0,
    os_region_id       => 'RegionOne',
    provider_interface => 'eth1',
    provider_ip        => $::ipaddress_eth1,
  }
  include openstack::install
}
```
* Run puppet on your nodes
* ???
* Enjoy your new openstack cluster
## TODO

* Update for newer releases of openstack
* Cleanup the mess
* your suggestions

## Built With

* [Puppet](https://puppet.com/)

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Jean-François GUILLAUME (Jeff MrBear)** - *Initial work* - [MrBE4R](https://github.com/MrBE4R)

See also the list of [contributors](https://github.com/MrBE4R/mrbe4r-openstack/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used