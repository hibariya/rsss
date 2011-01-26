guard 'spork' do
  watch('^app/*')
  watch('^lib/*')
  watch('^config/application.rb$')
  watch('^config/environment.rb$')
  watch('^config/environments/.*\.rb$')
  watch('^config/initializers/.*\.rb$')
  watch('^spec/spec_helper.rb')
  watch('^spec/fabricators*')
end

guard 'rspec', :version=>2, :drb=>true, :rvm=>'1.9.2', :fail_fast=>true do
  watch('^spec/(.*)_spec.rb')
  watch('^lib/(.*)\.rb'){|m| "spec/lib/#{m[1]}_spec.rb" }
  watch('^spec/spec_helper.rb'){ "spec" }
  watch('^app/controllers/application_controller.rb') { "spec/controllers" }
  watch('^app/controllers/(.*).rb'){|m| "spec/controllers/#{m[1]}_spec.rb" unless m[1] == 'application_controller' }
  watch('^app/models/(.*).rb'){|m| "spec/models/#{m[1]}*" }
  watch('^app/views/(.*)/*'){|m| "spec/acceptance/*#{m[1]}*" }
  watch('^app/helpers/(.*).rb'){|m| "spec/helpers/#{m[1]}_spec.rb" }
  watch('^spec/fabricators*'){ "spec/models" }
end


