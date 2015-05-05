Puppet::Functions.create_function(:nil_function) do
  def nil_function(should_raise)
    if should_raise
      raise Puppet::ParseError, 'Forced Failure - new version'
    end
  end
end
