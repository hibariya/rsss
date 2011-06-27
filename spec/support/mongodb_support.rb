def clear_db
  Mongoid.master.collections.select { |c| c.name !~ /system/ }.each(&:drop) rescue nil
end
