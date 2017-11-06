require 'active_support/concern'

module XmlID
  extend ActiveSupport::Concern
  included do
    def xml_id
      return "#{self.class.name.underscore}-#{id}" if id.present?
      "#{self.class.name.underscore}-o#{object_id}"
    end
  end
end
