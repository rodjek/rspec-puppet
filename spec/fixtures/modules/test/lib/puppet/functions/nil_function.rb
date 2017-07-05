Puppet::Functions.create_function(:nil_function) do
  def nil_function(should_raise)
    raise Puppet::ParseError, 'Forced Failure - new version' if should_raise
  end
end
