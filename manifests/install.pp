
class ldap::install {
	
	package { $ldap::params::package:
		ensure => present,
	}

}
