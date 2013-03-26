
require 'spec_helper'

describe 'ldap::server::master' do

	opts = {
		'Debian' => {
			:package => 'slapd',
			:prefix  => '/etc/ldap',
			:cfg     => '/etc/ldap/slapd.conf',
			:service => 'slapd',
			:server_owner => 'openldap',
			:server_group => 'openldap',
		},

		'Redhat' => {
			:package => 'openldap-servers',
			:prefix  => '/etc/openldap',
			:cfg     => '/etc/openldap/slapd.conf',
			:service => 'slapd',
			:server_owner => 'openldap',
			:server_group => 'openldap',
		},
	}

	opts.keys.each do |os|
		let(:facts) { { :operatingsystem => os } }
		let(:params) { { 
			:suffix => 'dc=example,dc=com',
			:rootpw => 'asdqw',
		} }
		describe "Running on #{os}" do
			it { should include_class('ldap::params') }
			it { should contain_package(opts[os][:package]) }
			it { should contain_service(opts[os][:service]) }
			it { should contain_file(opts[os][:prefix]) }
			it { should contain_file(opts[os][:cfg]) }

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
