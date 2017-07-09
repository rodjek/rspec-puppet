Puppet::Type.newtype(:fake) do
  feature :eleven, '11'
  feature :twelve, '12'

  newparam(:name, :isnamevar => true)

  newparam(:three)

  newparam(:four) do
    newvalues(%r{(one|two)})
  end

  newproperty(:seven)

  newproperty(:eight)

  validate do
    raise 'three is a required param' unless self[:three]
  end
end
