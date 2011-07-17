require 'rspec-puppet/example/define_example_group'

RSpec::configure do |c|
  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]'))
  end

  c.include RSpec::Puppet::DefineExampleGroup, :type => :define, :example_group => {
    :file_path => c.escaped_path(%w[spec defines])
  }
end
