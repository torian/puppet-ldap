# == Class: ldap::master
#
# Puppet module to manage server configuration for
# **OpenLdap**.
#
#
# === Parameters
#
#  [suffix]
#    
#    **Required**
#
#  [rootpw]
#    
#    **Required**
#
#  [rootdn]
#    
#    *Optional* (defaults to 3)
#
#  [schema_inc]
#    
#    *Optional* (defaults to 30)
#    
#  [modules_inc]
#    
#    *Optional* (defaults to 30)
#
#  [index_inc]
#    
#    *Optional* (defaults to 30)
#    
#  [log_level]
#    
#    *Optional* (defaults to false)
#    
#  [bind_anon]
#    
#    *Optional* (defaults to false)
#    
#  [ssl]
#    
#    *Requires*: ssl_cert parameter
#    *Optional* (defaults to false)
#    
#  [ssl_cert]
#    
#    *Optional* (defaults to false)
#    
#  [ssl_ca]
#    
#    *Optional* (defaults to false)
#    
#  [ssl_cert]
#    
#    *Optional* (defaults to false)
#    
#  [ssl_key]
#    
#    *Optional* (defaults to false)
#    
#  [syncprov]
#    
#    *Optional* (defaults to false)
#    
#  [syncprov_checkpoint]
#    
#    *Optional* (defaults to false)
#    
#  [syncprov_sessionlog]
#    
#    *Optional* (defaults to *'uid'*)
#    
#  [sync_binddn]
#    
#    *Optional* (defaults to *'member'*)
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
#   - Debian: 5.0   / 6.0   /
#   - RHEL    5.2   / 5.4   / 5.5   / 6.1   / 6.2 
#   - OVS:    2.1.1 / 2.1.5 / 2.2.0 / 3.0.2 /
#
#
# === Examples
#
# class { 'ldap':
#	uri  => 'ldap://ldapserver00 ldap://ldapserver01',
#	base => 'dc=suffix',
# }
#
# class { 'ldap':
#	uri  => 'ldap://ldapserver00',
#	base => 'dc=suffix',
#	ssl  => true,
#	ssl_cert => 'ldapserver00.pem'
# }
#
# class { 'ldap':
#	uri        => 'ldap://ldapserver00',
#	base       => 'dc=suffix',
#	ssl        => true,
#	ssl_cert => 'ldapserver00.pem'
#
#	nsswitch   => true,
#	nss_passwd => 'ou=users',
#	nss_shadow => 'ou=users',
#	nss_group  => 'ou=groups',
#
#	pam        => true,
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

class ldap::server::master($suffix, $rootpw,
	$rootdn              = "cn=admin,${suffix}",
	$schema_inc          = [],
	$modules_inc         = [],
	$index_inc           = [],
	$log_level           = '0',
	$bind_anon           = true,
	$ssl                 = false,
	$ssl_url             = false,
	$ssl_ca              = 'ca.pem',
	$ssl_cert            = 'cert.pem',
	$ssl_key             = 'cert.key',
	$syncprov            = false,
	$syncprov_checkpoint = '100 10',
	$syncprov_sessionlog = '100',
	$sync_binddn         = false,
	$enable_motd         = false,
	$ensure              = present) {

	include ldap::params
	
	if($enable_motd) { 
		motd::register { 'ldap::server::master': } 
	}
	
	package { $ldap::params::server_package:
		ensure => $ensure
	}

	service { $ldap::params::service:
		ensure     => $ensure ? {
				present => running,
				absent  => stopped,
				},
		enable     => $ensure ? {
				present => true,
				absent  => false,
				},
		name       => $ldap::params::server_script,
		pattern    => $ldap::params::server_pattern,
		hasstatus  => true,
		hasrestart => true,
		require    => Package[$ldap::params::server_package],
	}
	
	file { $ldap::params::prefix:
		ensure  => $ensure ? {
				present => directory,
				default => absent
				},
		owner   => 'root',
		group   => 'root',
		mode    => 0755,
		require => Package[$ldap::params::server_package],
	}

	file { "${ldap::params::prefix}/${ldap::params::server_config}":
		ensure  => $ensure,
		mode    => 0640,
		owner   => $ldap::params::server_owner,
		group   => $ldap::params::server_group,
		content => template("ldap/${ldap::params::server_config}.erb"),
		notify  => Service[$ldap::params::service],
		require => File[$ldap::params::prefix],
	}

	if($ssl == true) {
		file { "${ssl_prefix}/${ssl_ca}":
			ensure  => $ensure,
			mode    => 0640,
			owner   => $ldap::params::server_owner,
			group   => $ldap::params::server_group,
			source  => "puppet://${mod_prefix}"
		}
	}
}

