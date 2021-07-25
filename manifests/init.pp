# == Class: spamassassin
#
# This module manages spamassassin
#
class spamassassin (
  $allowedips,
  $allowtell,
  $blacklist_from,
  $createprefs,
  $cron_ensure,
  $helperhomedir,
  $listenip,
  $local,
  $maxchildren,
  $maxconnperchild,
  $maxspare,
  $minchildren,
  $minspare,
  $nouserconfig,
  $package_ensure,
  $report_safe,
  $roundrobin,
  $service_enable,
  $service_ensure,
  $syslog,
  $trusted_networks,
  $whitelist_from,
  $sa_update,
  $sa_path,
  $sa_service,
  $package_list,
) {
  case $::osfamily {
    'RedHat','Debian','Gentoo': {  }
    default: {
      fail("Class spamassassin supports osfamilies RedHat, Debian and Gentoo. Detected osfamily is ${::osfamily}.")
    }
  }

  package { $package_list:
    ensure => $package_ensure,
  }

  if $::osfamily == 'Debian' {
    file { '/etc/default/spamassassin':
      content => template('spamassassin/spamassassin-default.erb'),
      require => Package['spamassassin'],
      notify  => Service[ $sa_service ],
    }
  }

  cron { 'sa-update':
    ensure  => $cron_ensure,
    command => $sa_update,
    user    => 'root',
    hour    => 4,
    minute  => 10,
  }

  service { $sa_service:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['spamassassin'],
  }
}
