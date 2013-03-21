
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
	$ensure              = present) {

	include ldap::params

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

