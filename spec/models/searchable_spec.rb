#class SearchableDummyModel < ActiveRecord::Base
#  def self.columns() @columns ||= []; end
#
#  def self.column(name, sql_type=nil, default=nil, null=true)
#    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
#  end
#
#  column :email, :string
#  column :name, :string
#end

module SearchableTestModels
  module Nothing
  end
end

module Walkable
  extend ActiveSupport::Concern
  def self.included(base)
    def has_pavement?; 'paved' end
  end

  module ClassMethods
    def has_sidewalk?;  'luke sidewalker' end
  end
end

class Strasse
  def district=(val); @district=val end
  def district; @district end
  def name=(val); @name=val end
  def name; @name end
  def self.type; 'street' end
end

class Address < Strasse
  def initialize(a,b)
    @name=a
    @number=b
  end
  def number=(val); @number=val end
  def number; @number end
  def to_s; "Address is #{name} #{number}, #{district}" end
end

describe 'Searchability' do
  before(:each) do
    stub_const 'Dummy', Class.new(ActiveRecord::Base)
    Dummy.class_eval do
      def self.columns() @columns ||= []; end
    
      def self.column(name, sql_type=nil, default=nil, null=true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end
    
      column :email, :string
      column :name, :string
    end
  end

  context 'on a dummy model' do
    before(:each) do
      Dummy.class_eval do
        include Searchengine::Concerns::Models::Searchable
      end
#      SearchableDummyModel.class_eval do 
#      #  searchable as: 'Dumdum' do |dum| # `as: 'Dumdum'` part is optional
#      #    def greet; 'hi' 
#      #    field: :email, type: 'email'
#      #    field: :name # defaults to string
#      #  end
#      end
#      stub_const 'Dummy', SearchableDummyModel
    end

    it 'exposes the searchability descriptor' do
      expect(Dummy).to respond_to(:searchable_as)
    end

    context "sets the searchindex name" do
      it 'to the default name on #searchable' do
        expect{ 
          Dummy.searchable { p 'hi'} 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include("#{Dummy.name}Index")
      end
  
      it 'to the specified name' do
        expect{ 
          Dummy.searchable_as('Attrappe') { p 'ho' } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include('AttrappeIndex')
      end
    end

    it 'responds to #email' do
      expect(Dummy.new).to respond_to(:email)
    end

    it 'has a model that respects the concerns' do
      Strasse.class_eval do
        include Walkable
      end
      expect(Strasse).to respond_to :has_sidewalk?
      expect(Strasse).not_to respond_to :has_pavement?
      expect(Strasse.new).to respond_to :has_pavement?
    end

    it 'interrogates objects' do
      old_address = 'Eichendorffstraße 18'
      new_address = 'Novalisstraße 12'

      klass = Class.new(Strasse)
      klass.class_eval do
        def initialize(a,b)
          @name=a
          @number=b
        end
        def to_s; "Adresse est #{name} #{@number}, #{district}" end
      end

      first = Address.new(*old_address.split)
      expect(first.class.superclass).to equal(Strasse)
      expect(first.number).to eq(old_address.split.last)
      expect(first.name).to eq(old_address.split.first)
      expect(first.class.type).to eq(Strasse.type)

      second = klass.new(*new_address.split)
      expect(second.class.superclass).to equal(Strasse)
      expect(second.name).to eq(new_address.split.first)
      expect(second.class.type).to eq(Strasse.type)
    end

    it 'is named' do
      SearchableTestModels.const_set("Dummy", Class.new(Strasse))
      #p SearchableTestModels::Dummy
    end
  end
end