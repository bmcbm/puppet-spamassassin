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
  $sa_user,
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

  file { "${sa_path}/local.cf":
    content => template('spamassassin/local.cf.erb'),
    require => Package[ $package_list ],
    notify  => Service[ $sa_service ],
  }

  file { "${sa_path}/sa-update-keys":
    ensure => 'directory',
    owner  => $sa_user,
    group  => $sa_user,
    mode   => '0700',
  }

  if $::osfamily == 'Debian' {
    file { '/etc/default/spamassassin':
      content => template('spamassassin/spamassassin-default.erb'),
      require => Package['spamassassin'],
      notify  => Service[ $sa_service ],
    }
  } else {
    # Debian package comes with a nice cronjob in /etc/cron.daily/spamassassin
    cron { 'sa-update':
      ensure  => $cron_ensure,
      command => $sa_update,
      user    => $sa_user,
      hour    => 4,
      minute  => 10,
    }
  }

  service { $sa_service:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['spamassassin'],
  }
}
