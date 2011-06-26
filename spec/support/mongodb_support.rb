def clear_db
  Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop) rescue nil
end
