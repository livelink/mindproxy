require 'csv'

# country_iso = ["SY", "CU", "IR"]
# country_name = ["North Korea"]
# subdivision = ["Crimea"]

# geoname_ids = []
# ip_blocks = []

class ConfigGen

  attr_reader :geoname_ids, :ip_blocks

  def initialize(country_iso, country_name, subdivision)
    @country_iso = country_iso
    @country_name = country_name
    @subdivision = subdivision
    @geoname_ids = []
    @ip_blocks = []
  end

  def get_geoname_ids(csvfile)
    CSV.foreach(csvfile, headers: false, col_sep: ",") do |row|
      if @country_iso.include?(row[4]) || @country_name.include?(row[5]) || @subdivision.include?(row[7])
        @geoname_ids.push(row[0])
      end
    end
    @geoname_ids
  end

  def get_ip_blocks(csvfile, geoname_ids)
    CSV.foreach(csvfile, headers: false, col_sep: ",") do |row|
      if geoname_ids.include?(row[1])
        @ip_blocks.push(row[0])
      end
    end
  end
  #
  # puts "Writing File.."
  # File.open('/tmp/sanction_ip_list.txt', 'w') do |f|
  #   ip_blocks.each do |block|
  #     f.write("acl is_sanctioned_ip src #{block}\n")
  #   end
  # end
  #
end


