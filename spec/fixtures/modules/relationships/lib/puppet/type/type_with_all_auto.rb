Puppet::Type.newtype(:type_with_all_auto) do
  ensurable
  newparam(:name, :namevar => true)
  autobefore(:file) { [File.join(self[:name], 'before')] }
  autonotify(:file) { [File.join(self[:name], 'notify')] }
  autorequire(:file) { [File.join(self[:name], 'require')] }
  autosubscribe(:file) { [File.join(self[:name], 'subscribe')] }
end
