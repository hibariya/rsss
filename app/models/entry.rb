# -*- encoding: utf-8 -*-

class Entry
  include Mongoid::Document

  field :title,      :type => String
  field :content,    :type => String
  field :categories, :type => Array
  field :link,       :type => String
  field :date,       :type => Time

  embedded_in :site, :inverse_of => :entries

  validates :title,
    :presence => true,
    :length => {:maximum=>200}
  validates :content,
    :length => {:maximum=>5000}
  validates :link,
    :presence => true,
    :length => {:maximum=>400},
    :format => URI.regexp(%w[http https])

  # for fabrication
  alias link_uri= link=
  alias link_uri link
  alias description content

  def image_sources
    @image_sources ||= self.content.scan(/(<img[^>]+>)/).
      flatten.compact.map{|m| m.scan(/src=['"]([^'"]+)['"]/) }.
      flatten.compact
  end

end

