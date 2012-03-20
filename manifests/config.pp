# = Class: ldap::config
#
# This class sets the configuration based on params.pp
# and instantiation of ldap class
#
# == Parameters:
#
# == Actions:
#   Creates contents of /etc/<prefix>/ldap.conf
#   If ldap class is called with $nsswitch = true
#    nss_ldap attributes are set
#   If ldap class is called with $pam = true
#    pam_ldap attributes are set
#
# == Requires:
#   - Class nsswitch
#   - Class pam
#
# == Sample Usage:
# 
#   This class is called by its parent class, ldap.
#

class ldap::config {

	File {
		ensure  => $ensure,
		mode    => 0644,
		owner   => $ldap::params::owner,
		group   => $ldap::params::group,
	}

	file { $ldap::params::config:
		content => template("${ldap::params::mod_prefix}${ldap::params::config}.erb"),
	}
	
	case $operatingsystem {

		debian:  {}
		# RHEL and the likes have /etc/ldap.conf
		default: {
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

