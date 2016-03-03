module Aggregate::CombinedStringField
  class CombinedStringField
    attr_accessor :attributes, :host_attribute
    def initialize(attributes, host_attribute)
      @attributes = attributes
      @host_attribute = host_attribute
    end

    def read(owner,attribute_name,attribute_manager)
      value = attribute_hash(owner)[attribute_name] || ''
      attribute_manager ? attribute_manager.assign(value) : value
    end

    def write(owner,attribute_name,value_param,attribute_manager)
      value = attribute_manager ? attribute_manager.assign(value_param).to_json : value_param.to_s
      !value._?.include?("\n") or raise ArgumentError, "Cannot store newlines in combined fields storing #{value.inspect} in #{attribute_name}"
      owner.instance_eval("@#{host_attribute}_combined_field_changes ||= {}")
      owner.instance_eval("@#{host_attribute}_combined_field_changes['#{attribute_name}'] = true")

      local_hash = attribute_hash(owner)
      local_hash[attribute_name] = value.to_s
      host_values = attributes.map { |attribute_name| local_hash[attribute_name] }
      owner.send(:write_attribute,host_attribute,host_values.join("\n"))
    end

    def changed?(owner,attribute_name,attribute_manager)
      owner.instance_eval("@#{host_attribute}_combined_field_changes ||= {}")
      owner.instance_eval("@#{host_attribute}_combined_field_changes['#{attribute_name}']")
    end

    def attribute_hash(owner)
      Hash[*attributes.zip(host_value(owner).split("\n")).flatten]
    end

    def host_value(owner)
      owner.read_attribute(host_attribute) || ""
    end
  end

  def combine_string_fields(attribute_list, options)
    combined_attribute = CombinedStringField.new(attribute_list.map{ |a| [a].flatten.first }, options[:store_on])

    attribute_list.each do |attribute_name|
      attribute_manager = nil
      if attribute_name.is_a?(Array)
        attribute_name, attribute_type = attribute_name
        attribute_manager = Aggregate::AttributeHandler.factory("", attribute_type, {})
      end

      define_method(attribute_name) do
        combined_attribute.read(self,attribute_name,attribute_manager)
      end

      define_method("#{attribute_name}=") do |value|
        combined_attribute.write(self,attribute_name,value,attribute_manager)
      end

      define_method("#{attribute_name}_changed?") do
        combined_attribute.changed?(self,attribute_name,attribute_manager)
      end
    end

    define_method("read_attribute") do |name|
      if name.in?(attribute_list.map{ |a| [a].flatten.first.to_s })
        send(name)
      else
        super(name)
      end
    end

    define_method("write_attribute") do |name,value|
      if name.in?(attribute_list.map{ |a| [a].flatten.first.to_s })
        send("#{name}=",value)
      else
        super(name, value)
      end
    end
  end
end
