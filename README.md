# maxmind-haproxy-acl

A ruby script that parses the maxmind csv database files to produce a haproxy
compatible acl config file.

## Installation

Dependencies are specified in the Gemfile provided.
```
cd maxmind-haproxy-acl
bundle install
```

## Usage

```
./maxmind-haproxy-acl.rb -h
usage: ./maxmind-haproxy-acl.rb [options]
    -c, --citycsv      The maxmind city database csv
    -i, --ipblockscsv  The maxmind ip blocks database csv
    -a, --countryiso   The optional country code (ISO).
    -n, --countryname  The optional country name
    -s, --subdivision  A subdivision of a country. Eg Crimea
    -z, --aclname      The haproxy acl name string
    -o, --outputfile   The ouptut file
    -h, --help         Prints help message

```

## Example

A prerequisite is that the maxmind database csv file are downloaded in advance.
Grab them from [maxmind.com](https://www.maxmind.com/)

```
./maxmind-haproxy-acl.rb -c /tmp/GeoLite2-City-CSV_20210713/GeoLite2-City-Locations-en.csv -i /tmp/GeoLite2-City-CSV_20210713/GeoLite2-City-Blocks-IPv4
.csv -a UA,KP -s Crimea -o test.conf
```


## Tests

To run the test suite.

```
cd maxmind-haproxy-acl
rpsec
```

