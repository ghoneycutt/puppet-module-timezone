require 'spec_helper'

describe 'timezone', :type => 'class' do
  describe 'On RedHat' do
    ['5','6','7'].each do |release|
      describe "release #{release}" do
        context 'with default values for all parameters' do
          let(:facts) do
            {
              :osfamily                  => 'RedHat',
              :lsbmajdistrelease         => release,
              :operatingsystemmajrelease => release,
            }
          end

          it {
            should contain_file('/etc/localtime').with_ensure('link').
              with_target('/usr/share/zoneinfo/UTC')
          }

          if release == '7'
            it { should_not contain_file('/etc/sysconfig/clock') }
          else
            it {
              should contain_file('/etc/sysconfig/clock').with({
                'owner' => 'root',
                'group' => 'root',
                'mode'  => '0644',
              })
            }

          it { should contain_file('/etc/sysconfig/clock').with_content(/^ZONE=\"UTC\"$/) }
          it { should contain_file('/etc/sysconfig/clock').with_content(/^UTC=true$/) }
          it { should contain_file('/etc/sysconfig/clock').without_content(/^ARC/) }
          it { should contain_file('/etc/sysconfig/clock').without_content(/^SRM/) }
          end
        end

        [true,'true',false,'false'].each do |arc_value|
          context "with arc parameter set to #{arc_value}" do
            let(:params) { { :arc => arc_value } }
            let(:facts) do
              {
                :osfamily          => 'RedHat',
                :lsbmajdistrelease => release,
              }
            end

            it {
              should contain_file('/etc/localtime').with_ensure('link').
                with_target('/usr/share/zoneinfo/UTC')
            }

            it {
              should contain_file('/etc/sysconfig/clock').with({
                'owner' => 'root',
                'group' => 'root',
                'mode'  => '0644',
              })
            }

            if arc_value.to_s == 'true'
              it { should contain_file('/etc/sysconfig/clock').with_content(/^ARC=true$/) }
            else
              it { should contain_file('/etc/sysconfig/clock').with_content(/^ARC=false$/) }
            end

            it { should contain_file('/etc/sysconfig/clock').with_content(/^ZONE=\"UTC\"$/) }
            it { should contain_file('/etc/sysconfig/clock').with_content(/^UTC=true$/) }
            it { should contain_file('/etc/sysconfig/clock').without_content(/^SRM/) }
          end
        end

        context 'with arc parameter set to an invalid type' do
          let(:params) { { :arc => ['invalid','type'] } }
          let(:facts) do
            {
              :osfamily          => 'RedHat',
              :lsbmajdistrelease => release,
            }
          end

          it 'should fail' do
            expect {
              should contain_class('timezone')
            }.to raise_error(Puppet::Error)
          end
        end

        [true,'true',false,'false'].each do |srm_value|
          context "with srm parameter set to #{srm_value}" do
            let(:params) { { :srm => srm_value } }
            let(:facts) do
              {
                :osfamily          => 'RedHat',
                :lsbmajdistrelease => release,
              }
            end

            it {
              should contain_file('/etc/localtime').with_ensure('link').
                with_target('/usr/share/zoneinfo/UTC')
            }

            it {
              should contain_file('/etc/sysconfig/clock').with({
                'owner' => 'root',
                'group' => 'root',
                'mode'  => '0644',
              })
            }

            if srm_value.to_s == 'true'
              it { should contain_file('/etc/sysconfig/clock').with_content(/^SRM=true$/) }
            else
              it { should contain_file('/etc/sysconfig/clock').with_content(/^SRM=false$/) }
            end

            it { should contain_file('/etc/sysconfig/clock').with_content(/^ZONE=\"UTC\"$/) }
            it { should contain_file('/etc/sysconfig/clock').with_content(/^UTC=true$/) }
            it { should contain_file('/etc/sysconfig/clock').without_content(/^ARC/) }
          end
        end

        context 'with srm parameter set to an invalid type' do
          let(:params) { { :srm => ['invalid','type'] } }
          let(:facts) do
            {
              :osfamily          => 'RedHat',
              :lsbmajdistrelease => release,
            }
          end

          it 'should fail' do
            expect {
              should contain_class('timezone')
            }.to raise_error(Puppet::Error)
          end
        end
      end
    end
  end

  context "On RedHat system with time-zone Europe/Berlin" do
    let(:facts) do { :osfamily => 'RedHat' } end

    it {
      should contain_file('/etc/localtime').with_ensure('link').
        with_target('/usr/share/zoneinfo/UTC')
    }
  end

  context 'On Debian system with default values for all parameters' do
    let(:facts) do { :osfamily => 'Debian' } end

    it {
      should contain_file('/etc/localtime').with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })
    }

    it {
      should contain_file('/etc/timezone').with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })
    }

    it { should contain_file('/etc/timezone').with_content("UTC\n") }
  end
end
