Puppet::Type.newtype(:type_with_all_auto) do
  ensurable
  newparam(:name, :namevar => true)
  autobefore(:notify) { ["#{self[:name]}/before", nil] }
  autonotify(:notify) { ["#{self[:name]}/notify", nil] }
  autorequire(:notify) { ["#{self[:name]}/require", nil] }
  autosubscribe(:notify) { ["#{self[:name]}/subscribe", nil] }
end
