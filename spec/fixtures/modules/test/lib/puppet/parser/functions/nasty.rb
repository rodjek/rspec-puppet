Puppet::Parser::Functions.newfunction(:nasty, :type => :rvalue) do |arguments| # rubocop:disable Style/SymbolProc
  arguments.shift
end
