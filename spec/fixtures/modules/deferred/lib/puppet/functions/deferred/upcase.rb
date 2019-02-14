Puppet::Functions.create_function(:'deferred::upcase') do
  dispatch :up do
    param 'String', :some_string
  end

  def up(some_string)
    some_string.upcase
  end
end
