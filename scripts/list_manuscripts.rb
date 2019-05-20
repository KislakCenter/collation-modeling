#!/usr/bin/env ruby

exit # don't actually run; scratch code

# URL = "https://biblio-philly-collations.herokuapp.com"
URL = "https://protected-island-3361.herokuapp.com"

require 'csv'
rows = []
header = %w{ id url shelfmark title created_at updated_at }
CSV do |row|
	row << header
	Manuscript.all.each do |ms|
		data = []
		data << ms.id
		data << "#{URL}/manuscripts/xml/#{ms.id}?xml_type=filled_quires"
		data << ms.shelfmark
		data << ms.title
		data << ms.created_at
		data << ms.updated_at
		row << data
	end
end
