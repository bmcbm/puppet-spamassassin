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
            notify  => Service["spamassassin"];
        "/etc/cron.d/sa-update":
            mode    => 600,
            source  => "puppet:///modules/spamassassin/cron.d-sa-update",
            require => Package["spamassassin"];
    } # file

    service { "spamassassin":
        ensure  => running,
        enable  => true,
        require => Package["spamassassin"],
        pattern => "spamd",
    } # service
} # class spamassassin
