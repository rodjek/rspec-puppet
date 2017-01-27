Puppet::Functions.create_function(:frozen_array_function) do
  def frozen_array_function(value)
    value.frozen? && value.all?(&:frozen?)
  end
end
