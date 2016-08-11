class xwifi_spacewalk {

  $spwk_svr = xfwspwk-ch2-02.sys.comcast.net
  $spwk_pkgs = [ 'rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'm2crypto', 'yum-rhn-plugin', 'rhncfg', 'rhncfg-actions', 'rhncfg-client', 'osad' ]

  if ($::fqdn =~ /^xfwaaa/) {
    $activation_key = 1-xfinity_wifi_3xA
  }
  elseif ($::lsbmajdistrelease = 7) {
    $activation_key = 1-el7_aws_key
  }
  elseif ($::lsbdistrelease = 6.6) {
    $activation_key = 1-centos6.6
  }
  else {
    $activation_key = 1-generic
  }

  package { $spwk_pkgs:
    ensure  => 'latest',
  }

  service { 'osad':
    ensure  => running,
    enable  => true,
    require => Package['osad'];
    }

  exec{'retrieve_cert':
    command => "/usr/bin/wget -P /usr/share/rhn http://$spwk_svr/pub/RHN-ORG-TRUSTED-SSL-CERT",
    creates => "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT",
  }

  file{'/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT':
    mode    => 0755,
    require => Exec["retrieve_cert"],
  }

  exec{'activate':
    command => "rhnreg_ks --serverUrl=http://$spwk_svr/XMLRPC --activationkey=$activation_key"
  }

  exec{'rhn-actions':
    command => "rhn-actions-control --enable-all"
  }
}
