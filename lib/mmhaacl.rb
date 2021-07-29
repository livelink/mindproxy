require 'csv'
require 'zip'
require 'httparty'
require 'date'
require 'tempfile'

class ConfigGen

  attr_reader :geoname_ids, :ip_blocks

  def initialize(countryiso:, countryname:, subdivision:, ipblockscsv:,
                 citycsv:, outputfile:, license:, dir:)
    @countryiso = countryiso
    @countryname = countryname
    @subdivision = subdivision
    @ipblockscsv = ipblockscsv.empty? ? "#{dir}/GeoLite2-City-Blocks-IPv4.csv" : ipblockscsv
    @citycsv = citycsv.empty? ? "#{dir}/GeoLite2-City-Locations-en.csv" : citycsv
    @geoname_ids = []
    @ip_blocks = []
    @outputfile = outputfile
    @license = license
    @uri = 'https://download.maxmind.com/app/geoip_download?' \
    "edition_id=GeoLite2-City-CSV&suffix=zip&license_key=#{@license}"
    @download_dir = dir
  end

  def get_geoname_ids
    begin
      CSV.foreach(@citycsv, headers: false, col_sep: ",") do |row|
        if @countryiso.include?(row[4])  ||
           @countryname.include?(row[5]) ||
           @subdivision.include?(row[7])
          @geoname_ids.push(row[0])
        end
      end
    rescue SystemCallError => e
      puts "Error opening file #{@citycsv}: #{e}"
      exit 1
    end
  end

  def get_ip_blocks
    begin
      CSV.foreach(@ipblockscsv, headers: false, col_sep: ",") do |row|
        if @geoname_ids.include?(row[1])
          @ip_blocks.push(row[0])
        end
      end
    rescue SystemCallError => e
      puts "Error opening file #{@ipblockscsv}: #{e}"
      exit 1
    end
  end

  def analyse_db
    puts 'Analysing maxmind database csv files'
    get_geoname_ids
    get_ip_blocks
  end

  def write_config
    puts "Writing haproxy acl file to #{@outputfile}"
    begin
      FileUtils.mkdir_p(File.dirname(@outputfile))
      File.open(@outputfile, 'w') do |f|
        @ip_blocks.each do |block|
          f.write("#{block}\n")
        end
      end
    rescue SystemCallError => e
      puts "Error writing file #{@outputfile}: #{e}"
      exit 1
    end
  end

  def check_latest_db
    begin
      headers = HTTParty.head(@uri)
    rescue HTTParty::Error => e
      puts "Error retrieving headers: #{e}"
      exit 1
    end

    begin
      DateTime.parse(headers['last-modified'])
    rescue DateTime::Error, TypeError => e
      puts 'Could not parse last-modified date from the headers.' \
        "\nProbably an error downloading the maxmind db." \
        "\nHeaders: #{headers}"
      exit 1
    end
  end

  def get_filename
    begin
      headers = HTTParty.head(@uri)
    rescue HTTParty::Error => e
      puts "Error retrieving headers: #{e}"
    end
    headers['content-disposition'].partition('=').last
  end

  def check_stored_db
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

  def update_required?
    begin
      stored_db_date = check_stored_db.to_date().to_s
    rescue NoMethodError => e
      stored_db_date = nil
    end
    latest_db_date = check_latest_db.to_date().to_s
    puts "Stored database date: #{stored_db_date}"
    puts "Latest database date: #{latest_db_date}"
    if stored_db_date.eql? latest_db_date
      false
    else
      true
    end
  end

  def grab_extract_db
    begin
      FileUtils.mkdir_p(@download_dir)
      Tempfile.create(['mm_db']) do |tempfile|
        body = HTTParty.get(@uri).body
        tempfile.write(body)
        tempfile.close
        Zip::File.open(tempfile.path) do |zip_file|
          # Overwrite existing files
          zip_file.restore_times = true
          Zip.on_exists_proc = true
          zip_file.glob('**/*.csv') do |csv|
              fpath = File.join(@download_dir, "#{csv}".partition('/').last)
              zip_file.extract(csv, fpath)
          end
        end
      end
    rescue HTTParty::Error => e
      puts "Error retrieving file from #{@uri}: #{e}"
      exit 1
    rescue Zip::Error => e
      puts "Cannot read maxmind zip file: #{e}"
    rescue Tempfile::Errno => e
      puts "Error creating tempfile: #{e}"
      exit 1
    end
  end
end


