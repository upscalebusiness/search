require 'rails_helper'

RSpec.describe ShowsController, type: :controller do
  before(:all) do
    Chewy.massacre

    Show.search_index.create!

    puts "before #{Show.search_type.query(query_string: { query: 'hous*' }).total_count}"

    Show.create name: 'Fringe', producer: 'J.J. Abrams', piloted_at: DateTime.now
    Show.create name: 'The Wire', producer: 'David Simon', piloted_at: DateTime.now
    Show.create name: 'Game of Thrones', producer: 'Beinoff & Weiss', piloted_at: DateTime.now
    Show.create name: 'Sherlock', producer: 'Moffat & Gatiss', piloted_at: DateTime.now
    Show.create name: 'House of Cards', producer: 'Beau Willimon', piloted_at: DateTime.now
    Show.create name: 'Little House on the Prairie', producer: 'Michael Landon', piloted_at: DateTime.now
    Show.search_type.import! refresh: :true
    for i in 0..10
      if Show.search_type.query(query_string: { query: 'hous*' }).total_count == 2
        puts "data integrity achieved after attempt #{i}"
        break
      end
    end
    puts "after #{Show.search_type.query(query_string: { query: 'hous*' }).total_count}"
  end

  after(:all) do
    Show.destroy_all
  end

  describe "GET /index" do
    before { get :index }

    it 'returns a list of the shows' do
      expect(json_response.length).to eq(Show.count)
    end
  end

  describe "GET /query" do
    before { get :query, { q: 'hous*' } }

    it 'contains the matching items' do
      puts request.url
      expect(json_response[:responseData][:count]).to eq(2)
    end
  end
end
