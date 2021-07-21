#!/usr/bin/env ruby

require 'slop'
require_relative 'lib/mmhaacl'

opts = Slop.parse suppress_errors: true do |o|
  o.string '-c', '--citycsv', 'The maxmind city database csv'
  o.string '-i', '--ipblockscsv', 'The maxmind ip blocks database csv'
  o.array '-a', '--countryiso', 'The optional country code (ISO).', default: [], delimiter: ','
  o.array '-n', '--countryname', 'The optional country name', default: [], delimiter: ','
  o.array '-s', '--subdivision', 'A subdivision of a country. Eg Crimea', default: [], delimiter: ','
  o.string '-z', '--aclname', 'The haproxy acl name string', default: 'is_sanctioned_ip'
  o.string '-o', '--outputfile', 'The ouptut file'
  o.string '-l', '--license', 'A maxmind license key', default: ENV['MAXMIND_LICENSE_KEY']
  o.string '-d', '--dir', 'The directory to download to', default: '/tmp'
  o.on '-h', '--help', 'Prints help message' do
    puts o
    exit
  end
end

options = opts.to_hash

generator = ConfigGen.new(**options)
# generator.write_config()
generator.grab_extract_db
