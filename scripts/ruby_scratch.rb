##/usr/bin/env ruby

exit

cutoff = Date.new 2017, 9, 1

mss = Manuscript.where('updated_at < ?', cutoff).select { |ms|
  ms.leaves.all? { |leaf| leaf.updated_at < cutoff }
}

s = CSV.generate do |csv|
  mss.each do |m|
    csv << [m.id, m.shelfmark, m.title, m.created_at, m.updated_at]
  end
end

ids = mss.map &:id

Manuscript.where(id: ids).destroy_all
