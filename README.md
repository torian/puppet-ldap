Puppet OpenLDAP Module
======================

Introduction
------------

Puppet module to manage client and server configuration for
**OpenLdap**.

## Usage ##

### Ldap client ###

Ldap client configuration at its simplest:


    class { 'ldap::client':
    	uri  => 'ldap://ldapserver00 ldap://ldapserver01',
    	base => 'dc=foo,dc=bar'
    }


Enable TLS/SSL:

Note that *ssl_cert* should be the CA's certificate file, and
it should be located under *puppet:///files/ldap/*.

    class { 'ldap::client':
    	uri      => 'ldap://ldapserver00 ldap://ldapserver01',
    	base     => 'dc=foo,dc=bar',
    	ssl      => true,
    	ssl_cert => 'ldapserver.pem'
    }

Enable nsswitch and pam configuration (requires both modules):

    class { 'ldap::client':
      uri      => 'ldap://ldapserver00 ldap://ldapserver01',
      base     => 'dc=foo,dc=bar',
      ssl      => true
      ssl_cert => 'ldapserver.pem',

      nsswitch   => true,
      nss_passwd => 'ou=users',
      nss_shadow => 'ou=users',
      nss_group  => 'ou=groups',

      pam        => true,
    }

### OpenLdap Server ###

#### Master server ####

OpenLdap server as simple as it is:

    class { 'ldap::server::master':
      suffix      => 'dc=foo,dc=bar',
      rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
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

With TLS/SSL enabled:

    class { 'ldap::server::master':
      suffix      => 'dc=foo,dc=bar',
      rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
      ssl         => true,
      ssl_ca      => 'ca.pem',
      ssl_cert    => 'master-ldap.pem',
      ssl_key     => 'master-ldap.key',
    }

*NOTE*: SSL certificates should reside in you puppet master
file repository 'puppet:///files/ldap/'

#### Slave server ####

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

Ldap client / server configuration tested on:

 * Debian:   5     / 6   / 7
 * Redhat:   5.x   / 6.x
 * CentOS:   5.x   / 6.x
 * OpenSuSe: 12.x
 * SLES:     11.x

Should also work on (I'd appreciate reports on this distros and versions):

 * Ubuntu
 * Fedora
 * Scientific Linux 6

Requirements
------------

 * If nsswitch is enabled (nsswitch => true) you'll need
   [puppet-nsswitch](https://github.com/torian/puppet-nsswitch.git)
 * If pam is enabled (pam => true) you'll need
   [puppet-pam](https://github.com/torian/puppet-pam.git)
 * If enable_motd is enabled (enable_motd => true) you'll need
   [puppet-motd](https://github.com/torian/puppet-motd.git)

TODO
----

 * ldap::server::master and ldap::server::slave do not copy
   the schemas specified by *index_inc*. It just adds an include to slapd
 * Need support for extending ACLs

CopyLeft
---------

Copyleft (C) 2012 Emiliano Castagnari <ecastag@gmail.com> (a.k.a. Torian)

