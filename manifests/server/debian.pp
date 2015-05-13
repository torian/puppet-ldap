
class ldap::server::debian ($ssl = undef) {
  include ldap::params

  if ($ssl == undef) {
    fail('${ldap::server::debian::ssl} must be set.')
  }

  file { '/etc/default/slapd':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ldap/default/slapd.erb'),
    notify  => Service[$ldap::params::service]
  }

}
