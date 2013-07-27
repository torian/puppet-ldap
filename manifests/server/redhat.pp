
class ldap::server::redhat($ssl) {

  include ldap::params

  file { '/etc/sysconfig/ldap':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ldap/etc/sysconfig/ldap.erb'),
    notify  => Service[$ldap::params::service]
  }

}
