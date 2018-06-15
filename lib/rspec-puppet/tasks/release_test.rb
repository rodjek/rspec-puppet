require 'rake'
require 'open3'
require 'json'
require 'parser/current'

task :release_test do
  modules_to_test = [
    'puppetlabs/puppetlabs-apt',
    'puppetlabs/puppetlabs-tomcat',
    'puppetlabs/puppetlabs-apache',
    'puppetlabs/puppetlabs-mysql',
    'puppetlabs/puppetlabs-ntp',
    'puppetlabs/puppetlabs-acl',
    'puppetlabs/puppetlabs-chocolatey',
    'voxpupuli/puppet-archive',
    'voxpupuli/puppet-collectd',
    'garethr/garethr-docker',
    'sensu/sensu-puppet',
    'jenkinsci/puppet-jenkins',
    'rnelson0/puppet-local_user',
  ]

  Bundler.with_clean_env do
    FileUtils.mkdir_p('tmp')
    Dir.chdir('tmp') do
      modules_to_test.each do |module_name|
        puts "Testing #{module_name}..."
        module_dir = File.basename(module_name)

        if File.directory?(module_dir)
          Dir.chdir(module_dir) do
            print '  Updating repository... '
            _, status = Open3.capture2e('git', 'pull', '--rebase')
            if status.success?
              puts 'Done'
            else
              puts 'FAILED'
              next
            end
          end
        else
          print '  Cloning repository... '
          _, status = Open3.capture2e('git', 'clone', "https://github.com/#{module_name}")
          if status.success?
            puts 'Done'
          else
            puts 'FAILED'
            next
          end
        end

        Dir.chdir(module_dir) do
          print '  Installing dependencies... '
          bundle_install_output, status = Open3.capture2e('bundle', 'install', '--path', '../vendor/gems')
          if status.success?
            puts 'Done'
          else
            puts 'FAILED'
            puts bundle_install_output
            next
          end

          print '  Running baseline tests... '
          baseline_output, _, status = Open3.capture3({'SPEC_OPTS' => '--format json'}, 'bundle', 'exec', 'rake', 'spec')
          if status.success?
            puts 'Done'
          else
            puts 'Done (tests failed)'
          end

          print '  Updating Gemfile to use rspec-puppet HEAD... '
          buffer = Parser::Source::Buffer.new('Gemfile')
          buffer.source = File.read('Gemfile')
          parser = Parser::CurrentRuby.new
          ast = parser.parse(buffer)

          modified_gemfile = GemfileRewrite.new.rewrite(buffer, ast)

          gem_root = File.expand_path(File.join(__FILE__, '..', '..', '..', '..'))
          if modified_gemfile == buffer.source
            File.open('Gemfile', 'a') do |f|
              f.puts "gem 'rspec-puppet', :path => '#{gem_root}'"
            end
          else
            File.open('Gemfile', 'w') do |f|
              f.puts modified_gemfile
            end
          end

          puts 'Done'

          print '  Installing dependencies... '
          _, status = Open3.capture2e('bundle', 'install', '--path', '../vendor/gems')
          if status.success?
            puts 'Done'
          else
            puts "FAILED"
            next
          end

          print '  Running tests against rspec-puppet HEAD... '
          head_output, _, status = Open3.capture3({'SPEC_OPTS' => '--format json'}, 'bundle', 'exec', 'rake', 'spec')
          if status.success?
            puts 'Done'
          else
            puts 'Done (tests failed)'
          end

          print '  Restoring Gemfile... '
          _, status = Open3.capture2e('git', 'checkout', '--', 'Gemfile')
          if status.success?
            puts 'Done'
          else
            puts 'FAILED'
          end

          json_regex = %r{\{(?:[^{}]|(?:\g<0>))*\}}x
          baseline_results = JSON.parse(baseline_output.scan(json_regex).find { |r| r.include?('summary_line') })
          head_results = JSON.parse(head_output.scan(json_regex).find { |r| r.include?('summary_line') })
          if head_results['summary_line'] == baseline_results['summary_line']
            puts "  PASS: #{head_results['summary_line']}"
          else
            puts "!!FAILED: baseline:(#{baseline_results['summary_line']}) head:(#{head_results['summary_line']})"
          end
        end
      end
    end
  end
end

class GemfileRewrite < Parser::TreeRewriter
  def on_send(node)
    _, method_name, *args = *node

    if method_name == :gem
      gem_name = args.first
      if gem_name.type == :str && gem_name.children.first == 'rspec-puppet'
        gem_root = File.expand_path(File.join(__FILE__, '..', '..', '..', '..'))
        replace(node.location.expression, "gem 'rspec-puppet', :path => '#{gem_root}'")
      end
    end

    super
  end
end
