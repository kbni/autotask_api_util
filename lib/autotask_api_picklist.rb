# Add Picklist functionality to AutotaskAPI::Client for immediate-ish lookup
# of types, etc. for queries
module AutotaskAPI
  class PicklistHelper
    attr_accessor :client
    def initialize(client)
      self.client = client
    end
    
    def method_missing(method_sym, *arguments, &block)
      ret = self.client.picklist["#{method_sym}"]
      if ret == nil then
        super
      else
        ret
      end
    end
  end
  
  class Client
    def get_picklist(entity_name)
      @picklist ||= Hash.new
      res = savon_client.call :get_field_info,
        message: "<psObjectType>#{entity_name}</psObjectType>",
        attributes: { xmlns: NAMESPACE }
      res.xpath(
        "//Autotask:Field[./Autotask:IsPickList='true']",
        Autotask: NAMESPACE).collect do |f|
        field_name = f.xpath('./Autotask:Name', Autotask: NAMESPACE).text
        f.xpath('.//Autotask:PickListValue', Autotask: NAMESPACE).collect do |p|
          label = p.xpath('./Autotask:Label', Autotask: NAMESPACE).text
          value = p.xpath('./Autotask:Value', Autotask: NAMESPACE).text
          label = label.gsub(/[^a-zA-Z0-9_]/, '')
          @picklist["#{entity_name}_#{field_name}_#{label}"] = value
        end
      end
    end
    
    def pl
      @helper ||= PicklistHelper.new(self)
      @helper
    end
    
    def picklist
      @picklist
    end
  end
end