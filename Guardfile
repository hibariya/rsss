# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork' do
  watch(%r{^app/[^#]*\.rb$})
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
  watch('spec/spec_helper.rb')
end

guard 'rspec', version: 2, rvm: '1.9.2-p180', cli: '--drb --format=Fuubar' do
  watch(/^spec\/(.*)_spec.rb/)
  watch(/^lib\/(.*)\.rb/)                               {|m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper.rb/)                        { "spec" }
  watch(/^app\/controllers\/application_controller.rb/) { "spec/controllers" }
  watch(/^app\/controllers\/(.*).rb/)                   {|m| "spec/controllers/#{m[1]}_spec.rb" }
  watch(/^app\/models\/(.*).rb/)                        {|m| "spec/models/#{m[1]}*" }
  watch(/^app\/helpers\/(.*).rb/)                       {|m| "spec/helpers/#{m[1]}_spec.rb"  }
  watch(/^spec\/fabricators*/)                          { "spec/models" }
end


