
class ldap::server::redhat ($ssl = undef) {
  include ldap::params

  if ($ssl == undef) {
    fail('${ldap::server::redhat::ssl} must be set.')
  }

  file { '/etc/sysconfig/ldap':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ldap/sysconfig/ldap.erb'),
    notify  => Service[$ldap::params::service]
  }

}
