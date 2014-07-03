# == Class: ldap::client
#
# Puppet module to manage client installation and configuration for
# **OpenLdap**.
#
#
# === Parameters
#
#  [uri]
#    Ldap URI as a string. Multiple values can be set
#    separated by spaces ('ldap://ldapmaster ldap://ldapslave')
#    **Required**
#
#  [base]
#    Ldap base dn.
#    **Required**
#
#  [version]
#    Ldap version for the connecting client
#    *Optional* (defaults to 3)
#
#  [timelimit]
#    Time limit in seconds to use when performing searches
#    *Optional* (defaults to 30)
#
#  [bind_timelimit]
#    *Optional* (defaults to 30)
#
#  [idle_timelimit]
#    *Optional* (defaults to 30)
#
#  [binddn]
#    Default bind dn to use when performing ldap operations
#    *Optional* (defaults to false)
#
#  [bindpw]
#    Password for default bind dn
#    *Optional* (defaults to false)
#
#  [ssl]
#    Enable TLS/SSL negotiation with the server
#    *Requires*: ssl_cert parameter
#    *Optional* (defaults to false)
#
#  [ssl_cert]
#    Filename for the CA (or self signed certificate). It should
#    be located under puppet:///files/ldap/
#    *Optional* (defaults to false)
#
#  [nsswitch]
#    If enabled (nsswitch => true) enables nsswitch to use
#    ldap as a backend for password, group and shadow databases.
#    *Requires*: https://github.com/torian/puppet-nsswitch.git (in alpha)
#    *Optional* (defaults to false)
#
#  [nss_passwd]
#    Search base for the passwd database. *base* will be appended.
#    *Optional* (defaults to false)
#
#  [nss_group]
#    Search base for the group database. *base* will be appended.
#    *Optional* (defaults to false)
#
#  [nss_shadow]
#    Search base for the shadow database. *base* will be appended.
#    *Optional* (defaults to false)
#
#  [pam]
#    If enabled (pam => true) enables pam module, which will
#    be setup to use pam_ldap, to enable authentication.
#    *Requires*: https://github.com/torian/puppet-pam.git (in alpha)
#    *Optional* (defaults to false)
#
#  [pam_att_login]
#    User's login attribute
#    *Optional* (defaults to *'uid'*)
#
#  [pam_att_member]
#    Member attribute to use when testing user's membership
#    *Optional* (defaults to *'member'*)
#
#  [pam_passwd]
#    Password hash algorithm
#    *Optional* (defaults to *'md5'*)
#
#  [pam_filter]
#    Filter to use when retrieving user information
#    *Optional* (defaults to *'objectClass=posixAccount'*)
#
#  [sudoers_base]
#    The DN (parameter $base is appended) to use when performing sudo
#    LDAP queries. Typically this is of the form ou=SUDOers,dc=example,dc=com
#    for the domain example.com.
#    *Optional* (defaults to false)
#
#  [sudoers_filter]
#    An LDAP filter which is used to restrict the set of records returned when
#    performing a sudo LDAP query. Typically, this is of the form attribute=value
#    or (&(attribute=value)(attribute2=value2)).
#    *Optional* (defaults to false)
#
#  [sudoers_timed]
#    Whether or not to evaluate the sudoNotBefore and sudoNotAfter attributes
#    that implement time-dependent sudoers entries.
#    *Optional* (defaults to false)
#
#  [sudoers_debug]
#    This sets the debug level for sudo LDAP queries. Debugging information
#    is printed to the standard error.
#    Should not be set on production environments
#    *Optional* (defaults to 0)
#
#  [enable_motd]
#    Use motd to report the usage of this module.
#    *Requires*: https://github.com/torian/puppet-motd.git
#    *Optional* (defaults to false)
#
#  [ensure]
#    *Optional* (defaults to 'present')
#
#
# == Tested/Works on:
#   - Debian:    5.0   / 6.0   / 7.x
#   - RHEL       5.x   / 6.x
#   - CentOS     5.x   / 6.x
#   - OpenSuse:  11.x  / 12.x
#   - OVS:       2.1.1 / 2.1.5 / 2.2.0 / 3.0.2
#
#
# === Examples
#
# class { 'ldap':
#  uri  => 'ldap://ldapserver00 ldap://ldapserver01',
#  base => 'dc=suffix',
# }
#
# class { 'ldap':
#  uri  => 'ldap://ldapserver00',
#  base => 'dc=suffix',
#  ssl  => true,
#  ssl_cert => 'ldapserver00.pem'
# }
#
# class { 'ldap':
#  uri        => 'ldap://ldapserver00',
#  base       => 'dc=suffix',
#  ssl        => true,
#  ssl_cert => 'ldapserver00.pem'
#
#  nsswitch   => true,
#  nss_passwd => 'ou=users',
#  nss_shadow => 'ou=users',
#  nss_group  => 'ou=groups',
#
#  pam        => true,
# }
#
#
# === Authors
#
# Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
# === Copyleft
#
# Copyleft (C) 2012 Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
class ldap::client(
  $uri,
  $base,
  $version        = '3',
  $timelimit      = 30,
  $bind_timelimit = 30,
  $idle_timelimit = 60,
  $binddn         = false,
  $bindpw         = false,
  $ssl            = false,
  $ssl_cert       = false,

  $nsswitch   = false,
  $nss_passwd = false,
  $nss_group  = false,
  $nss_shadow = false,

  $pam            = false,
  $pam_att_login  = 'uid',
  $pam_att_member = 'member',
  $pam_passwd     = 'md5',
  $pam_filter     = 'objectClass=posixAccount',

  $sudoers_base   = false,
  $sudoers_filter = false,
  $sudoers_timed  = false,
  $sudoers_debug  = 0,

  $enable_motd    = false,
  $ensure         = present) {

  require ldap

  if($enable_motd) {
    motd::register { 'ldap': }
  }

  File {
    ensure  => $ensure,
    mode    => '0644',
    owner   => $ldap::params::owner,
    group   => $ldap::params::group,
  }

  file { $ldap::params::prefix:
    ensure  => $ensure ? {
                  present => directory,
                  default => absent,
                },
    require => Package[$ldap::params::package],
  }

  if($sudoers_base) {
    if(! $sudoers_filter) {
      fail('If sudoers_base attribute is set, you must define sudoers_filter')
    }
  }

  file { "${ldap::params::prefix}/${ldap::params::config}":
    content => template("ldap/${ldap::params::prefix}/${ldap::params::config}.erb"),
    require => File[$ldap::params::prefix],
  }

  # Configurations based on operating system release
  include "ldap::os::${::operatingsystem}"

  if($ssl) {

    if(!$ssl_cert) {
      fail('When ssl is enabled you must define ssl_cert (filename)')
    }

    file { $ldap::params::cacertdir:
      ensure => $ensure ? {
                  present => directory,
                  default => absent
                },
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { "${ldap::params::cacertdir}/${ssl_cert}":
      ensure  => $ensure,
      owner   => 'root',
      group   => $ldap::params::group,
      mode    => '0644',
      source  => "puppet:///files/ldap/${ssl_cert}",
      require => File[$ldap::params::cacertdir],
    }

    # Create certificate hash file
    exec { 'Build cert hash':
      command => "ln -s ${ldap::params::cacertdir}/${ssl_cert} ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::cacertdir}/${ssl_cert}).0",
      unless  => "test -f ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::cacertdir}/${ssl_cert}).0",
      require => File["${ldap::params::cacertdir}/${ssl_cert}"],
      path    => [ "/bin", "/usr/bin", "/sbin", "/usr/sbin" ]
    }
  }

  # require module nsswitch
  if($nsswitch == true) {
    class { 'nsswitch':
      uri         => $uri,
      base        => $base,
      module_type => $ensure ? {
                        'present' => 'ldap',
                        default   => 'none'
                      },
    }
  }

  # require module pam
  if($pam == true) {
    Class ['pam::pamd'] -> Class['ldap']
  }

}

