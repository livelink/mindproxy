#!/usr/bin/env ruby

require 'slop'
require_relative 'lib/mmhaacl'

begin
  opts = Slop.parse do |o|
    o.string '-c', '--citycsv', 'The maxmind city database csv', default: ''
    o.string '-i', '--ipblockscsv', 'The maxmind ip blocks database csv', default: ''
    o.array '-a', '--countryiso', 'The optional country code (ISO).Has to match code in csv', default: [], delimiter: ','
    o.array '-n', '--countryname', 'The optional country name. Has to match name in csv', default: [], delimiter: ','
    o.array '-s', '--subdivision', 'A subdivision of a country. Has to match name in csv. Eg Crimea', default: [], delimiter: ','
    o.string '-o', '--outputfile', 'The ouptut file', default: '/tmp/mindproxy_acl.lst'
    o.string '-l', '--license', 'A maxmind license key', default: ENV['MAXMIND_LICENSE_KEY']
    o.string '-d', '--dir', 'The directory to download the maxmind db to', default: '/tmp/maxmind_db'
    o.bool '-f', '--force', 'Force analysis even if database is up-to-date', default: false
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
options.delete(:force)

if opts[:countryname].empty? && opts[:countryiso].empty? && opts[:subdivision].empty?
  puts 'You need to specify at least a countryname, countryiso or subdivision'
  exit 1
end
generator = ConfigGen.new(**options)

# If maxmind license key is supplied check for any updates first. Otherwise use
# the files are are supplied.
if opts[:license]
  if generator.update_required?
    puts 'MaxMind database out of date or non existent. Downloading...'
    generator.grab_extract_db
    generator.analyse_db
  elsif opts[:force]
    puts 'Forcing analysis, even though maxmind db is up-to-date'
    generator.analyse_db
  else
    puts 'MaxMind database is up to date! Skipping download and exiting'
    exit 0
  end
  generator.write_config
else
  generator.analyse_db
  generator.write_config
end
