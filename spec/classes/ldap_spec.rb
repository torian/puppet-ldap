
require 'spec_helper'

describe 'ldap' do

	opts = {
		'Debian' => {
			:arch    => 'amd64',
			:package => 'ldap-utils',
			:ldapcfg => '/etc/ldap/ldap.conf',
		},
		'Redhat' => {
			:arch    => 'x86_64',
			:package => 'openldap-clients',
			:ldapcfg => '/etc/openldap/ldap.conf',
		}
	} 
	
	opts.keys.each do |os|
		describe "Running on #{os}" do
			let(:facts) { {
				:operatingsystem => os,
				:architecture    => opts[os][:arch],
			} }
			let(:params) { { 
				:uri  => 'ldap://ldap.example.com',
				:base => 'dc=suffix',
			} }
			it { should include_class('ldap::params') }
			it { should contain_package(opts[os][:package]) }
			it { should contain_file(opts[os][:ldapcfg]) }

			context 'Motd disabled (default)' do
				it { should_not contain_motd__register('ldap') }
			end
			context 'Motd enabled' do
				let(:params) { {
					:uri  => 'ldap://ldap.example.com',
					:base => 'dc=suffix',
					:enable_motd => true 
				} }
				it { should contain_motd__register('ldap') }
			end
		end
	end
end
