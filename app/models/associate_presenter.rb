class AssociatePresenter
  attr_accessor :associate

  def initialize(associate)
    @associate = associate
  end

  def summary
    summaries.last
  end

  def summaries
    associate_summaries.sort_by{|s| s.date }
  end

  def method_missing(name, *args)
    summary.send name, *args rescue @associate.send name, *args
  end

  class << self
    def method_missing(name, *args)
      Associate.send name, *args
    end
  end

  private
    def associate_summaries
      @associate.user.associate_summaries.where(:associate_id => @associate.id)
    end
end
