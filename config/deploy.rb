require 'mongrel_cluster/recipes'

set :application, "travis"
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git
set :repository, "http://github.com/ehedberg/travis.git"
set :deploy_to, "/var/apps/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :user, "evodeploy"
set :use_sudo, false
set :deploy_via, :remote_cache
default_run_options[:pty] = true

role :app, "buildbox.office.gdi"
role :web, "buildbox.office.gdi"
role :db,  "buildbox.office.gdi", :primary => true


after 'deploy:update_code', 'deploy:symlink_configs'
after 'deploy:symlink', 'solr:restart'

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_configs do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml"
    run "rm -rf #{release_path}/solr"
    run "ln -nfs #{shared_path}/solr #{release_path}/solr"
    run "ln -nfs #{shared_path}/config/environment.rb #{release_path}/config/environment.rb"
    run "ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb"
  end
end

namespace :solr do
  desc "stops solr"
  task :stop do
    run "cd #{current_path} && rake solr:stop RAILS_ENV=production"
  end
  
  desc "starts solr"
  task :start do
    run "cd #{current_path} && rake solr:start RAILS_ENV=production"
  end

  desc "reindexes solr"
  task :reindex do
    run "cd #{current_path} && rake solr:reindex RAILS_ENV=production"
  end
  
  desc "restarts solr"
  task :restart do
    stop
    start
  end

end

