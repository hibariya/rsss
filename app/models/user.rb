class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String
  field :bio,  type: String

  index :name, unique: true
  index :'tags.name'

  validates :name, presence: true, uniqueness: true, length: {maximum: 200}
  validates :url, allow_blank: true, format: URI.regexp(%w(http https)), length: {maximum: 200}
  validates :bio, length: {maximum: 400}

  embeds_many :tags, class_name: User::Tag.to_s do
    def names
      all.map(&:name)
    end

    def by_name_or_build(name)
      tags.where(name).first || build(name: name)
    end
  end

  embeds_many :related_users, class_name: User::RelatedUser.to_s do
    def by_name_or_build(name)
      tags.where(name).first || build(name: name)
    end
  end

  references_many :authentications

  references_many :sites do
    include Scorable

    def sync!
      threads = all.map {|site|
        Thread.fork do
          site.sync!
          Thread.pass
        end
      }

      threads.map(&:join)
    end

    def update_scores!
      volume_scores.zip(frequency_scores).map do |(site_id, volume), (_, frequency)|
        site = by_id(site_id)
        site.update_attributes! volume_score: volume, frequency_score: frequency
      end
    end

    def volume_scores
      volumes = all.inject({}) {|res, site|
        res[site.id] = site.articles.content_volume
        res
      }

      score volumes
    end

    def frequency_scores
      frequencies = all.inject({}) {|res, site|
        res[site.id] = site.articles.content_frequency
        res
      }

      score frequencies
    end

    def by_id(id)
      where(_id: site_id).first
    end

    def tags
      all.map(&:tags).flatten.compact
    end
  end

  module Scorable
    def score(list)
      values = list.values

      if values.uniq.length.pred.zero?
        _score_flatly list
      else
        _score list
      end
    end

    def _score(list)
      values = list.values
      max    = Math.sqrt(values.max)
      min    = Math.sqrt(values.min)
      factor = 24 / (max - min)

      list.inject({}) do |scores, (k, v)|
        scores[k] = ((Math.sqrt(v) - min) * factor).round
        scores
      end
    end

    def _score_flatly(list)
      list.inject({}) do |scores, (k, v)|
        scores[k] = 0
        scores
      end
    end
  end

  class << self
    # XXX メモ以上の価値はないのであった
    def reload_all!
      all.map do |user|
        user.sites.sync!
        user.sites.update_scores!
        user.reload_tags!
      end

      all.map &:reload_related_users!
    end
  end

  def reload_tags!
    frequencies = sites.tags.inject({}) {|res, tag|
      res[tag] ||= 0
      res[tag] +=  1
      res
    }

    frequencies.each do |name, frequency|
      tag = tags.by_name_or_build(name)
      tag.frequency = frequency
    end

    save!
    tags.not_in(name: sites.tags).map(&:destroy)
  end

  def reload_related_users!
    tag_names = tags.names
    users = User.any_in(:'tags.name' => tags.map(&:name)).excludes(_id: id)

    users.map do |user|
      related_user = related_users.by_name_or_build(user.name)
      matches = user.tags.names & tag_names
      related_user.frequency = matches.count
    end

    save!
    tags.not_in(name: users.map(&:name)).map(&:destroy)
  end
end
