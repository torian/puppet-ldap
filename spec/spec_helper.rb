require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))


RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end

@oses = {

  'Debian' => {
    :operatingsystem        => 'Debian',
    :osfamily               => 'Debian',
    :operatingsystemrelease => '7.0',
    :lsbdistid              => 'Debian',
    :lsbdistrelease         => '7.0',
    :architecture           => 'amd64',

    :utils_pkg   => 'ldap-utils',
    :utils_cfg   => '/etc/ldap/ldap.conf',
    :cacertdir   => '/etc/ssl/certs',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'slapd',
    :server_prefix => '/etc/ldap',
    :server_cfg    => '/etc/ldap/slapd.conf',
    :server_owner  => 'openldap',
    :service       => 'slapd',
    :server_group  => 'openldap',
  },

  'Ubuntu' => {
    :operatingsystem        => 'Ubuntu',
    :osfamily               => 'Debian',
    :operatingsystemrelease => '13.04',
    :lsbdistid              => 'Ubuntu',
    :lsbdistrelease         => '13.04',
    :architecture           => 'amd64',

    :utils_pkg   => 'ldap-utils',
    :utils_cfg   => '/etc/ldap/ldap.conf',
    :cacertdir   => '/etc/ssl/certs',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'slapd',
    :server_prefix => '/etc/ldap',
    :server_cfg    => '/etc/ldap/slapd.conf',
    :server_owner  => 'openldap',
    :service       => 'slapd',
    :server_group  => 'openldap',
  },

  'Redhat 5' => {
    :operatingsystem            => 'Redhat',
    :osfamily                   => 'Redhat',
    :operatingsystemrelease     => '5.0',
    :operatingsystemmajrelease  => '5',
    :lsbdistid                  => 'Redhat',
    :lsbdistrelease             => '5.0',
    :architecture               => 'x86_64',

    :utils_pkg   => 'openldap-clients',
    :utils_cfg   => '/etc/openldap/ldap.conf',
    :cacertdir   => '/etc/openldap/cacerts',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'openldap-servers',
    :server_prefix => '/etc/openldap',
    :server_cfg    => '/etc/openldap/slapd.conf',
    :server_owner  => 'ldap',
    :server_group  => 'ldap',
    :service       => 'ldap',
  },

  'Redhat 6' => {
    :operatingsystem            => 'Redhat',
    :osfamily                   => 'Redhat',
    :operatingsystemrelease     => '6.0',
    :operatingsystemmajrelease  => '6',
    :lsbdistid                  => 'Redhat',
    :lsbdistrelease             => '6.0',
    :architecture               => 'x86_64',

    :utils_pkg   => 'openldap-clients',
    :utils_cfg   => '/etc/openldap/ldap.conf',
    :cacertdir   => '/etc/openldap/certs',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'ldap',
    :utils_group => 'ldap',

    :server_pkg    => 'openldap-servers',
    :server_prefix => '/etc/openldap',
    :server_cfg    => '/etc/openldap/slapd.conf',
    :server_owner  => 'openldap',
    :server_group  => 'openldap',
    :service       => 'slapd',
  },

  'CentOS 5' => {
    :operatingsystem            => 'CentOS',
    :osfamily                   => 'Redhat',
    :operatingsystemrelease     => '5.0',
    :operatingsystemmajrelease  => '5',
    :lsbdistid                  => 'CentOS',
    :lsbdistrelease             => '5.0',
    :architecture               => 'x86_64',

    :utils_pkg   => 'openldap-clients',
    :utils_cfg   => '/etc/openldap/ldap.conf',
    :cacertdir   => '/etc/openldap/cacerts',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'openldap-servers',
    :server_prefix => '/etc/openldap',
    :server_cfg    => '/etc/openldap/slapd.conf',
    :server_owner  => 'ldap',
    :server_group  => 'ldap',
    :service       => 'ldap',
  },

  'CentOS 6' => {
    :operatingsystem            => 'CentOS',
    :osfamily                   => 'Redhat',
    :operatingsystemrelease     => '6.0',
    :operatingsystemmajrelease  => '6',
    :lsbdistid                  => 'CentOS',
    :lsbdistrelease             => '6.0',
    :architecture               => 'x86_64',

    :utils_pkg   => 'openldap-clients',
    :utils_cfg   => '/etc/openldap/ldap.conf',
    :cacertdir   => '/etc/openldap/certs',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'openldap-servers',
    :server_prefix => '/etc/openldap',
    :server_cfg    => '/etc/openldap/slapd.conf',
    :server_owner  => 'ldap',
    :server_group  => 'ldap',
    :service       => 'slapd',
  },

  'Scientific Linux 6' => {
    :operatingsystem            => 'Scientific',
    :osfamily                   => 'Redhat',
    :operatingsystemrelease     => '6.0',
    :operatingsystemmajrelease  => '6',
    :lsbdistid                  => 'Scientific',
    :lsbdistrelease             => '6.0',
    :architecture               => 'x86_64',

    :utils_pkg   => 'openldap-clients',
    :utils_cfg   => '/etc/openldap/ldap.conf',
    :cacertdir   => '/etc/openldap/certs',
    :ssl_cert    => 'ldap.pem',
    :utils_owner => 'root',
    :utils_group => 'root',

    :server_pkg    => 'openldap-servers',
    :server_prefix => '/etc/openldap',
    :server_cfg    => '/etc/openldap/slapd.conf',
    :server_owner  => 'ldap',
    :server_group  => 'ldap',
    :service       => 'slapd',
  },

}

