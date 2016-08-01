node default {                                                              # applies to nodes that aren't explicitly defined
  class { 'linux': }                                                  # Heira will load Linux and Mediawiki classes
}

node 'wiki' {
  #$wikisitename = 'wiki'                                                   # Removed to put into hiera
  heira_include('classes')
  #class { 'linux': }
  #class { 'mediawiki': }
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
