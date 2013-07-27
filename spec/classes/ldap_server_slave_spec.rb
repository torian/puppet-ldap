  
require 'spec_helper'

oses = @oses

describe 'ldap::server::slave' do

  oses.keys.each do |os|
	
		describe "Running on #{os}" do

		  let(:facts) { { 
				:osfamily                  => oses[os][:osfamily],
				:operatingsystem           => oses[os][:operatingsystem],
				:operatingsystemmajrelease => oses[os][:operatingsystemmajrelease],
				:architecture              => oses[os][:architecture],
      } }
	
      let(:params) { { 
        :suffix => 'dc=example,dc=com',
        :rootpw => 'rootpwsuperpass',
        :sync_rid => 1,
        :sync_provider => 'ldap://master.ldap',
        :sync_updatedn => 'cn=admin,dc=example,dc=com',
        :sync_binddn   => 'cn=sync,dc=example,dc=com',
        :sync_bindpw   => 'password',
      } }
    
			it { should include_class('ldap') }
			it { should contain_package(oses[os][:server_pkg]) }
			it { should contain_service(oses[os][:service]) }
			it { should contain_file(oses[os][:server_cfg]) }

			context 'Motd disabled (default)' do
        let(:params) { { 
          :suffix => 'dc=example,dc=com',
          :rootpw => 'rootpwsuperpass',
          :sync_rid => 1,
          :sync_provider => 'ldap://master.ldap',
          :sync_updatedn => 'cn=admin,dc=example,dc=com',
          :sync_binddn   => 'cn=sync,dc=example,dc=com',
          :sync_bindpw   => 'password',
        } }
 				it { should_not contain_motd__register('ldap::server::master') }
			end
      
			context 'Motd enabled' do
        let(:params) { { 
          :suffix => 'dc=example,dc=com',
          :rootpw => 'rootpwsuperpass',
          :sync_rid => 1,
          :sync_provider => 'ldap://master.ldap',
          :sync_updatedn => 'cn=admin,dc=example,dc=com',
          :sync_binddn   => 'cn=sync,dc=example,dc=com',
          :sync_bindpw   => 'password',
          :enable_motd   => true,
        } }
   
				it { should contain_motd__register('ldap::server::slave') }
			end
		end
	end
	
	describe "Running on unsupported OS" do
		let(:facts) { { :osfamily => 'solaris' } }
    let(:params) { { 
      :suffix => 'dc=example,dc=com',
      :rootpw => 'rootpwsuperpass',
      :sync_rid => 1,
      :sync_provider => 'ldap://master.ldap',
      :sync_updatedn => 'cn=admin,dc=example,dc=com',
      :sync_binddn   => 'cn=sync,dc=example,dc=com',
      :sync_bindpw   => 'password',
    } }

		it {
			expect {
				should include_class('ldap')
			}.to raise_error(Puppet::Error, /^Operating system.*/)
		}
	end

end
