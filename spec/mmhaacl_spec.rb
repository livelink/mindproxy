require 'mmhaacl'

describe ConfigGen do
  country_iso = ['CY']
  country_name = []
  subdivision = []

  before(:each) do
    @gen = ConfigGen.new(country_iso, country_name, subdivision)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids('./spec/city_test_data.csv')
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  country_iso = []
  country_name = ['Cyprus']
  subdivision = []

  before(:each) do
    @gen = ConfigGen.new(country_iso, country_name, subdivision)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids('./spec/city_test_data.csv')
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  country_iso = []
  country_name = []
  subdivision = ['Ammochostos']

  before(:each) do
    @gen = ConfigGen.new(country_iso, country_name, subdivision)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns geoname id 18918" do
        @gen.get_geoname_ids('./spec/city_test_data.csv')
        expect(@gen.geoname_ids).to eq(['18918'])
      end
    end
  end
end

describe ConfigGen do
  country_iso = []
  country_name = []
  subdivision = []
  geoname_ids = ['2077456']

  before(:each) do
    @gen = ConfigGen.new(country_iso, country_name, subdivision)
  end
  describe ".get_geoname_ids" do

    context "load csv" do
      it "returns 1.0.0.0/24" do
        @gen.get_ip_blocks('./spec/blocks_test_data.csv', geoname_ids)
        expect(@gen.ip_blocks).to eq(['1.0.0.0/24'])
      end
    end
  end
end
