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

      %w(data manifests lib files templates functions types).each do |dir|
        if File.exist? dir
          safe_make_symlink("../../../../#{dir}", "spec/fixtures/modules/#{module_name}/#{dir}")
        end
      end

      safe_create_spec_helper
      safe_create_rakefile
    end

  protected
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
      content = "require 'rspec-puppet/spec_helper'\n"
      safe_create_file('spec/spec_helper.rb', content)
    end

    def self.safe_make_symlink(source, target)
      if File.exists? target
        unless File.symlink? target
          $stderr.puts "!! #{target} already exists and is not a symlink"
        end
      else
        FileUtils.ln_s(source, target)
        puts " + #{target}"
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
