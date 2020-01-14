require 'puppet_x/node_manager/common'

Puppet::Type.newtype(:node_group) do
  desc 'The node_group type creates and manages node groups for the PE Node Manager'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the common name for the node group'
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |value|
      fail("ID is read-only")
    end
  end
  newproperty(:override_environment) do
    desc 'Override parent environments'
    newvalues(:false, :true)
  end
  newproperty(:parent) do
    desc 'The ID of the parent group'
  end
  newproperty(:variables) do
    desc 'Variables set this group\'s scope'
    validate do |value|
      fail("Variables must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
  newproperty(:rule, :array_matching => :all) do
    desc 'Match conditions for this group'
  end
  newproperty(:environment) do
    desc 'Environment for this group'
    defaultto :production
    validate do |value|
      fail("Invalid environment name") unless value =~ /\A[a-z0-9_]+\Z/ or value == 'agent-specified'
    end
  end
  newproperty(:classes) do
    desc 'Classes applied to this group'
    defaultto {}
    validate do |value|
      fail("Classes must be supplied as a hash") unless value.is_a?(Hash)
    end
    # Need to deep sort hashes so they be evaluated equally
    munge do |value|
      PuppetX::Node_manager::Common.sort_hash(value)
    end
  end
  newproperty(:data) do
    desc 'Data applied to this group'
    #defaultto {}
    validate do |value|
      fail("Data must be supplied as a hash") unless value.is_a?(Hash)
    end
    # Need to deep sort hashes so they be evaluated equally
    munge do |value|
      PuppetX::Node_manager::Common.sort_hash(value)
    end
  end
  newproperty(:description) do
    desc 'Description of this group'
  end

  autorequire(:node_group) do
    self[:parent] if @parameters.include? :parent
  end

end
