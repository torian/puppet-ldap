
class ldap::os::ubuntu {

  case $::operatingsystemrelease {
  
    '12.04': {
      
      file { '/etc/ldap.conf':
        ensure  => link,
        target  => "${ldap::params::prefix}/${ldap::params::config}",
        require => File["${ldap::params::prefix}/${ldap::params::config}"],
      }

    }

    default: {}

  }

}

