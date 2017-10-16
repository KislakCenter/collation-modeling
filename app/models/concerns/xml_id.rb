require 'active_support/concern'

module XmlID
  extend ActiveSupport::Concern
  included do
    def xml_id
      "#{self.class.name.underscore}-#{id || object_id}"
    end
  end
end
