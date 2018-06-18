require 'rake'
require 'open3'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'

def forge_api_req(uri)
  puts uri
  uri = URI.parse(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  response.body
end

def query_forge(params)
  request_params = if params.is_a?(String)
                     params[%r{.+\?(.+)\Z}, 1]
                   else
                     params.map { |k, v| "#{k}=#{v}" }.join('&')
                   end

  data = forge_api_req("https://forgeapi.puppetlabs.com/v3/modules?#{request_params}")
  json_data = JSON.parse(data)

  results = json_data['results']
  if json_data['pagination']['next']
    results += query_forge(json_data['pagination']['next'])
  end

  results
end

def audit_rspec_puppet_version(modules)
  FileUtils.mkdir_p('tmp')
  Bundler.with_clean_env do
    Dir.chdir('tmp') do
      modules.each do |mod|
        next if mod['deprecated_at']

        print "#{mod['slug']}: "

        module_dir = File.basename(mod['homepage_url'])
        if File.directory?(module_dir)
          Dir.chdir(module_dir) do
            _, status = Open3.capture2e('git', 'pull', '--rebase')
            unless status.success?
              puts "GIT PULL FAILED"
              next
            end
          end
        else
          git_url = mod['current_release']['metadata']['source']
          git_url.gsub!(%r{\Agit@github\.com:}, 'https://github.com/')
          _, status = Open3.capture2e('git', 'clone', git_url, module_dir)
          unless status.success?
            puts "GIT CLONE FAILED"
            next
          end
        end

        Dir.chdir(module_dir) do
          unless File.exist?('Gemfile')
            puts "NO GEMFILE"
            next
          end

          _, status = Open3.capture2e('bundle', 'install', '--path', '../vendor/gems')
          unless status.success?
            puts "BUNDLE INSTALL FAILED"
            next
          end

          output, status = Open3.capture2e('bundle', 'show', 'rspec-puppet')
          if status.success?
            print output[%r{.+rspec-puppet-(\d+\.\d+\.\d+)\Z}, 1]
            File.open('Gemfile', 'rb') do |f|
              if f.read.match(%r{\brspec-puppet\b})
                print ' (Gemfile contains rspec-puppet pin)'
              end
            end
            puts ''
          else
            puts "BUNDLE SHOW FAILED"
          end
        end
      end
    end
  end
end

namespace :audit do
  task :supported do
    audit_rspec_puppet_version(query_forge(:supported => true))
  end

  task :puppetlabs do
    audit_rspec_puppet_version(query_forge(:owner => 'puppetlabs'))
  end
end
