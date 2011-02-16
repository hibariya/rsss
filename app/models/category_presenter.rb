class CategoryPresenter
  attr_accessor :category

  def initialize(category, user=nil)
    @category, @user = category, user
  end

  def summary
    summaries.last
  end

  def summaries
    category_summaries.sort_by{|s| s.date }
  end

  def user
    @user ||= category.user
  end

  # TODO: remove 
  def method_missing(name, *args)
    @category.respond_to?(name)?
      @category.send(name, *args):
      summary.send(name, *args)
  end

  private
    def category_summaries
      user.category_summaries.where(:category_id => @category.id)
    end
end
