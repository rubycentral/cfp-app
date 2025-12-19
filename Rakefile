# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

CfpApp::Application.load_tasks

# A monkey-patch for annotate 2.6.5
task :monkey_patch_annotate do
  ::Fixnum = ::Bignum = ::Integer
end

Rake::Task['db:migrate'].enhance [:monkey_patch_annotate]
