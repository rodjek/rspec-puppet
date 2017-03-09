module Puppet::Parser::Functions
  newfunction(:camelCaseFunction, :type => :rvalue) do |args|
    raise Puppet::ParseError, "Requires 1 argument" unless args.length == 1
    raise Puppet::ParseError, "Argument must be a string" unless args.first.is_a?(String)
    return "test"
  end
end
