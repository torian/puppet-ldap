
class ldap::params {

	case $operatingsystem {
	
		debian: {

			$mod_prefix = 'ldap/debian'

			$package = [ 'ldap-utils' ]
			
			$prefix  = '/etc/ldap'
			$owner   = 'root'
			$group   = 'root'
			$config  = "${prefix}/ldap.conf"

			$server_config   = "${prefix}/slapd.conf"
			$service         = 'slapd'
			$server_script   = 'slapd'
			$server_pattern  = 'slapd'
		}

		# For redhat ovs oel
		default: {
			
			$mod_prefix = 'ldap/redhat'

			$package = [ 'openldap', 'openldap-clients' ]


			$prefix  = '/etc/openldap'
			$owner   = 'root'
			$group   = 'root'
			$config  = "${prefix}/ldap.conf"

			$server_package  = [ 'openldap-servers' ]
			$server_config   = "${prefix}/slapd.conf"
			$service         = 'slapd'
			$server_script   = 'slapd'
			$server_pattern  = 'slapd'
			$server_owner    = 'ldap'
			$server_group    = 'ldap'

			$schema_prefix = "${prefix}/schema"
			$db_prefix     = '/var/lib/ldap'
			if($architecture =~ /^x86_64/) {
				$module_prefix = '/usr/lib64/openldap'
			} else {
				$module_prefix = '/usr/lib/openldap'
			}
			$ssl_prefix    = '/etc/openssl/ssl'
			$server_run    = '/var/run/openldap'
			$schema_base   = [ 'core', 'cosine', 'nis', 'inetorgperson', 'authldap' ]
			$modules_base  = [ 'back_bdb' ]
			$index_base    = [
				'index objectclass  eq',
				'index entryCSN     eq',
				'index entryUUID    eq',
				'index uidNumber    eq',
				'index gidNumber    eq',
				'index cn           pres,sub,eq',
				'index sn           pres,sub,eq',
				'index uid          pres,sub,eq',
				'index displayName  pres,sub,eq',
				]
		}
	}
}
