
class ldap::server::slave($suffix, $rootpw,
	$sync_rid,
	$sync_provider,
	$sync_type      = 'refreshOnly',
	$sync_interval  = '00:00:10:00',
	$sync_base      = '',
	$sync_filter    = '(objectClass=*)',
	$sync_attrs     = '*',
	$sync_scope     = 'sub',
	$sync_updatedn,
	$sync_binddn,
	$sync_bindpw,
	$schema_inc     = [],
	$modules_inc    = [],
	$index_inc      = [],
	$log_level      = '0',
	$bind_anon      = true,
	$ssl            = false,
	$ssl_ca         = 'ca.pem',
	$ssl_cert       = 'cert.pem',
	$ssl_key        = 'cert.key',
	$enable_motd    = false,
	$ensure         = 'present') {

	include ldap::params

	if($enable_motd) {
		motd::register { 'ldap::server::slave': }
	}

	package { $ldap::params::server_package:
		ensure => $ensure
	}

	$mod_prefix    = $ldap::params::mod_prefix
	$db_prefix     = $ldap::params::db_prefix
	$module_prefix = $ldap::params::module_prefix
	$schema_prefix = $ldap::params::schema_prefix
	$ssl_prefix    = $ldap::params::ssl_prefix
	$server_run    = $ldap::params::server_run
	$modules_base  = $ldap::params::modules_base
	$schema_base   = $ldap::params::schema_base
	$index_base    = $ldap::params::index_base

	file { $ldap::params::server_config:
		ensure  => $ensure,
		mode    => 0640,
		owner   => $ldap::params::server_owner,
		group   => $ldap::params::server_group,
		content => template("${mod_prefix}/${ldap::params::server_config}.erb"),
		require => Package[$ldap::params::server_package]
	}

	service { $ldap::params::service:
		ensure     => $ensure ? {
						'present' => running,
						'absent'  => stopped,
						},
		enable     => $ensure ? {
						'present' => true,
						'absent'  => false,
						},
		name       => $ldap::params::server_script,
		pattern    => $ldap::params::server_pattern,
		hasstatus  => true,
		hasrestart => true,
		subscribe  => File[$ldap::params::server_config],
		require    => Package[$ldap::params::server_package],
	}
	
}

# vim: ts=4
