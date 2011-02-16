class AssociatePresenter
  attr_accessor :associate

  def initialize(associate, user=nil)
    @associate, @user = associate, user
  end

  def summary
    summaries.last
  end

  def summaries
    associate_summaries.sort_by{|s| s.date }
  end

  def user
    @user ||= associate.user
  end

  # TODO: remove 
  def method_missing(name, *args)
    @associate.respond_to?(name)?
      @associate.send(name, *args):
      summary.send(name, *args)
  end

  private
    def associate_summaries
      user.associate_summaries.where(:associate_id => @associate.id)
    end
end
