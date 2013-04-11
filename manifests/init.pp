# = Class: ldap
#
# The main class handles ldap client configuration and
# nss_ldap and pam_ldap options.
#
# Additional parametrized classes:
#  ldap::server::master
#  ldap::server::slave
#
# == Parameters:
# 
# Required parameters:
#  $uri::            ldap uri in the form of 'ldap:://'
#  $base::           base for search
#
# Optional parameters (otherwise noted, defaults to false):
#  $version::        LDAP protocol version tu use. Defaults to '3'
#  $ensure::         Enables or disables ldap configuration. Defaults to 'present'
#                    (valid options are present|absent)
#  $ssl::            if set to true, enables client to
#                     connect using SSL
#  $ssl_cert::       filname for the remote server certificate
#
#  $nsswitch::       if set to true, configures nss_ldap options 
#  $nss_passwd::     branch on which users reside. base is appended
#  $nss_shadow::     branch on which users reside. base is appended
#  $nss_group::      branch on which groups reside. base is appended
#
#  $pam::            if set to true, configures pam_ldap options
#  $pam_att_login::  Attribute for user's login. Defaults to 'uid'
#  $pam_att_member:: Defaults to 'member'
#  $pam_passwd::     Password change protocol. Defaults to 'md5'
#  $pam_filter::     Filter for user information. Defaults to 'objectClass=posixAccount'
#
# == Actions:
#  Creation and management of ldap.conf
#
# == Requires:
#   - Class nsswitch
#   - Class pam
#
# == Tested/Works on:
#   - Debian: 5.0   / 6.0   /
#   - RHEL    5.2   / 5.4   / 5.5   / 6.1   / 6.2 
#   - OVS:    2.1.1 / 2.1.5 / 2.2.0 / 3.0.2 /
#
# == Sample Usage:
# 
# class { 'ldap':
#	uri  => 'ldap://ldapserver00 ldap://ldapserver01',
#	base => 'dc=suffix',
# }
#
# class { 'ldap':
#	uri  => 'ldap://ldapserver00 ldap://ldapserver01',
#	base => 'dc=suffix',
#	ssl  => true,
#	ssl_cert => 'ldapserver00.pem'
# }
#
# class { 'ldap':
#	uri        => 'ldap://ldapserver00 ldap://ldapserver01',
#	base       => 'dc=suffix',
#	ssl        => false,
#
#	nsswitch   => true,
#	nss_passwd => 'ou=users',
#	nss_shadow => 'ou=users',
#	nss_group  => 'ou=groups',
#
#	pam        => true,
# }
#
class ldap($uri, $base,
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
		mode    => 0644,
		owner   => $ldap::params::owner,
		group   => $ldap::params::group,
	}

	file { "${ldap::params::prefix}/${ldap::params::config}":
		content => template("ldap/${ldap::params::config}.erb"),
	}
	
	case $operatingsystem {

		Debian:  {}
		# RHEL and the likes have /etc/ldap.conf
		/Redhat|OEL/: {
			file { '/etc/ldap.conf':
				ensure  => $ensure ? {
							'present' => symlink,
							default   => absent
						},
				target  => $ldap::params::config,
				require => File[$ldap::params::config],
			}
		}
	}

	if($ssl) {
		if(!$ssl_cert) {
			fail("When ssl is enabled you must define ssl_cert (filename)")
		}
		
		# Set the certificate name from the uri.
		#$cert_name = regsubst($uri, '/^([a-zA-Z0-9_-]+)(\..*)$/', '\1')
		
		file { "${ldap::params::cacertdir}/${ssl_cert}":
			ensure => $ensure,
			owner  => 'root',
			group  => 'root',
			mode   => 0640,
			source => "puppet://ldap/${ssl_cert}"
		}
		
		# Create certificate hash file
		exec { "Build cert hash":
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
		class { 'pam':
			module_type => $ensure ? {
					'present' => 'ldap',
					default   => 'none'
				},
		}
	}
}

