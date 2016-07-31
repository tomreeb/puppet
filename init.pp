class mediawiki {
  $phpmysql = $osfamily ? {
    'redhat' => 'php-mysql',
    'debian' => 'php5-mysql',
  }

  package { $phpmysql: 
    ensure => 'present',
  }

  if $osfamily = 'redhat' {
      package { 'php-xml' 
        ensure => 'present',
        }
  }

  class { '::apache':                                                      # use apache module, install, and start it
    docroot => '/var/www/html'
    mpm_module => 'present',
    subscribe => Package[$phpmysql],
  }

  class { '::apache::mod::php':}
}