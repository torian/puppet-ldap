
class ldap::server::debian($ssl) {

  include ldap::params

  file { '/etc/default/slapd':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ldap/etc/default/slapd.erb'),
    notify  => Service[$ldap::params::service]
  }

}
