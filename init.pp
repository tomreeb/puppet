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
}