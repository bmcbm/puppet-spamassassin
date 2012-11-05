# Class: spamassassin
#
# This module manages spamassassin
#
class spamassassin {

    case $::osfamily {
        RedHat: {
            $package_list = [ 'perl-Encode-Detect', 'perl-Geography-Countries',
                              'perl-IP-Country', 'perl-Mail-DKIM',
                              'perl-Mail-DomainKeys', 'perl-Mail-SPF',
                              'perl-Mail-SPF-Query', 'perl-Net-Ident',
                              'spamassassin' ]
            $sa_update = '/usr/share/spamassassin/sa-upcate.cron 2>&1 | tee -a /var/log/sa-update.log'
        }
        Debian: {
            ## Debian seems to not have the following perl packages.
            ## * perl-IP-Country
            ## * perl-Mail-DomainKeys
            ## * perl-Mail-SPF-Query
            ## * 
            $package_list = [ 'libencode-detect-perl',
                              'libgeography-countries-perl',
                              'libmail-dkim-perl', 'libmail-spf-perl',
                              'libnet-ident-perl', 'spamassassin', 'spamc' ]
            $sa_update = '/usr/bin/sa-update && /etc/init.d/spamassassin reload'
        }
        default: {
            fail("Module ${module_name} does not support ${::operatingsystem}")
        }
    }

    package { $package_list: }

    file {
        "/etc/mail/spamassassin/v312.pre":
            source  => "puppet:///modules/spamassassin/v312.pre",
            require => Package[ $package_list ],
            notify  => Service["spamassassin"]
    } # file

    if $::osfamily == 'Debian' {
        file { "/etc/default/spamassassin":
            source  => 'puppet:///modules/spamassassin/spamassassin-default',
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

    service { "spamassassin":
        ensure  => running,
        enable  => true,
        require => Package["spamassassin"],
        pattern => "spamd",
    } # service
} # class spamassassin
