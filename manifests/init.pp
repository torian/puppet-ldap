# == Class: ldap
#
# Puppet module to manage client and server configuration for
# **OpenLdap**.
#
#
# === Parameters
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
# }
#
# class { 'ldap':
#   ensure => present,
# }
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
class ldap($ensure = present) {

    include stdlib
    include ldap::params

    package { $ldap::params::package :
      ensure => $ensure,
    }

}

