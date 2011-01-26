# -*- coding: utf-8 -*-

if %(development test).include? Rails.env
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    config.data_directory = File.join(Rails.root, 'tmp', 'metric_fu', '_data')
    config.rcov = {:environment => 'test',
      :test_files => ['spec/**/*_spec.rb'],
      :rcov_opts => ["--sort coverage",
        "--no-html",
        "--text-coverage",
        "--no-color",
        "--profile",
        "--rails",
        "--exclude /gems/,/Library/,/usr/,spec"],
        :external => nil
    }
    config.flay ={:dirs_to_flay => %w(app lib),
      :minimum_score => 25,
      :filetypes => %w(rb) }
  end
end
