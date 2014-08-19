# == Class: spamassassin
#
# This module manages spamassassin
#
class spamassassin (
  $listenip         = '127.0.0.1',
  $allowedips       = '127.0.0.1',
  $helperhomedir    = '',
  $nouserconfig     = false,
  $allowtell        = false,
  $report_safe      = 1,
  $trusted_networks = '', # e.g. '192.168.'
  $whitelist_from   = [],
  $blacklist_from   = [],
) {
  case $::osfamily {
    RedHat: {
      $package_list = [
        'perl-Encode-Detect', 'perl-Geography-Countries',
        'perl-IP-Country', 'perl-Mail-DKIM',
        'perl-Mail-DomainKeys', 'perl-Mail-SPF',
        'perl-Mail-SPF-Query', 'perl-Net-Ident',
        'spamassassin'
      ]
      $sa_update = '/usr/share/spamassassin/sa-update.cron 2>&1 | tee -a /var/log/sa-update.log'
    }
    Debian: {
      ## Debian seems to not have the following perl packages.
      ## * perl-IP-Country
      ## * perl-Mail-DomainKeys
      ## * perl-Mail-SPF-Query
      $package_list = [
        'libencode-detect-perl',
        'libgeography-countries-perl',
        'libmail-dkim-perl', 'libmail-spf-perl',
        'libnet-ident-perl', 'spamassassin', 'spamc'
      ]
      $sa_update = '/usr/bin/sa-update && /etc/init.d/spamassassin reload'
    }
    default: {
      fail("Class spamassassin supports osfamilies RedHat and Debian. Detected osfamily is ${::osfamily}.")
    }
  }

  package { $package_list: }

  file { '/etc/mail/spamassassin/init.pre':
    source  => 'puppet:///modules/spamassassin/init.pre',
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  file { '/etc/mail/spamassassin/local.cf':
    content => template('spamassassin/local.cf'),
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  file { '/etc/mail/spamassassin/v310.pre':
    source  => 'puppet:///modules/spamassassin/v310.pre',
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  file { '/etc/mail/spamassassin/v312.pre':
    source  => 'puppet:///modules/spamassassin/v312.pre',
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  file { '/etc/mail/spamassassin/v320.pre':
    source  => 'puppet:///modules/spamassassin/v320.pre',
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  file { '/etc/mail/spamassassin/v330.pre':
    source  => 'puppet:///modules/spamassassin/v330.pre',
    require => Package[ $package_list ],
    notify  => Service['spamassassin']
  }

  if $::osfamily == 'Debian' {
    file { '/etc/default/spamassassin':
      content => template('spamassassin/spamassassin-default'),
      require => Package['spamassassin'],
      notify  => Service['spamassassin'],
    }
  }

  cron { 'sa-update':
    command => $sa_update,
    user    => 'root',
    hour    => 4,
    minute  => 10,
  }

  service { 'spamassassin':
    ensure  => running,
    enable  => true,
    require => Package['spamassassin'],
    pattern => 'spamd',
  }
}
