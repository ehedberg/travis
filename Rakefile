# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'tasks/rails'
begin
  require 'rcov/rcovtask'
  desc "just rcov minus html output"
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/{unit,integration,functional}/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  puts 'Rcov is not available. Proceeding without...'
end

namespace :test do 
  namespace :coverage do
    desc "Delete aggregate coverage data."
    task(:clean) { rm_f "coverage.data"; rm_rf "test/coverage" }

    desc "open the rcov html files"
    task :files do
      puts "View the full results at:"
                                %w[unit functional integration].each do |target|
        system "open -a safari file://#{File.expand_path("./test/coverage/#{target}")}/index.html"
                                end
    end
  end
  desc 'Aggregate code coverage for unit, functional and integration tests'
  task :coverage => "test:coverage:clean"
          %w[unit functional].each do |target|
    namespace :coverage do
      Rcov::RcovTask.new(target) do |t|
        t.libs << "test"
        t.test_files = FileList["test/#{target}/**/*_test.rb"]
        t.output_dir = "test/coverage/#{target}"
        t.verbose = true
        t.rcov_opts << '--exclude gems --exclude Library --rails --aggregate coverage.data'
      end
    end
    task :coverage => "test:coverage:#{target}" 
          end
  task :coverage => "test:coverage:files"
end
