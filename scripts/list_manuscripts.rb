#!/usr/bin/env ruby

exit # don't actually run; scratch code

require 'csv'
rows = []
header = %w{ id url shelfmark title created_at updated_at }
CSV do |row|
	row << header
	Manuscript.all.each do |ms| 
		data = []
		data << ms.id
		data << "https://biblio-philly-collations.herokuapp.com/manuscripts/xml/#{ms.id}?xml_type=filled_quires"
		data << ms.shelfmark
		data << ms.title
		data << ms.created_at
		data << ms.updated_at
		row << data
	end
end
