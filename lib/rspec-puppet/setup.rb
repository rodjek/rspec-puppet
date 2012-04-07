require 'puppet'
require 'fileutils'

module RSpec::Puppet
  class Setup
    def self.run(module_name=nil)
      unless is_module_dir?
        $stderr.puts "Does not appear to be a Puppet module.  Aborting"
        return false
      end

      if module_name.nil?
        module_name = get_module_name
        if module_name.nil?
          $stderr.puts "Unable to determine module name.  Aborting"
          return false
        end
      end

      [
        'spec',
        'spec/classes',
        'spec/defines',
        'spec/functions',
        'spec/hosts',
        'spec/fixtures',
        'spec/fixtures/manifests',
        'spec/fixtures/modules',
        "spec/fixtures/modules/#{module_name}",
      ].each { |dir| safe_mkdir(dir) }

      safe_touch('spec/fixtures/manifests/site.pp')

      ['manifests','lib','files','templates'].each do |dir|
        if File.exist? dir
          safe_make_symlink("../../../../#{dir}", "spec/fixtures/modules/#{module_name}/#{dir}")
        end
      end

      safe_create_spec_helper
      safe_create_rakefile
    end

  protected
    def self.get_module_name
      p = Puppet::Parser::Lexer.new
      module_name = nil
      Dir["manifests/*.pp"].entries.each do |manifest|
        p.string = File.read(manifest)
        tokens = p.fullscan
        i = tokens.index { |token| [:CLASS, :DEFINE].include? token.first }
        unless i.nil?
          module_name = tokens[i + 1].last[:value].split('::').first
          break
        end
      end
      module_name
    end

    def self.is_module_dir?
      Dir["*"].entries.include? "manifests"
    end

    def self.safe_mkdir(dir)
      if File.exists? dir
        unless File.directory? dir
          $stderr.puts "!! #{dir} already exists and is not a directory"
        end
      else
        FileUtils.mkdir dir
        puts " + #{dir}/"
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

    def self.safe_create_spec_helper
      content = <<-EOF
require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
EOF
      if File.exists? 'spec/spec_helper.rb'
        old_content = File.read('spec/spec_helper.rb')
        if old_content != content
          $stderr.puts "!! spec/spec_helper.rb already exists and differs from template"
        end
      else
        File.open('spec/spec_helper.rb', 'w') do |f|
          f.puts content
        end
        puts ' + spec/spec_helper.rb'
      end
    end

    def self.safe_make_symlink(source, target)
      if File.exists? target
        unless File.symlink? target
          $stderr.puts "!! #{file} already exists and is not a symlink"
        end
      else
        FileUtils.ln_s(source, target)
        puts " + #{target}"
      end
    end

    def self.safe_create_rakefile
      content = <<-EOF
require 'rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end
EOF
      if File.exists? 'Rakefile'
        old_content = File.read('Rakefile')
        if old_content != content
          $stderr.puts "!! Rakefile already exists and differs from template"
        end
      else
        File.open('Rakefile', 'w') do |f|
          f.puts content
        end
        puts ' + Rakefile'
      end
    end
  end
end
