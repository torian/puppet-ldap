
class ldap::params {

	case $operatingsystem {
	
		Debian: {

			$package = [ 'ldap-utils' ]
			
			$prefix  = '/etc/ldap'
			$owner   = 'root'
			$group   = 'root'
			$config  = 'ldap.conf'

			$service         = 'slapd'
			$server_script   = 'slapd'
			$server_pattern  = 'slapd'
			$server_package  = 'slapd'
			$server_config   = 'slapd.conf'
			$server_owner    = 'openldap'
			$server_group    = 'openldap'
			$db_prefix       = '/var/lib/ldap'
			$ssl_prefix      = '/etc/openssl/ssl'
			$server_run      = '/var/run/openldap'

			case $architecture {
				amd64: { 
					$module_prefix = '/usr/lib64/ldap' 
				}

				/^i?[346]86/: {
					$module_prefix = '/usr/lib32/ldap'
				}

				default: {
					fail("Architecture not supported by this module")
				}
			}

			$modules_base  = [ 'back_bdb' ]
			
			$schema_prefix   = "${prefix}/schema"
			$schema_base     = [ 'core', 'cosine', 'nis', 'inetorgperson', ]
			$index_base      = [
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

		# For redhat ovs oel
		Redhat: {
			
			$package = [ 'openldap', 'openldap-clients' ]
			
			$prefix  = '/etc/openldap'
			$owner   = 'root'
			$group   = 'root'
			$config  = 'ldap.conf'

			$server_package  = [ 'openldap-servers' ]
			$server_config   = 'slapd.conf'
			$service         = 'slapd'
			$server_script   = 'slapd'
			$server_pattern  = 'slapd'
			$server_owner    = 'ldap'
			$server_group    = 'ldap'

			$schema_prefix   = "${prefix}/schema"
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

		default:  {
			fail("Operating system not supported")
		}
	}
}
