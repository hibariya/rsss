# = Rsss::Summary 
#
# == Example
#
#   class Color
#     include Mongoid::Document
#     field :name, :type=>String
#     field :score, :type=>Float
#   end
#
#   class ColorSummary
#     include Mongoid::Document
#     include Rsss::Summary
#     
#     field :color_id, :type=>BSON::ObjectId
#     field :popularity, :type=>Fixnum
#
#     max_documents 30
#   end
#
#   ColorSummary.max_documents       # => 30
#
# == Date field
#
#   Color.new.attributes.keys        # => ["_id", "name", "score"]
#   ColorSummary.new.attributes.keys # => ["_id", "date", "color_id", "popularity"]
#
#   color = Color.create :name=>'green', :score=>10.5
#
#   color_summary = ColorSummary.create :color_id=>color.id, :popularity=>10
#   Date.today         # => Sun, 16 Jan 2011
#   color_summary.date # => Sun, 16 Jan 2011
#
# == Reference Object Finder
#
#   color_summary.color      == color # => true
#   color_summary.references == color # => true
#
# == Delete the overflowing document
#
#   100.times do |t| 
#     ColorSummary.create :color_id=>color.id, :popularity=>10, :date=>t.days.ago.to_date
#   end
#
#   ColorSummary.count         # => 30
#   ColorSummary.max_documents # => 30
#
# == Delete the duplicating document
#
#   100.times do
#     ColorSummary.create :color_id=>color.id, :popularity=>10, :date=>Date.today
#   end
#
#   ColorSummary.all.select{|cs| cs.ate == Date.today }.length # => 1
#
module Rsss::Summary
  def self.included model
    model.instance_eval do
      include Mongoid::Document
      field :date, :type => Date

      extend  ClassMethods
      include Methods

      before_create :set_default_date,  :load_duplicates
      after_create  :delete_duplicates, :delete_overflows
    end
  end

  module Methods
    def references_key
      self.class.references_key
    end

    def max_documents
      self.class.max_documents
    end

    def references
      self.class.references.find attributes[references_key]
    end

  private

    def where *args
      self.class.where *args
    end

    def load_duplicates
      @duplicates = where(references_key=>attributes[references_key]).
                    where(:date => date).reject{|d| d == self }
    end

    def delete_duplicates
      @duplicates.map &:delete
    end

    def delete_overflows
      summaries = where references_key=>attributes[references_key]
      overflow = summaries.reverse[max_documents..-1]
      overflow.map &:delete if overflow
    end

    def set_default_date
      self.date ||= Date.today
    end

    def method_missing m, *args
      return references if m.to_s.classify == self.class.references_name
      super
    end
  end


  module ClassMethods
    def max_documents max=nil
      @max_documents = max || @max_documents
    end

    def references_key
      @references_key ||= "#{references_name.underscore}_id".intern
    end

    def references_name
      @references_name ||= model_name.scan(/^[A-Z0-9]+[a-z0-9]+/).first
    end

    def references
      @references ||= Object.const_get references_name
    end
  end
end
