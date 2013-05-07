  
require 'spec_helper'

describe 'ldap::server::master' do

  oses = {

    'Debian' => {
      :operatingsystem        => 'Debian',
      :osfamily               => 'Debian',
      :operatingsystemrelease => '7.0',
      :lsbdistid              => 'Debian',
      :lsbdistrelease         => '7.0',
      :architecture           => 'x86_64',

			:package      => 'slapd',
			:prefix       => '/etc/ldap',
			:cfg          => '/etc/ldap/slapd.conf',
			:service      => 'slapd',
			:server_owner => 'openldap',
			:server_group => 'openldap',
    },

    'Redhat' => {
      :operatingsystem        => 'Redhat',
      :osfamily               => 'Redhat',
      :operatingsystemrelease => '5.0',
      :lsbdistid              => 'Redhat',
      :lsbdistrelease         => '5.0',
      :architecture           => 'x86_64',

			:package   => 'openldap-servers',
			:prefix    => '/etc/openldap',
			:cfg       => '/etc/openldap/slapd.conf',
			:service   => 'slapd',
			:server_owner => 'openldap',
			:server_group => 'openldap',
    }

  }
  
  oses.keys.each do |os|
 
		let(:facts) { { 
      :operatingsystem => oses[os][:operatingsystem],
      :architecture    => oses[os][:architecture],
    } }
		
		describe "Running on #{os}" do

      let(:params) { { 
        :suffix => 'dc=example,dc=com',
        :rootpw => 'asdqw',
      } }
    
			it { should include_class('ldap::params') }
			it { should contain_service(oses[os][:service]) }
			it { should contain_package(oses[os][:package]) }
			it { should contain_file(oses[os][:cfg]) }

			context 'Motd disabled (default)' do
				it { should_not contain_motd__register('ldap::server::master') }
			end
      
			context 'Motd enabled' do
				let(:params) { {
					:suffix => 'dc=example,dc=com',
					:rootpw => 'asdqw',
					:enable_motd => true 
				} }
				it { should contain_motd__register('ldap::server::master') }
			end
		end
	end
	
	describe "Running on unsupported OS" do
		let(:facts) { { :operatingsystem => 'solaris' } }
		let(:params) { { 
			:suffix => 'dc=example,dc=com',
			:rootpw => 'asdqw',
		} }
		it {
			expect {
				should include_class('ldap::params')
			}.to raise_error(Puppet::Error, /^Operating system.*/)
		}
	end

end
