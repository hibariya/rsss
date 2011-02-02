class CategoryPresenter
  attr_accessor :category

  def initialize(category)
    @category = category
  end

  def summary
    summaries.last
  end

  def summaries
    category_summaries.sort_by{|s| s.date }
  end

  def method_missing(name, *args)
    summary.send name, *args rescue @category.send name, *args
  end

  class << self
    def method_missing(name, *args)
      Category.send name, *args
    end
  end

  private
    def category_summaries
      @category.user.category_summaries.where(:category_id => @category.id)
    end
end
