Puppet::Parser::Functions.newfunction(:ensure_packages, :type => :statement) do |args|
  Puppet::Parser::Functions.function(:create_resources)
  function_create_resources(['Package', { args.first => { 'ensure' => 'present' } }])
end
