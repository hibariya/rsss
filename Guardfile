guard 'spork' do

  watch /^app\/*/

  watch /^lib\/*/

  watch /^config\/application.rb$/

  watch /^config\/environment.rb$/

  watch /^config\/environments\/.*\.rb$/

  watch /^config\/initializers\/.*\.rb$/

  watch /^spec\/spec_helper.rb/

  watch /^spec\/fabricators*/
end

guard 'rspec', :version => 2, :drb => true, :rvm => '1.9.2', :fail_fast => true do

  watch /^spec\/(.*)_spec.rb/

  watch /^lib\/(.*)\.rb/ do |m| 
    "spec/lib/#{m[1]}_spec.rb"
  end

  watch /^spec\/spec_helper.rb/ do
    "spec"
  end

  watch /^app\/controllers\/application_controller.rb/ do
    "spec/controllers"
  end

  watch /^app\/controllers\/(.*).rb/ do |m|
    "spec/controllers/#{m[1]}_spec.rb"
  end

  watch /^app\/models\/(.*).rb/ do |m|
    "spec/models/#{m[1]}*"
  end

  watch /^app\/views\/(.*)\/*/ do |m|
    "spec/acceptance/*#{m[1]}*"
  end

  watch /^app\/helpers\/(.*).rb/ do |m|
    "spec/helpers/#{m[1]}_spec.rb" 
  end

  watch /^spec\/fabricators*/ do
    "spec/models"
  end
end

