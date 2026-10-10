require 'spec_helper'
describe 'timezone' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with default values for class parameters" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('timezone') }

      it {
        is_expected.to contain_file('/etc/localtime').with_ensure('link')
                                                     .with_target('/usr/share/zoneinfo/UTC')
      }

      if os_facts[:os]['name'] == 'Ubuntu' && Gem::Version.new(os_facts[:os]['release']['full']) < Gem::Version.new('26.04')
        it {
          is_expected.to contain_file('/etc/timezone').with({
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0644',
            'content' => "UTC\n",
          })
        }
      else
        it { is_expected.not_to contain_file('/etc/timezone') }
      end
    end

    context "on #{os} with timezone specified (Europe/Berlin)" do
      let(:facts) { os_facts }
      let(:params) do
        { timezone: 'Europe/Berlin' }
      end

      it {
        is_expected.to contain_file('/etc/localtime').with_ensure('link')
                                                     .with_target('/usr/share/zoneinfo/Europe/Berlin')
      }

      if os_facts[:os]['name'] == 'Ubuntu' && Gem::Version.new(os_facts[:os]['release']['full']) < Gem::Version.new('26.04')
        it {
          is_expected.to contain_file('/etc/timezone').with({
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0644',
            'content' => "Europe/Berlin\n",
          })
        }
      else
        it { is_expected.not_to contain_file('/etc/timezone') }
      end
    end
  end

  describe 'on unsupported platform' do
    let(:facts) do
      { os: { 'family' => 'unsupported', 'name' => 'unsupported', 'release' => { 'full' => '1' } } }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/localtime') }
    it { is_expected.not_to contain_file('/etc/timezone') }
  end

  describe 'variable data type and content validations' do
    validations = {
      'string' => {
        name: ['timezone'],
        valid: ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects a String value',
      },
    }

    validations.sort.each do |type, var|
      mandatory_params = {} if mandatory_params.nil?
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:facts) { { os: { 'family' => 'RedHat' } } }
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'fails' do
              expect { is_expected.to contain_class(subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
