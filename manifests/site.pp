#node 'ns1', 'ns2' {    # applies to ns1 and ns2 nodes
#  file {'/tmp/dns':    # resource type file and filename
#    ensure => present, # make sure it exists
#    mode => '0644',
#    content => "Only DNS servers get this file.\n",
#  }
#}

node 'puppettest' {                                                         # Could be regex for web01-09 by: 'node /^web0[1-9]+/ {'
  class { 'linux': }                                                        # Call Class
  vcsrepo { '/var/www/html':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/tomreeb/v5',
  }
  class { '::apache': }                                                     # use apache module, install, and start it
  apache::vhost { 'tomreeb.com':                                            # define vhost resource
    port    => '80',
    docroot => '/var/www/html'
  }
}

class linux {

    $optpkgs = ['git', 'nano', 'tmux', 'htop', 'ntp', 'screen']             # Variables

    $ntpservice = $osfamily ? {
      'redhat' => 'ntpd',
      'debian' => 'ntp',
      default  => 'ntpd',
    }

    package { $optpkgs:
      ensure => 'installed',
    }

    service { $ntpservice:
      ensure => 'running',
      enable => true,
    }

    file {'/tmp/example-ip':                                                # resource type file and filename
      ensure  => present,                                                   # make sure it exists
      mode    => '0644',                                                    # file permissions
      content => "Here is my IP Address: ${ipaddress_eno16777984}.\n",      # note the ipaddress_eth0 fact
    }
}
