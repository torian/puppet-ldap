
require 'spec_helper'

oses = @oses

describe 'ldap::client' do

	oses.keys.each do |os|

		describe "Running on #{os}" do

			let(:facts) { {
				:osfamily                  => oses[os][:osfamily],
				:operatingsystem           => oses[os][:operatingsystem],
				:operatingsystemmajrelease => oses[os][:operatingsystemmajrelease],
				:architecture              => oses[os][:architecture],
			} }

			let(:params) { { 
				:uri  => 'ldap://ldap.example.com',
				:base => 'dc=suffix',
			} }
      
			it { should include_class('ldap::params') }
			it { should contain_file(oses[os][:utils_cfg]) }

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
					:ssl_cert => oses[os][:ssl_cert],
				} }
				it { should contain_file("#{oses[os][:cacertdir]}/#{oses[os][:ssl_cert]}") } 
			end

			context 'SSL Enabled without certificate' do
				let(:params) { {
					:uri      => 'ldap://ldap.example.com',
					:base     => 'dc=suffix',
					:ssl      => true,
				} }
				it { expect {
					should contain_file("#{oses[os][:cacertdir]}/#{oses[os][:ssl_cert]}") 
					}.to raise_error(Puppet::Error, /^When ssl is.*/)
				}

			end

		end

	end

end
