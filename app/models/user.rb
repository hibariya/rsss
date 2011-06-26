class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :url,  type: String
  field :bio,  type: String

  index :name, unique: true

  validates :name, presence: true, uniqueness: true, length: {maximum: 200}
  validates :url, format: URI.regexp(%w(http https)), length: {maximum: 200}
  validates :bio, length: {maximum: 400}

  embeds_many :tags
  embeds_many :related_users

  references_many :authentications
  references_many :sites do
    def sync!
      threads = all.map {|site|
        Thread.fork do
          site.sync!
          Thread.pass
        end
      }

      threads.map(&:join)
    end

    def update_scores
      volume_scores.zip(frequency_scores).map do |site_id, volume, _, frequency|
        site = where(_id: site_id).first
        site.update_attributes! volume_score: volume, frequency_score: frequency
      end
    end

    def volume_scores
      volumes = all.inject({}) {|res, site|
        res[c.id] = site.articles.content_volume
        res
      }

      score volumes
    end

    def frequency_scores
      frequencies = all.inject({}) {|res, site|
        res[c.id] = site.articles.content_frequency
        res
      }

      score frequencies
    end

    private

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
end
