#!/usr/bin/env ruby

require 'csv'

# https://biblio-philly-collations.herokuapp.com/manuscripts/xml/154?xml_type=filled_quires

HOST = "https://biblio-philly-collations.herokuapp.com/"

PATTERN = "manuscripts/xml/ID_GOES_HERE?xml_type=filled_quires"

OUT_DIR = "#{ENV['HOME']/tmp/bphil}"
fail "OUT_DIR doesn't exist: #{OUT_DIR}" unless File.directory? OUT_DIR

input_csv = ARGV.shift

fail "Need value CSV, not #{input_csv.inspect}" unless File.exists? input_csv

CSV.foreach input_csv do |row|
  id = row[0]
  next if id == 'ID'
  raise "ID is not an integer: #{id}" unless id.to_s =~ /\A\d+\z/
  file_name_string = row[1]
  file_name = "#{file_name_string.strip.gsub(/[^[:alnum:]]+/, '_')}.xml"
  url = "#{HOST}/#{PATTERN.sub(/ID_GOES_HERE/, id)}"
  puts %x{curl -o #{OUT_DIR}/#{file_name} "#{url}"}
  sleep 1
end

