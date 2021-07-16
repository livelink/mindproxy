require 'mmhaacl'

describe ConfigGen do
  # country_iso = ['CY']
  # country_name = []
  # subdivision = []

  options = {countryiso: ['CY'], countryname: [], subdivision: [],
             citycsv: './spec/city_test_data.csv', ipblockscsv: '',
             aclname: '', outputfile: ''}

  before(:each) do
    @gen = ConfigGen.new(options)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids()
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  # country_iso = []
  # country_name = ['Cyprus']
  # subdivision = []

  options = {countryiso: [], countryname: ['Cyprus'], subdivision: [],
             citycsv: './spec/city_test_data.csv', ipblockscsv: '',
             aclname: '', outputfile: ''}
  before(:each) do
    @gen = ConfigGen.new(options)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids()
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  # country_iso = []
  # country_name = []
  # subdivision = ['Ammochostos']

  options = {countryiso: [], countryname: ['Cyprus'], subdivision: [],
             citycsv: './spec/city_test_data.csv', ipblockscsv: '',
             aclname: '', outputfile: ''}
  before(:each) do
    @gen = ConfigGen.new(options)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids()
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  geoname_ids = ['2077456']

  options = {countryiso: [], countryname: [], subdivision: [],
             citycsv: '', ipblockscsv: './spec/blocks_test_data.csv',
             aclname: '', outputfile: ''}
  before(:each) do
    @gen = ConfigGen.new(options)
  end

  describe ".get_ip_blocks" do

    context "load csv" do
      it "returns 1.0.0.0/24" do
        @gen.get_ip_blocks(geoname_ids)
        expect(@gen.ip_blocks).to eq(['1.0.0.0/24'])
      end
    end
  end
end
