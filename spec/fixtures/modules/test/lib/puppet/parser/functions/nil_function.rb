Puppet::Parser::Functions.newfunction(:nil_function) do |arguments|
  raise Puppet::ParseError, 'Forced Failure - old version' if arguments[0]
end
