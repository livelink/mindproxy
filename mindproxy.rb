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
    o.string '-o', '--outputfile', 'The ouptut haproxy config file', default: '/tmp/mindproxy_acl.config'
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
  exit 0
end

options = opts.to_hash

if options[:countryname].empty? && options[:countryiso].empty? && options[:subdivision].empty?
  puts 'You need to specify at least a countryname, countryiso or subdivision'
  exit 1
end
generator = ConfigGen.new(**options)

# If maxmind license key is supplied check for any updates first. Otherwise use
# the files are are supplied.
if options[:license]
  if generator.update_required?
    puts 'MaxMind database out of date or non existent. Downloading...'
    generator.grab_extract_db
  else
    puts 'MaxMind database is up to date! Skipping download.'
  end
  generator.write_config
else
  generator.write_config
end
