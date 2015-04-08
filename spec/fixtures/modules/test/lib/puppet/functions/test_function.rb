Puppet::Functions.create_function(:test_function) do
  def test_function(value)
    "value is #{value}"
  end
end
