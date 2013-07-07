# == Class: ldap
#
# Puppet module to manage client and server configuration for
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
class ldap(
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

  $enable_motd    = false,
  $ensure         = present) {

  include ldap::params

  if($enable_motd) {
    motd::register { 'ldap': }
  }

  package { $ldap::params::package:
    ensure => $ensure,
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

  file { "${ldap::params::prefix}/${ldap::params::config}":
    content => template("ldap/${ldap::params::config}.erb"),
    require => File[$ldap::params::prefix],
  }

  if($ssl) {

    if(!$ssl_cert) {
      fail('When ssl is enabled you must define ssl_cert (filename)')
    }

    file { "${ldap::params::cacertdir}/${ssl_cert}":
      ensure => $ensure,
      owner  => 'root',
      group  => $ldap::params::group,
      mode   => '0644',
      source => "puppet:///files/ldap/${ssl_cert}"
    }

    # Create certificate hash file
    exec { 'Build cert hash':
      command => "ln -s ${ldap::params::cacertdir}/${ssl_cert} ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::cacertdir}/${ssl_cert}).0",
      unless  => "test -f ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::cacertdir}/${ssl_cert}).0",
      require => File["${ldap::params::cacertdir}/${ssl_cert}"]
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

