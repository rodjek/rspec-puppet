require 'pathname'

# Load this library before enabling the monkey-patches to avoid HI-581
begin
require 'hiera/util/win32'
rescue LoadError
  # ignore this on installs without hiera, e.g. puppet 3 gems
end

class RSpec::Puppet::EventListener
  def self.example_started(example)
    if rspec3?
      @rspec_puppet_example = example.example.example_group.ancestors.include?(RSpec::Puppet::Support)
      @current_example = example.example
      if !@current_example.respond_to?(:environment) && @current_example.respond_to?(:example_group_instance)
        @current_example = @current_example.example_group_instance
      end
    else
      @rspec_puppet_example = example.example_group.ancestors.include?(RSpec::Puppet::Support)
      @current_example = example
    end
  end

  def self.example_passed(example)
    @rspec_puppet_example = false
  end

  def self.example_pending(example)
    @rspec_puppet_example = false
  end

  def self.example_failed(example)
    @rspec_puppet_example = false
  end

  def self.rspec_puppet_example?
    @rspec_puppet_example || false
  end

  def self.rspec3?
    if @rspec3.nil?
      @rspec3 = defined?(RSpec::Core::Notifications)
    end

    @rspec3
  end

  def self.current_example
    @current_example
  end
end

RSpec.configuration.reporter.register_listener(RSpec::Puppet::EventListener, :example_started, :example_pending, :example_passed, :example_failed)

require 'rspec-puppet/monkey_patches/win32/taskscheduler'
require 'rspec-puppet/monkey_patches/win32/registry'
require 'rspec-puppet/monkey_patches/windows/taskschedulerconstants'

module Puppet
  # Allow rspec-puppet to prevent Puppet::Type from automatically picking
  # a provider for a resource. We need to do this because in order to fully
  # resolve the graph edges, we have to convert the Puppet::Resource objects
  # into Puppet::Type objects so that their autorequires are evaluated. We need
  # to prevent provider code from being called during this process as it's very
  # platform specific.
  class Type
    old_set_default = instance_method(:set_default)

    define_method(:set_default) do |attr|
      if RSpec::Puppet.rspec_puppet_example?
        old_posix = nil
        old_microsoft_windows = nil

        if attr == :provider
          old_posix = Puppet.features.posix?
          old_microsoft_windows = Puppet.features.microsoft_windows?

          if Puppet::Util::Platform.pretend_windows?
            Puppet.features.add(:posix) { false }
            Puppet.features.add(:microsoft_windows) { true }
          else
            Puppet.features.add(:posix) { true }
            Puppet.features.add(:microsoft_windows) { false }
          end
        end

        retval = old_set_default.bind(self).call(attr)

        unless old_posix.nil?
          Puppet.features.add(:posix) { old_posix }
        end
        unless old_microsoft_windows.nil?
          Puppet.features.add(:microsoft_windows) { old_microsoft_windows }
        end

        retval
      else
        old_set_default.bind(self).call(attr)
      end
    end

    def self.suppress_provider?
      @suppress_provider ||= false
    end

    def self.suppress_provider
      @suppress_provider = true
    end

    def self.unsuppress_provider
      @suppress_provider = false
    end
  end

  module Parser::Files
    alias :old_find_manifests_in_modules :find_manifests_in_modules
    module_function :old_find_manifests_in_modules

    def find_manifests_in_modules(pattern, environment)
      if RSpec::Puppet.rspec_puppet_example?
        pretending = Puppet::Util::Platform.pretend_platform

        unless pretending.nil?
          Puppet::Util::Platform.pretend_to_be nil
          RSpec::Puppet::Consts.stub_consts_for(RSpec.configuration.platform)
        end

        if pretending && pretending != Puppet::Util::Platform.actual_platform
          environment.send(:value_cache).clear if environment.respond_to?(:value_cache, true)
        end
        output = old_find_manifests_in_modules(pattern, environment)

        unless pretending.nil?
          Puppet::Util::Platform.pretend_to_be pretending
          RSpec::Puppet::Consts.stub_consts_for pretending
        end

        output
      else
        old_find_manifests_in_modules(pattern, environment)
      end
    end
    module_function :find_manifests_in_modules
  end

  module Util
    if respond_to?(:get_env)
      alias :old_get_env :get_env
      module_function :old_get_env

      def get_env(name, mode = default_env)
        if RSpec::Puppet.rspec_puppet_example?
          # use the actual platform, not the pretended
         old_get_env(name, Platform.actual_platform)
        else
         old_get_env(name, mode)
        end
      end
      module_function :get_env
    end

    # Allow rspec-puppet to pretend to be different platforms.
    module Platform
      alias :old_windows? :windows?
      module_function :old_windows?

      def windows?
        if RSpec::Puppet.rspec_puppet_example?
          pretend_platform.nil? ? (actual_platform == :windows) : pretend_windows?
        else
          old_windows?
        end
      end
      module_function :windows?

      def actual_platform
        @actual_platform ||= !!File::ALT_SEPARATOR ? :windows : :posix
      end
      module_function :actual_platform

      def actually_windows?
        actual_platform == :windows
      end
      module_function :actually_windows?

      def pretend_windows?
        pretend_platform == :windows
      end
      module_function :pretend_windows?

      def pretend_to_be(platform)
        # Ensure that we cache the real platform before pretending to be
        # a different one
        actual_platform

        @pretend_platform = platform
      end
      module_function :pretend_to_be

      def pretend_platform
        @pretend_platform ||= nil
      end
      module_function :pretend_platform
    end
  end

  begin
    require 'puppet/confine/exists'

    class Confine::Exists < Puppet::Confine
      old_pass = instance_method(:pass?)

      define_method(:pass?) do |value|
        if RSpec::Puppet.rspec_puppet_example?
          true
        else
          old_pass.bind(self).call(value)
        end
      end
    end
  rescue LoadError
    require 'puppet/provider/confine/exists'

    class Provider::Confine::Exists < Puppet::Provider::Confine
      old_pass = instance_method(:pass?)

      define_method(:pass?) do |value|
        if RSpec::Puppet.rspec_puppet_example?
          true
        else
          old_pass.bind(self).call(value)
        end
      end
    end
  end
end

class Pathname
  def rspec_puppet_basename(path)
    raise ArgumentError, 'pathname stubbing not enabled' unless RSpec.configuration.enable_pathname_stubbing

    if path =~ /\A[a-zA-Z]:(#{SEPARATOR_PAT}.*)\z/
      path = path[2..-1]
    end
    path.split(SEPARATOR_PAT).last || path[/(#{SEPARATOR_PAT})/, 1] || path
  end

  if instance_methods.include?("chop_basename")
    old_chop_basename = instance_method(:chop_basename)

    define_method(:chop_basename) do |path|
      if RSpec::Puppet.rspec_puppet_example?
        if RSpec.configuration.enable_pathname_stubbing
          base = rspec_puppet_basename(path)
          if /\A#{SEPARATOR_PAT}?\z/o =~ base
            return nil
          else
            return path[0, path.rindex(base)], base
          end
        else
          old_chop_basename.bind(self).call(path)
        end
      else
        old_chop_basename.bind(self).call(path)
      end
    end
  end
end

# Prevent the File type from munging paths (which uses File.expand_path to
# normalise paths, which does very bad things to *nix paths on Windows.
file_path_munge = Puppet::Type.type(:file).paramclass(:path).instance_method(:unsafe_munge)
Puppet::Type.type(:file).paramclass(:path).munge do |value|
  if RSpec::Puppet.rspec_puppet_example?
    value
  else
    file_path_munge.bind(self).call(value)
  end
end

# Prevent the Exec type from validating the user. This parameter isn't
# supported under Windows at all and only under *nix when the current user is
# root.
exec_user_validate = Puppet::Type.type(:exec).paramclass(:user).instance_method(:unsafe_validate)
Puppet::Type.type(:exec).paramclass(:user).validate do |value|
  if RSpec::Puppet.rspec_puppet_example?
    true
  else
    exec_user_validate.bind(self).call(value)
  end
end

# Stub out Puppet::Util::Windows::Security.supports_acl? if it has been
# defined. This check only makes sense when applying the catalogue to a host
# and so can be safely stubbed out for unit testing.
Puppet::Type.type(:file).provide(:windows).class_eval do
  old_supports_acl = instance_method(:supports_acl?) if respond_to?(:supports_acl?)

  def supports_acl?(path)
    if RSpec::Puppet.rspec_puppet_example?
      true
    else
      old_supports_acl.bind(self).call(value)
    end
  end

  old_manages_symlinks = instance_method(:manages_symlinks?) if respond_to?(:manages_symlinks?)

  def manages_symlinks?
    if RSpec::Puppet.rspec_puppet_example?
      true
    else
      old_manages_symlinks.bind(self).call(value)
    end
  end
end

# Prevent Puppet from requiring 'puppet/util/windows' if we're pretending to be
# windows, otherwise it will require other libraries that probably won't be
# available on non-windows hosts.
module Kernel
  alias :old_require :require
  def require(path)
    return if (['puppet/util/windows', 'win32/registry'].include?(path)) && RSpec::Puppet.rspec_puppet_example? && Puppet::Util::Platform.pretend_windows?
    old_require(path)
  end
end
