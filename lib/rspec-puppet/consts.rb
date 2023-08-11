# frozen_string_literal: true

module RSpec::Puppet::Consts
  STUBBED_CONSTS = {
    posix: {
      'File::PATH_SEPARATOR' => ':',
      'File::ALT_SEPARATOR' => nil,
      'Pathname::SEPARATOR_PAT' => /#{Regexp.quote('/')}/
    },
    windows: {
      'File::PATH_SEPARATOR' => ';',
      'File::ALT_SEPARATOR' => '\\',
      'Pathname::SEPARATOR_PAT' => /[#{Regexp.quote('\\')}#{Regexp.quote('/')}]/
    }
  }.freeze

  FEATURES = {
    posix: {
      posix: true,
      microsoft_windows: false
    },
    windows: {
      posix: false,
      microsoft_windows: true
    }
  }.freeze

  def self.stub_consts_for(platform)
    STUBBED_CONSTS[platform].each do |const_name, const_value|
      stub_const_wrapper(const_name, const_value)
    end
    Puppet::Util::Platform.pretend_to_be(platform)
    FEATURES[platform].each do |feature_name, feature_value|
      Puppet.features.add(feature_name) { feature_value }
    end
  end

  def self.stub_const_wrapper(const, value)
    klass_name, const_name = const.split('::', 2)
    klass = Object.const_get(klass_name)
    klass.send(:remove_const, const_name) if klass.const_defined?(const_name)
    klass.const_set(const_name, value)
  end

  def self.restore_consts
    stub_consts_for(RSpec.configuration.platform)
  end

  def self.without_stubs
    if Puppet::Util::Platform.pretending?
      pretend_platform = Puppet::Util::Platform.pretend_platform
      restore_consts
    end

    yield
  ensure
    stub_consts_for(pretend_platform) if pretend_platform
  end
end
