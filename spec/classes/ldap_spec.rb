
require 'spec_helper'

oses = @oses

describe 'ldap' do

	oses.keys.each do |os|

		describe "Running on #{os}" do

			let(:facts) { {
				:osfamily                  => oses[os][:osfamily],
				:operatingsystem           => oses[os][:operatingsystem],
				:operatingsystemmajrelease => oses[os][:operatingsystemmajrelease],
				:architecture              => oses[os][:architecture],
			} }

			it { should include_class('ldap::params') }

      context 'Ensure is set to present' do

        let(:params) { { 
          :ensure  => 'present',
        } }

			  it 'install required packages ' do
          should contain_package(oses[os][:utils_pkg]).with({
            'ensure' => 'present',
          })
        end

      end

      context 'Ensure is set to absent' do

        let(:params) { { 
          :ensure  => 'absent',
        } }

			  it 'do not install required packages ' do
          should contain_package(oses[os][:utils_pkg]).with({
            'ensure' => 'absent',
          })
        end

      end

      context 'Ensure is not set' do

			  it 'install required packages ' do
          should contain_package(oses[os][:utils_pkg]).with({
            'ensure' => 'present',
          })
        end

      end

		end

	end

end
