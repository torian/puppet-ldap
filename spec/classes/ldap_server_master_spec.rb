
require 'spec_helper'

oses = @oses

describe 'ldap::server::master' do

  oses.keys.each do |os|

    describe "Running on #{os}" do

      let(:facts) { {
        :osfamily                  => oses[os][:osfamily],
        :operatingsystem           => oses[os][:operatingsystem],
        :operatingsystemmajrelease => oses[os][:operatingsystemmajrelease],
        :architecture              => oses[os][:architecture],
        :concat_basedir            => '/nonexistent',
      } }

      let(:params) { {
        :suffix => 'dc=example,dc=com',
        :rootpw => 'asdqw',
      } }

      it { should contain_class('ldap') }
      it { should contain_service(oses[os][:service]) }
      it { should contain_package(oses[os][:server_pkg]) }
      it { should contain_file(oses[os][:server_cfg]) }

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
    let(:facts) { { :osfamily => 'solaris' } }
    let(:params) { {
      :suffix => 'dc=example,dc=com',
      :rootpw => 'asdqw',
    } }
    it {
      expect {
        should contain_class('ldap')
      }.to raise_error(Puppet::Error, /^Operating system.*/)
    }
  end

end
