require 'csv'
require 'zip'
require 'httparty'
require 'date'

class ConfigGen

  attr_reader :geoname_ids, :ip_blocks

  def initialize(countryiso:, countryname:, subdivision:, ipblockscsv:,
                 citycsv:, outputfile:, aclname:, license:, download_dir:)
    @countryiso = countryiso
    @countryname = countryname
    @subdivision = subdivision
    @ipblockscsv = ipblockscsv
    @citycsv = citycsv
    @geoname_ids = []
    @ip_blocks = []
    @outputfile = outputfile
    @acl_name = aclname
    @license = license
    @uri = "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=#{@license}"
    @download_dir = download_dir
  end

  def get_geoname_ids()
    begin
      CSV.foreach(@citycsv, headers: false, col_sep: ",") do |row|
        if @countryiso.include?(row[4]) || @countryname.include?(row[5]) || @subdivision.include?(row[7])
          @geoname_ids.push(row[0])
        end
      end
    rescue SystemCallError => e
      puts "Error opening file #{@citycsv}: #{e}"
      exit
    end
  end

  def get_ip_blocks()
    begin
      CSV.foreach(@ipblockscsv, headers: false, col_sep: ",") do |row|
        if @geoname_ids.include?(row[1])
          @ip_blocks.push(row[0])
        end
      end
    rescue SystemCallError => e
      puts "Error opening file #{@ipblockscsv}: #{e}"
      exit
    end
  end

  def write_config()
    puts 'Analysing maxmind database csv files'
    get_geoname_ids()
    get_ip_blocks()
    puts 'Writing haproxy acl file..'
    begin
      File.open(@outputfile, 'w') do |f|
        @ip_blocks.each do |block|
          f.write("acl #{@acl_name} src #{block}\n")
        end
      end
    rescue SystemCallError => e
      puts "Error writing file #{@outputfile}: #{e}"
      exit
    end
  end

  def check_latest_db()
    begin
      headers = HTTParty.head(@uri)
    rescue HTTParty::Error => e
      puts "Error retrieving headers: #{e}"
    end

    begin
      DateTime.parse(headers['last-modified'])
    rescue DateTime::Error => e
      puts "Could not parse date string"
    end
  end

  def check_stored_db()
    begin
      DateTime.parse(File.mtime("#{@download_dir}/GeoLite2-City-Locations-en.csv").to_s)
    rescue Errno::ENOENT => e
      puts "File or directory #{@download_dir}/GeoLite2-City-Locations-en.csv doesn't exist."
      nil
    rescue Errno::EACCES => e
      puts "Can't read from #{@download_dir}/GeoLite2-City-Locations-en.csv. No permission."
      exit 1
    end
  end

  def download_csv_db()
  end
end

