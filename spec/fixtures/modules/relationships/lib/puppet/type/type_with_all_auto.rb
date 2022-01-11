Puppet::Type.newtype(:type_with_all_auto) do
  ensurable
  newparam(:name, :namevar => true)
  autobefore(:file) { [File.join(self[:name], 'before'), nil] }
  autonotify(:file) { [File.join(self[:name], 'notify'), nil] }
  autorequire(:file) { [File.join(self[:name], 'require'), nil] }
  autosubscribe(:file) { [File.join(self[:name], 'subscribe'), nil] }
end
