
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

  include ldap::params

  if($enable_motd) {
    motd::register { 'ldap::server::slave': }
  }

  package { $ldap::params::server_package:
    ensure => $ensure
  }

  service { $ldap::params::service:
    ensure     => running,
    enable     => true,
    name       => $ldap::params::server_script,
    pattern    => $ldap::params::server_pattern,
    require    => [
      Package[$ldap::params::server_package],
      File["${ldap::params::prefix}/${ldap::params::server_config}"],
      ]
  }
 
  File {
    mode    => 0640,
    owner   => $ldap::params::server_owner,
    group   => $ldap::params::server_group,
  }
  
  file { "${ldap::params::prefix}/${ldap::params::server_config}":
    ensure  => $ensure,
    content => template("ldap/${ldap::params::server_config}.erb"),
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
    }

    if(!$ssl_cert) { fail("${msg_prefix} ssl_cert ${msg_suffix}") }
    file { 'ssl_cert':
      ensure  => present,
      source  => "puppet:///files/ldap/${ssl_cert}",
      path    => "${ldap::params::ssl_prefix}/${ssl_cert}",
    }

    if(!$ssl_key) { fail("${msg_prefix} ssl_key ${msg_suffix}") }
    file { 'ssl_key':
      ensure  => present,
      source  => "puppet:///files/ldap/${ssl_key}",
      path    => "${ldap::params::ssl_prefix}/${ssl_key}",
    }

    # Create certificate hash file
    exec { "Server certificate hash":
      command => "ln -s ${ldap::params::ssl_prefix}/${ssl_cert} ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::ssl_prefix}/${ssl_cert}).0",
      unless  => "test -f ${ldap::params::cacertdir}/$(openssl x509 -noout -hash -in ${ldap::params::ssl_prefix}/${ssl_cert}).0",
      require => File['ssl_cert']
    }
    
  }

}

# vim: ts=4
