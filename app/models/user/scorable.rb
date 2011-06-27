module User::Scorable
  def score(list)
    values = list.values

    if values.empty? || values.uniq.length.pred.zero?
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
