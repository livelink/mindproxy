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

Either country name *or* country ISO code *or* country subdivision can be specified.  The string must
match what is in the csv file.

The haproxy acl name can be overridden if required, it defaults to
`is_sanctioned_ip`.


## Example

A prerequisite is that the maxmind database csv file are downloaded in advance.
Grab them from [maxmind.com](https://www.maxmind.com/)

```
#Filter North Korea(KP), Cuba, and Crimea
./maxmind-haproxy-acl.rb -c /tmp/GeoLite2-City-CSV_20210713/GeoLite2-City-Locations-en.csv -i /tmp/GeoLite2-City-CSV_20210713/GeoLite2-City-Blocks-IPv4
.csv -a KP -n Cuba -s Crimea -o test.conf

head test.conf
acl is_sanctioned_ip src 5.59.104.0/24
acl is_sanctioned_ip src 5.62.56.73/32
acl is_sanctioned_ip src 5.62.56.74/31
acl is_sanctioned_ip src 5.62.56.160/30
acl is_sanctioned_ip src 5.62.58.69/32
acl is_sanctioned_ip src 5.62.58.70/31
acl is_sanctioned_ip src 5.62.61.64/30
acl is_sanctioned_ip src 5.101.208.0/21
acl is_sanctioned_ip src 31.3.24.0/21
acl is_sanctioned_ip src 31.40.128.70/32

```


## Tests

To run the test suite.

```
cd maxmind-haproxy-acl
rpsec
```

