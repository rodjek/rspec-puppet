Puppet::Functions.create_function(:frozen_function) do
  def frozen_function(value)
    value.frozen?
  end
end
