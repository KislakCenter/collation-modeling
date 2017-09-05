require 'active_support/concern'

module XmlID
  extend ActiveSupport::Concern
  included do
    def xml_id
      "#{self.class.name.underscore}-#{self.id}"
    end
  end
end
