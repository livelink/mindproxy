require 'mmhaacl'
require 'webmock/rspec'
require 'date'

describe ConfigGen do
  options = {countryiso: ['CY'], countryname: [], subdivision: [],
             citycsv: './spec/GeoLite2-City-Locations-en.csv', ipblockscsv: '',
             aclname: '', outputfile: '', license: '', dir: ''}

  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.get_geoname_ids' do

    context 'filter with countryiso' do
      it 'returns geoname id 18918' do
        @gen.get_geoname_ids()
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  options = { countryiso: [], countryname: ['Cyprus'], subdivision: [],
             citycsv: './spec//GeoLite2-City-Locations-en.csv', ipblockscsv: './spec/GeoLite2-City-Blocks-IPv4.csv',
             aclname: '', outputfile: '', license: '', dir: '' }
  before(:context) do
    @gen = ConfigGen.new(**options)
  end
  describe '.get_geoname_ids' do
    context 'filter with countryname' do
      it 'returns geoname id 18918' do
        @gen.get_geoname_ids()
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
    context 'get ip block for geoname_id 18918' do
      it 'returns 1.0.0.0/24' do
        @gen.get_ip_blocks()
        expect(@gen.ip_blocks).to eq(['1.0.0.0/24'])
      end
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: ''}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.check_latest_db' do
    it 'returns a DateTime object' do
      stub_request(:head, "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=").
        to_return(status: 200, body:"", headers: { 'last-modified':'Tue, 13 Jul 2021 02:33:26 GMT' })
      expect(@gen.check_latest_db()).to be_an_instance_of(DateTime)
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: ''}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.get_filename' do
    it 'returns filename as specified in header' do
      stub_request(:head, "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=").
        to_return(status: 200, body:"", headers: {'content-disposition': 'attachment; filename=GeoLite2-City-CSV_20210720.zip'})
      expect(@gen.get_filename).to eq('GeoLite2-City-CSV_20210720.zip')
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: 'spec'}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.check_stored_db' do
    it 'returns a DateTime object' do
      expect(@gen.check_stored_db()).to be_an_instance_of(DateTime)
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: 'does_not_exist'}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.check_stored_db' do
    context 'when file does not exist' do
      it 'returns nil' do
        expect(@gen.check_stored_db()).to equal(nil)
      end
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: ''}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  describe '.update_required?' do
    context 'when dates match' do
      it "return false" do
        stub_request(:head, 'https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=').
        to_return(status: 200, body:"", headers: { 'last-modified':'Tue, 13 Jul 2021 02:33:26 GMT' })

        allow(@gen).to receive(:check_stored_db).and_return(DateTime.parse('Tue, 13 Jul 2021 02:33:26 GMT'))
        expect(@gen.update_required?).to equal(false)
      end
    end
    context 'when dates do not match' do
      it 'return true' do
        stub_request(:head, "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=").
        to_return(status: 200, body:"", headers: { 'last-modified':'Tue, 13 Jul 2021 02:33:26 GMT' })

      allow(@gen).to receive(:check_stored_db).and_return(DateTime.parse('Tue, 14 Jul 2021 02:33:26 GMT'))
      expect(@gen.update_required?).to equal(true)
      end
    end
  end
end

describe ConfigGen do
  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: '', aclname: '', outputfile: '',
             license: '', dir: 'extract_test/maxmind_db'}
  before(:each) do
    @gen = ConfigGen.new(**options)
  end
  after(:each) do
    FileUtils.rm_rf(options[:dir])
  end
  zip = File.open('spec/test.zip', 'rb')
  zip_data = zip.read
  zip.close
  describe '.grab_extract_db' do
    it 'extracts csv files from zip' do
      stub_request(:get, "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&suffix=zip&license_key=").
        to_return(status: 200, body: zip_data, headers: {'content-type': 'application/zip'})
      @gen.grab_extract_db
      expect(Dir.entries("#{options[:dir]}")).to include('GeoLite2-City-Blocks-IPv4.csv')
    end
  end
end
