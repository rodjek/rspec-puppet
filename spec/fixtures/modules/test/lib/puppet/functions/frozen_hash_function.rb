Puppet::Functions.create_function(:frozen_hash_function) do
  def frozen_hash_function(value)
    value.frozen? && value.all? { |k, v| k.frozen? && v.frozen? }
  end
end
