require 'mmhaacl.rb'

RSpec.describe get_geoname_ids do
  It 'retreives ids from the csv' do
    ids = get_geoname_ids('city_test_data.csv')
    expect(ids).to equal([])
  end
end
