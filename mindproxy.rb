#!/usr/bin/env ruby

require 'slop'
require_relative 'lib/mmhaacl'

begin
  opts = Slop.parse do |o|
    o.string '-c', '--citycsv', 'The maxmind city database csv', default: '/tmp/maxmind_db/GeoLite2-City-Locations-en.csv'
    o.string '-i', '--ipblockscsv', 'The maxmind ip blocks database csv', default: '/tmp/maxmind_db/GeoLite2-City-Blocks-IPv4.csv'
    o.array '-a', '--countryiso', 'The optional country code (ISO).', default: [], delimiter: ','
    o.array '-n', '--countryname', 'The optional country name', default: [], delimiter: ','
    o.array '-s', '--subdivision', 'A subdivision of a country. Eg Crimea', default: [], delimiter: ','
    o.string '-z', '--aclname', 'The haproxy acl name string', default: 'is_sanctioned_ip'
    o.string '-o', '--outputfile', 'The ouptut file', default: '/tmp/mindproxy_acl.config'
    o.string '-l', '--license', 'A maxmind license key', default: ENV['MAXMIND_LICENSE_KEY']
    o.string '-d', '--dir', 'The directory to download to', default: '/tmp/maxmind_db'
    o.on '-h', '--help', 'Prints help message' do
      puts o
      exit
    end
  end
rescue Slop::UnknownOption => e
  puts e
  exit 1
end

if ARGV.length == 0
  puts opts
  exit 1
end

options = opts.to_hash

generator = ConfigGen.new(**options)
if generator.update_required?
  puts "Database out of date or non existent. Will download update.."
  generator.grab_extract_db
else
  puts "Database is up to date.  Skipping download"
end
generator.write_config
