class mediawiki {

  $wikimetanamespace = hiera('mediawiki::wikimetanamespace')
  $wikisitename = hiera('mediawiki::wikisitename')
  $wikiserver = hiera('mediawiki::wikiserver')
  $wikidbserver = hiera('mediawiki::wikidbserver')
  $wikidbname = hiera('mediawiki::wikidbname')
  $wikidbuser = hiera('mediawiki::wikidbuser')
  $wikidbpassword = hiera('mediawiki::wikidbpassword')
  $wikiupgradekey = hiera('mediawiki::wikiupgradekey')
  
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

  class { '::apache':                                                     # use apache module, install, and start it
    docroot => '/var/www/html'
    mpm_module => 'present',
    subscribe => Package[$phpmysql],
  }

  class { '::apache::mod::php':}                                          # :: means puppet looks for apache class at top level

  vcsrepo { '/var/www/html':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/wikimedia/mediawiki.git',
    revision => 'REL1_23',
    }

  file { '/var/www/html/index.html':                                      # Delete the file because git wont clone to a non-empty dir
    ensure => 'absent',
  }

  File['/var/www/html/index.html'] -> Vcsrepo['/var/www/html']            # Ordering arrow. Want File to run before Vcsrepo

  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    override_options        => $override_options
  }

  class { '::firewall': }                                                 # Ensures firewall is installed and running

  firewall { '000 allow http access':
    port   => '80',
    proto  => 'tcp',
    action => 'accept',
  }

  file { 'LocalSettings.php':
    path    => '/var/www/html/LocalSettings.php',
    ensure  => 'file',
    content => template('mediawiki/LocalSettings.erb'),
  }

}
