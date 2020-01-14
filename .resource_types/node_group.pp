# This file was automatically generated on 2020-01-13 17:09:09 +0000.
# Use the 'puppet generate types' command to regenerate this file.

# The node_group type creates and manages node groups for the PE Node Manager
Puppet::Resource::ResourceType3.new(
  'node_group',
  [
    # The basic property that the resource should be in.
    # 
    # Valid values are `present`, `absent`.
    Puppet::Resource::Param(Enum['present', 'absent'], 'ensure'),

    # The ID of the group
    Puppet::Resource::Param(Any, 'id'),

    # Override parent environments
    # 
    # Valid values are `false`, `true`.
    Puppet::Resource::Param(Variant[Boolean, Enum['false', 'true']], 'override_environment'),

    # The ID of the parent group
    Puppet::Resource::Param(Any, 'parent'),

    # Variables set this group's scope
    Puppet::Resource::Param(Any, 'variables'),

    # Match conditions for this group
    Puppet::Resource::Param(Any, 'rule'),

    # Environment for this group
    Puppet::Resource::Param(Any, 'environment'),

    # Classes applied to this group
    Puppet::Resource::Param(Any, 'classes'),

    # Data applied to this group
    Puppet::Resource::Param(Any, 'data'),

    # Description of this group
    Puppet::Resource::Param(Any, 'description')
  ],
  [
    # This is the common name for the node group
    Puppet::Resource::Param(Any, 'name', true),

    # The specific backend to use for this `node_group`
    # resource. You will seldom need to specify this --- Puppet will usually
    # discover the appropriate provider for your platform.Available providers are:
    # 
    # https
    # : * Default for `feature` == `posix`.
    # 
    # puppetclassify
    # :
    Puppet::Resource::Param(Any, 'provider')
  ],
  {
    /(?m-ix:(.*))/ => ['name']
  },
  true,
  false)
