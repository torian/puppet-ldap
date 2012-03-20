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
#	ssl  => false,
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
	$version  = '3',
	$ensure   = 'present',
	$ssl      = false,
	$ssl_cert = false,
	
	# nsswitch options (requires nsswitch module) - disabled by default
	$nsswitch   = false,
	$nss_passwd = false,
	$nss_group  = false,
	$nss_shadow = false,
	
	# pam options (requires pam module) - disabled by default
	$pam            = false,
	$pam_att_login  = 'uid',
	$pam_att_member = 'member',
	$pam_passwd     = 'md5',
	$pam_filter     = 'objectClass=posixAccount') {

	include ldap::params
	include ldap::install
	include ldap::config
}

