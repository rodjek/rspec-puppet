Puppet::Parser::Functions.newfunction(:nil_function) do |arguments|
  if arguments[0]
    raise Puppet::ParseError, 'Forced Failure - old version'
  end
end
