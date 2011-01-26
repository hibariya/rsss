class ErrorLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :error_type, :type=>String
  field :message, :type=>String
  field :backtrace, :type=>Array

  LOG_MAXIMUM = 100

  class << self
    def add(e)
      destroy_over LOG_MAXIMUM-1
      self.create :error_type=>e.class,
        :message=>e.message,
        :backtrace=>e.backtrace
    end

    def destroy_over(maximum)
      order_by(:created_at.desc).skip(maximum).map(&:destroy)
    end
  end
end
