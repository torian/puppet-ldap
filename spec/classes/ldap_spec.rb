
require 'spec_helper'

describe 'ldap' do

	opts = {
		'Debian' => {
			:arch      => 'amd64',
			:package   => 'ldap-utils',
			:ldapcfg   => '/etc/ldap/ldap.conf',
			:cacertdir => '/etc/ssl/certs',
			:ssl_cert  => 'ldap.pem',
		},
		'Redhat' => {
			:arch      => 'x86_64',
			:package   => 'openldap-clients',
			:ldapcfg   => '/etc/openldap/ldap.conf',
			:cacertdir => '/etc/openldap/cacerts',
			:ssl_cert  => 'ldap.pem',
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

			context 'SSL Enabled with certificate filename' do
				let(:params) { {
					:uri      => 'ldap://ldap.example.com',
					:base     => 'dc=suffix',
					:ssl      => true,
					:ssl_cert => opts[os][:ssl_cert],
				} }
				it { should contain_file("#{opts[os][:cacertdir]}/#{opts[os][:ssl_cert]}") } 
			end

			context 'SSL Enabled without certificate' do
				let(:params) { {
					:uri      => 'ldap://ldap.example.com',
					:base     => 'dc=suffix',
					:ssl      => true,
				} }
				it { expect {
					should contain_file("#{opts[os][:cacertdir]}/#{opts[os][:ssl_cert]}") 
					}.to raise_error(Puppet::Error, /^When ssl is.*/)
				}
			end
		end
	end
end
