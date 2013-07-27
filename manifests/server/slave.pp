# == Class: ldap::server::slave
#
# Puppet module to manage server configuration for
# **OpenLdap**.
#
#
# === Parameters
#
#  [suffix]
#    Ldap tree base
#    **Required**
#
#  [sync_rid]
#    Replica ID (numeric)
#    **Required**
#
#  [sync_provider]
#    Provider URI (ldap[s]://master.ldap)
#    **Required**
#
#  [sync_updatedn]
#    DN permitted to update the replica (should not be the same as rootdn)
#    **Required**
#
#  [sync_binddn]
#    DN that will perform sync (connect to master and fetch data)
#    **Required**
#
#  [sync_bindpw]
#    Credentials fr sync_binddn.
#    **NOTE** This should be in clear text
#    **Required**
#
#  [rootpw]
#    Password for root DN (encrypted as in 'slappasswd -h "{SHA}" -s example')
#    **Required**
#
#  [rootdn]
#    Root DN.
#    *Optional* (defaults to 'cn=admin,${suffix}')
#
#  [schema_inc]
#    Array of additional schemas that will be included.
#    Some schemas are already included (ldap::params::schemas_base)
#    'core', 'cosine', 'nis', 'inetorgperson'
#    *Optional* (defaults to [])
#
#  [modules_inc]
#    Array of modules that you want to load. Depends on the ditro being used.
#    Some modules are already included through ldap::params::modules_base
#    *Optional* (defaults to [])
#
#  [index_inc]
#    Array of indexes to be generated.
#    Some indexes are already generated through ldap::params::index_base
#         'index objectclass  eq',
#         'index entryCSN     eq',
#         'index entryUUID    eq',
#         'index uidNumber    eq',
#         'index gidNumber    eq',
#         'index cn           pres,sub,eq',
#         'index sn           pres,sub,eq',
#         'index uid          pres,sub,eq',
#         'index displayName  pres,sub,eq',
#    *Optional* (defaults to [])
#
#  [cnconfig_attrs]
#    Default cn=config attributes that needs to be changed
#    upon runs
#    *Optional* (defaults to {})
#
#  [log_level]
#    OpenLdap server log level.
#    *Optional* (defaults to 0)
#
#  [bind_anon]
#    Allow anonymous binding
#    *Optional* (defaults to true)
#
#  [ssl]
#    Enable SSL/TLS.
#    *Requires*: ssl_{cert,ca,key} parameter
#    *Optional* (defaults to false)
#
#  [ssl_cert]
#    Public certificate filename (should be located at puppet:///files/ldap)
#    *Requires*: ssl => true
#    *Optional* (defaults to false)
#
#  [ssl_ca]
#    CA certificate filename (should be located at puppet:///files/ldap)
#    *Requires*: ssl => true
#    *Optional* (defaults to false)
#
#  [ssl_key]
#    Private certificate filename (should be located at puppet:///files/ldap)
#    *Requires*: ssl => true
#    *Optional* (defaults to false)
#
#  [sync_type]
#    Content synchronizatin protocol type (refreshOnly / refreshAndPersist)
#    *Optional* (defaults to refreshOnly)
#
#  [sync_interval]
#    Synchronization interval.
#    *Optional* (defaults to 00:00:10:00)
#
#  [sync_base]
#    Base for replication
#    *Optional* (defaults to '')
#
#  [sync_filter]
#    Filter to use when fetching content.
#    *Optional* (defaults to '(ObjectClass=*)')
#
#  [sync_attrs]
#    Attributes to synchronize.
#    *Optional* (defaults to '*')
#
#  [sync_scope]
#    Objects search depth.
#    *Optional* (defaults to 'sub')
#
#  [enable_motd]
#    Use motd to report the usage of this module.
#    *Requires*: https://github.com/torian/puppet-motd.git
#    *Optional* (defaults to false)
#
#  [ensure]
#    *Optional* (defaults to 'present')
#
#
# == Tested/Works on:
#   - Debian:    5.0   / 6.0   / 7.x
#   - RHEL       5.x   / 6.x
#   - CentOS     5.x   / 6.x
#   - OpenSuse:  11.x  / 12.x
#   - OVS:       2.1.1 / 2.1.5 / 2.2.0 / 3.0.2
#
#
# === Examples
#
# class { 'ldap::server::master':
#  suffix      => 'dc=foo,dc=bar',
#  rootpw      => '{SHA}iEPX+SQWIR3p67lj/0zigSWTKHg=',
#  syncprov    => true,
#  sync_binddn => 'cn=sync,dc=foo,dc=bar',
#  modules_inc => [ 'syncprov' ],
#  schema_inc  => [ 'gosa/samba3', 'gosa/gosystem' ],
#  index_inc   => [
#  'index memberUid            eq',
#    'index mail                 eq',
#    'index givenName            eq,subinitial',
#    ],
#  }
#
# === Authors
#
# Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
# === Copyleft
#
# Copyleft (C) 2012 Emiliano Castagnari ecastag@gmail.com (a.k.a. Torian)
#
#
class ldap::server::slave(
  $suffix,
  $sync_rid,
  $sync_provider,
  $sync_updatedn,
  $sync_binddn,
  $sync_bindpw,
  $rootpw,
  $rootdn         = "cn=admin,${suffix}",
  $schema_inc     = [],
  $modules_inc    = [],
  $index_inc      = [],
  $cnconfig_attrs = {},
  $log_level      = '0',
  $bind_anon      = true,
  $ssl            = false,
  $ssl_ca         = false,
  $ssl_cert       = false,
  $ssl_key        = false,
  $sync_type      = 'refreshOnly',
  $sync_interval  = '00:00:10:00',
  $sync_base      = '',
  $sync_filter    = '(objectClass=*)',
  $sync_attrs     = '*',
  $sync_scope     = 'sub',
  $enable_motd    = false,
  $ensure         = 'present') {

  require ldap

  if($enable_motd) {
    motd::register { 'ldap::server::slave': }
  }

  package { $ldap::params::server_package:
    ensure => $ensure
  }

  service { $ldap::params::service:
    ensure     => running,
    enable     => true,
    pattern    => $ldap::params::server_pattern,
    require    => [
      Package[$ldap::params::server_package],
      File["${ldap::params::prefix}/${ldap::params::server_config}"],
      ]
  }


  if (!empty($cnconfig_attrs)) {

    $cnconfig_default_attrs = $ldap::params::cnconfig_default_attrs

    file {"${ldap::params::prefix}/slapd.d/cn=config-update.ldif":
      ensure  => present,
      content => template("ldap/${ldap::params::prefix}/slapd.d/cn=config-update.ldif.erb"),
      require => Service[$ldap::params::service],
    }

    exec{"/usr/bin/ldapmodify -Y EXTERNAL -H ldapi:/// -f ${ldap::params::prefix}/slapd.d/cn=config-update.ldif && rm -f ${ldap::params::prefix}/slapd.d/cn=config-update.ldif":
      require => File["${ldap::params::prefix}/slapd.d/cn=config-update.ldif"],
    }

  }

  File {
    mode    => '0640',
    owner   => $ldap::params::server_owner,
    group   => $ldap::params::server_group,
  }

  file { "${ldap::params::prefix}/${ldap::params::server_config}":
    ensure  => $ensure,
    content => template("ldap/${ldap::params::prefix}/${ldap::params::server_config}.erb"),
    notify  => Service[$ldap::params::service],
    require => $ssl ? {
      false => [
        Package[$ldap::params::server_package],
        ],
      true  => [
        Package[$ldap::params::server_package],
        File['ssl_ca'],
        File['ssl_cert'],
        File['ssl_key'],
        ]
      }
  }

  $msg_prefix = 'SSL enabled. You must specify'
  $msg_suffix = '(filename). It should be located at puppet:///files/ldap'

  if($ssl) {

    if(!$ssl_ca) { fail("${msg_prefix} ssl_ca ${msg_suffix}") }
    file { 'ssl_ca':
      ensure  => present,
      source  => "puppet:///files/ldap/${ssl_ca}",
      path    => "${ldap::params::ssl_prefix}/${ssl_ca}",
      mode    => '0644',
    }

    if(!$ssl_cert) { fail("${msg_prefix} ssl_cert ${msg_suffix}") }
    file { 'ssl_cert':
      ensure  => present,
      source  => "puppet:///files/ldap/${ssl_cert}",
      path    => "${ldap::params::ssl_prefix}/${ssl_cert}",
      mode    => '0644',
    }

    if(!$ssl_key) { fail("${msg_prefix} ssl_key ${msg_suffix}") }
    file { 'ssl_key':
      ensure  => present,
      source  => "puppet:///files/ldap/${ssl_key}",
      path    => "${ldap::params::ssl_prefix}/${ssl_key}",
    }

    # Create certificate hash file
    exec { 'Server certificate hash':
      command  => "ln -s ${ldap::params::ssl_prefix}/${ssl_cert} ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::ssl_prefix}/${ssl_cert}).0",
      unless   => "test -f ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::ssl_prefix}/${ssl_cert}).0",
      provider => $::puppetversion ? {
                    /^3./   => 'shell',
                    /^2.7/  => 'shell',
                    /^2.6/  => 'posix',
                    default => 'posix'
                  },
      require  => File['ssl_cert'],
      path    => [ "/bin", "/usr/bin", "/sbin", "/usr/sbin" ]
    }

  }

  # Additional configurations (for rc scripts)
  case $::osfamily {
    
    'Debian' : {
      class { 'ldap::server::debian': ssl => $ssl }
    }

    'RedHat' : {
      class { 'ldap::server::redhat': ssl => $ssl }
    }

    #'Suse' : {
    #  class { 'ldap::server::suse':   ssl => $ssl }
    #}

  }

}

# vim: ts=4
