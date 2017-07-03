require 'puppet'
if Puppet.version.to_f >= 4.0
  require 'puppet/pops'
end
require 'fileutils'

module RSpec::Puppet
  class Setup
    def self.run(module_name=nil)
      unless is_module_dir?
        $stderr.puts "Does not appear to be a Puppet module.  Aborting"
        return false
      end

      safe_setup_directories(module_name)
      safe_touch(File.join('spec', 'fixtures', 'manifests', 'site.pp'))

      safe_create_spec_helper
      safe_create_rakefile
    end

    def self.safe_setup_directories(module_name=nil, verbose=true)
      if control_repo?
        $stderr.puts "Unable to setup rspec-puppet automatically in a control repo" if verbose
        return false
      end

      if module_name.nil?
        module_name = get_module_name
        if module_name.nil?
          $stderr.puts "Unable to determine module name.  Aborting" if verbose
          return false
        end
      end

      [
        'spec',
        File.join('spec', 'classes'),
        File.join('spec', 'defines'),
        File.join('spec', 'functions'),
        File.join('spec', 'hosts'),
        File.join('spec', 'fixtures'),
        File.join('spec', 'fixtures', 'manifests'),
        File.join('spec', 'fixtures', 'modules'),
      ].each { |dir| safe_mkdir(dir, verbose) }

      target = File.join('spec', 'fixtures', 'modules', module_name)
      safe_make_link('.', target, verbose)
    end

    def self.safe_teardown_links(module_name=nil)
      if module_name.nil?
        module_name = get_module_name
        if module_name.nil?
          $stderr.puts "Unable to determine module name.  Aborting"
          return false
        end
      end

      target = File.join('spec', 'fixtures', 'modules', module_name)
      if File.symlink?(target) && File.readlink(target) == File.expand_path('.')
        File.unlink(target)
      end
    end
  protected
    def self.control_repo?
      !File.exist?('metadata.json')
    end

    def self.get_module_name
      module_name = nil
      Dir["manifests/*.pp"].entries.each do |manifest|
        module_name = get_module_name_from_file(manifest)
        break unless module_name.nil?
      end
      module_name
    end

    def self.get_module_name_from_file(file)
      # FIXME: see discussion at
      # https://github.com/rodjek/rspec-puppet/issues/290
      if Puppet.version.to_f >= 4.0
        p = Puppet::Pops::Parser::Lexer2.new
      else
        p = Puppet::Parser::Lexer.new
      end
      module_name = nil
      p.string = File.read(file)
      tokens = p.fullscan

      i = tokens.index { |token| [:CLASS, :DEFINE].include? token.first }
      unless i.nil?
        module_name = tokens[i + 1].last[:value].split('::').first
      end

      module_name
    end

    def self.is_module_dir?
      Dir["*"].entries.include? "manifests"
    end

    def self.safe_mkdir(dir, verbose=true)
      if File.exists? dir
        unless File.directory? dir
          $stderr.puts "!! #{dir} already exists and is not a directory"
        end
      else
        begin
          FileUtils.mkdir dir
        rescue Errno::EEXIST => e
          raise e unless File.directory? dir
        end
        puts " + #{dir}/" if verbose
      end
    end

    def self.safe_touch(file)
      if File.exists? file
        unless File.file? file
          $stderr.puts "!! #{file} already exists and is not a regular file"
        end
      else
        FileUtils.touch file
        puts " + #{file}"
      end
    end

    def self.safe_create_file(filename, content)
      if File.exists? filename
        old_content = File.read(filename)
        if old_content != content
          $stderr.puts "!! #{filename} already exists and differs from template"
        end
      else
        File.open(filename, 'w') do |f|
          f.puts content
        end
        puts " + #{filename}"
      end
    end

    def self.safe_create_spec_helper
      content = File.read(File.expand_path(File.join(__FILE__, '..', 'spec_helper.rb')))
      safe_create_file('spec/spec_helper.rb', content)
    end

    def self.safe_make_link(source, target, verbose=true)
      if File.exists?(target)
        unless File.symlink?(target) && File.readlink(target) == File.expand_path(source)
          $stderr.puts "!! #{target} already exists and is not a symlink"
        end
      else
        if Puppet::Util::Platform.windows?
          output = `call mklink /J "#{target.gsub('/', '\\')}" "#{source}"`
          unless $?.success?
            puts output
            abort
          end
        else
          begin
            FileUtils.ln_s(File.expand_path(source), target)
          rescue Errno::EEXIST => e
            raise e unless File.symlink?(target) && File.readlink(target) == File.expand_path(source)
          end
        end
        puts " + #{target}" if verbose
      end
    end

    def self.safe_create_rakefile
      content = <<-'EOF'
require 'rspec-puppet/rake_task'

begin
  if Gem::Specification::find_by_name('puppet-lint')
    require 'puppet-lint/tasks/puppet-lint'
    PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp"]
    task :default => [:rspec, :lint]
  end
rescue Gem::LoadError
  task :default => :rspec
end
EOF
      safe_create_file('Rakefile', content)
    end
  end
end
