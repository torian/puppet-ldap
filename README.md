Puppet OpenLDAP Module
======================

Introduction
------------


Examples
--------

Ldap client configuration at its simplest:

	class { 'ldap':
		uri  => 'ldap://ldapserver00 ldap://ldapserver01',
		base => 'dc=foo,dc=bar'
	}

Enable TLS/SSL:

	class { 'ldap':
		uri  => 'ldap://ldapserver00 ldap://ldapserver01',
		base => 'dc=foo,dc=bar',
		ssl  => true
	}

Enable nsswitch and pam configuration (requires both modules):

	class { 'ldap':
		uri  => 'ldap://ldapserver00 ldap://ldapserver01',
		base => 'dc=foo,dc=bar',
		ssl  => true

		nsswitch   => true,
		nss_passwd => 'ou=users',
		nss_shadow => 'ou=users',
		nss_group  => 'ou=groups',

		pam        => true,
	}

Configure an OpenLdap master with syncrepl enabled:

	class { 'ldap::server::master':
		suffix      => 'dc=foo,dc=bar',
		rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
		syncprov    => true,
		sync_binddn => 'cn=sync,dc=foo,dc=bar',
		modules_inc => [ 'syncprov' ],
		schema_inc  => [ 'gosa/samba3', 'gosa/gosystem' ],
		index_inc   => [
			'index memberUid            eq',
			'index mail                 eq',
			'index givenName            eq,subinitial',
			],
	}

Configure an OpenLdap slave:

	class { 'ldap::server::slave':
		suffix        => 'dc=foo,dc=bar',
		rootpw        => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
		sync_rid      => '1234',
		sync_provider => 'ldap://ldapmaster'
		sync_updatedn => 'cn=admin,dc=foo,dc=bar',
		sync_binddn   => 'cn=sync,dc=foo,dc=bar',
		sync_bindpw   => 'super_secret',
		schema_inc    => [ 'gosa/samba3', 'gosa/gosystem' ],
		index_inc     => [
			'index memberUid            eq',
			'index mail                 eq',
			'index givenName            eq,subinitial',
			],
	}

Notes
-----

 * Ldap client config tested / works on:
   - Debian: 5.0   / 6.0   
   - RHEL    5.2   / 5.4   / 5.5   / 6.1   / 6.2 
   - OVS:    2.1.1 / 2.1.5 / 2.2.0 / 3.0.2 
 * If nsswitch or pam modules are enabled (i.e. nsswitch => true) you need my nsswitch or pam module (or both)

Issues
------

 * Should do some more testing on RHEL 6.x to be able to use sssd (although works with nslcd)

TODO
----

 * Make sure SSL configuration works as expected
 * Document a little bit more

CopyLeft
---------

Copyleft (C) 2012 Emiliano Castagnari <ecastag@gmail.com> (a.k.a. Torian)

