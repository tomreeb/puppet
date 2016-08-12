class xwifi_spacewalk {

  $spwk_svr = xfwspwk-ch2-02.sys.comcast.net
  $spwk_pkgs = [ 'rhn-client-tools', 'rhn-check', 'rhn-setup', 'rhnsd', 'm2crypto', 'yum-rhn-plugin', 'rhncfg', 'rhncfg-actions', 'rhncfg-client', 'osad', 'python-hwdata' ]

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

  yumrepo { "spwk_repo":
      baseurl => "http://yum.spacewalkproject.org/2.4-client/RHEL/$operatingsystemmajrelease/$architecture",
      descr => "Spacewalk 2.4 Client Repo",
      enabled => 1,
      gpgcheck => 0
   }

  package { $spwk_pkgs:
    ensure  => 'latest',
  }

  service { 'osad':
    ensure  => running,
    enable  => true,
    require => Package['osad'];
    }

  exec{ 'repo_del' :
    path    => '/bin',
    command => "mv /etc/yum.repos.d /etc/yum.repos.d.bak",
  }

  exec{ 'retrieve_cert' :
    path    => '/usr/bin',
    command => "wget -P /usr/share/rhn http://$spwk_svr/pub/RHN-ORG-TRUSTED-SSL-CERT",
    creates => "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT",
  }

  file{ '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT' :
    mode    => 0755,
    require => Exec["retrieve_cert"],
  }

  exec{ 'activate' :
    path    => '/usr/sbin',
    command => "rhnreg_ks --serverUrl=http://$spwk_svr/XMLRPC --activationkey=$activation_key",
  }

  exec{ 'rhn-actions' :
    path    => '/usr/sbin',
    command => "rhn-actions-control --enable-all",
  }
}
