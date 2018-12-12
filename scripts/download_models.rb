#!/usr/bin/env ruby

require 'open-uri'
require 'csv'
require 'pry'

CSV.foreach ARGV.shift, headers: true do |row|
  data = open(row['url']).read
  outfile = "tmp/leaves/#{row['shelfmark'].gsub(/\W+/, '_')}-#{row['id']}.xml"
  File.open(outfile, 'w+') { |f| f.puts data }
  puts "Wrote: '#{outfile}'"
end

