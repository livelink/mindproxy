require 'csv'

country_iso = ["SY", "CU", "IR"]
country_name = ["North Korea"]
subdivision = ["Crimea"]

geoname_ids = []
ip_blocks = []

CSV.foreach(('/Users/adamcathersides/Downloads/GeoLite2-City-CSV_20210713/GeoLite2-City-Locations-en.csv'), headers: false, col_sep:",") do |row|
  if country_iso.include? row[4] or country_name.include? row[5] or subdivision.include? row[7]
    puts "#{row[0]} - #{row[5]} - #{row[7]}"
    geoname_ids.push(row[0])
  end
end

CSV.foreach(('/Users/adamcathersides/Downloads/GeoLite2-City-CSV_20210713/GeoLite2-City-Blocks-IPv4.csv'), headers: false, col_sep: ",") do |row|
  if geoname_ids.include? row[1]
    ip_blocks.push(row[0])
  end
end

puts "Writing File.."
File.open('/tmp/sanction_ip_list.txt', 'w') do |f|
  ip_blocks.each do |block|
    f.write("acl is_sanctioned_ip src #{block}\n")
  end
end
