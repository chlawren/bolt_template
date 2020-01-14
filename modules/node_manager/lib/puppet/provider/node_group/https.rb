require 'puppet/util/nc_https'
require 'puppet_x/node_manager/common'

Puppet::Type.type(:node_group).provide(:https) do
  defaultfor :feature => :posix

  def initialize(value={})
    super(value)
    @property_flush = {
      'state' => {},
      'attrs' => {},
    }
  end


  def self.classifier
    @classifier ||= initialize_client
  end

  def self.initialize_client
    Puppet::Util::Nc_https.new
  end

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :classes            => 'classes',
      :environment        => 'environment',
      :environment_trumps => 'override_environment',
      :id                 => 'id',
      :name               => 'name',
      :parent             => 'parent',
      :rule               => 'rule',
      :variables          => 'variables',
      :description        => 'description',
      :config_data        => 'data',
    }
  end

  def self.instances
    $ngs = classifier.get_groups
    $ngs.collect do |group|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        # Replace parent ID with string name
        if friendly == 'parent'
          gindex = get_name_index_from_id(group[property.to_s])
          ngs_hash[friendly.to_sym] = $ngs[gindex]['name']
        else
          ngs_hash[friendly.to_sym] = group[property.to_s]
        end
      end
      # Boolean strings converted to syms
      ngs_hash[:override_environment] = :"#{ngs_hash[:override_environment]}"
      ngs_hash[:ensure] = :present
      new(ngs_hash)
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |group|
      if provider = ngs.find{ |g| g.name == group }
        resources[group].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def create
    @noflush = true
    # Only passing parameters that are given
    send_data = Hash.new
    @resource.original_parameters.each do |k,v|
      next if [:ensure, :provider].include? k
      next if @resource.parameter(k).metaparam?
      key = k.to_s
      # key changed for usability
      key = 'environment_trumps' if key == 'override_environment'
      key = 'config_data'        if key == 'data'
      send_data[key] = v
    end
    # namevar may not be in this hash
    send_data['name'] = @resource[:name] unless send_data['name']
    # Passing an empty hash in the type results in undef
    send_data['classes'] = {} unless send_data['classes']

    send_data['parent'] = '00000000-0000-4000-8000-000000000000' if !send_data['parent']
    unless send_data['parent'] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = get_id_index_from_name(send_data['parent'])
      if gindex
        send_data['parent'] = $ngs[gindex]['id']
      end
    end

    resp = self.class.classifier.create_group(send_data)
    @resource.original_parameters.each_key do |k|
      if k == :ensure
        @property_hash[:ensure] = :present
      else
        @property_hash[k]       = @resource[k]
      end
    end
    # Add placeholder for $ngs lookups
    $ngs << { "name" => send_data['name'], "id" => resp }

    exists? ? (return true) : (return false)

  end

  def destroy
    @noflush = true
    self.class.classifier.delete_group(@property_hash[:id])
    @property_hash.clear

    exists? ? (return false) : (return true)
  end

  # If ID is given, translate to string name
  def parent
    if @resource[:parent] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = self.class.get_name_index_from_id(@resource[:parent])
      $ngs[gindex]['name']
    else
      @property_hash[:parent]
    end
  end

  def classes
    # Need to deep sort hashes so they be evaluated equally
    PuppetX::Node_manager::Common.sort_hash(@property_hash[:classes])
  end

  def data
    # Need to deep sort hashes so they be evaluated equally
    PuppetX::Node_manager::Common.sort_hash(@property_hash[:data])
  end

  def rule
    @property_hash[:rule].nil? ? [''] : @property_hash[:rule]
  end

  friendly_name.each do |property,friendly|
    define_method "#{friendly}=" do |value|
      if property == :parent
        if value =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
          @property_flush['attrs'][property.to_s] = value
        else
          gindex = $ngs.index { |i| i['name'] == value }
          @property_flush['attrs'][property.to_s] = $ngs[gindex]['id']
        end
      # These 3 attributes are additive, so need to submit nulls to remove unwanted values
      elsif [:variables, :classes, :config_data].include?(property)
        @property_flush['attrs'][property.to_s] = add_nulls(@property_hash[friendly.to_sym], value)
        # For logging return to original intended value
        @resource[friendly.to_sym] = value.select { |k,v| v != nil }
      else
        # The to_json function needs to recognize
        # booleans true/false, not symbols :true/false
        case value
        when :true
          @property_flush['attrs'][property.to_s] = true
        when :false
          @property_flush['attrs'][property.to_s] = false
        else
          @property_flush['attrs'][property.to_s] = value
        end
      end
      @property_hash[friendly.to_sym] = value
    end
  end

  def flush
    return if @noflush
    Puppet.debug @property_flush['attrs']
    if @property_flush['attrs']
      @property_flush['attrs']['id'] = @property_hash[:id] unless @property_flush['attrs']['id']
      self.class.classifier.update_group(@property_flush['attrs'])
    end
  end

  private

  def self.get_name_index_from_id(id)
    $ngs.index { |i| i['id'] == id }
  end

  def get_id_index_from_name(name)
    $ngs.index { |i| i['name'] == name }
  end

  def add_nulls(current, new)
    if current.is_a?(Hash)
      allkeys = (current.keys + new.keys).uniq
    else
      allkeys = new.keys
    end
    newhash = Hash.new

    allkeys.each do |k|
      if new[k].is_a?(Hash)
        # Push forward an empty hash if nothing is there
        _current   = current.is_a?(Hash) ? current[k] : {}
        newhash[k] = add_nulls(_current, new[k])
      else
        newhash[k] = new[k] || nil
      end
    end

    newhash
  end

end
