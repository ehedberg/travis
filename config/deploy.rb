require 'mongrel_cluster/recipes'

set :application, "travis"
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :repository,  "https://svn.office.gdi/development/travis/trunk/"
set :deploy_to, "/var/apps/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
default_run_options[:pty] = true

role :app, "buildbox.office.gdi"
role :web, "buildbox.office.gdi"
role :db,  "buildbox.office.gdi", :primary => true

after 'deploy:update_code', 'deploy:symlink_configs', 'solr:reindex'
namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_configs do
    sudo "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    sudo "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml"
    sudo "rm -rf #{release_path}/solr"
    sudo "ln -nfs #{shared_path}/solr #{release_path}/solr"
  end
end

namespace :solr do
  desc "stops solr"
  task :stop do
    sudo "sh -c 'cd #{current_path} && rake solr:stop RAILS_ENV=production'"
  end
  
  desc "starts solr"
  task :start do
    sudo "sh -c 'cd #{current_path} && rake solr:start RAILS_ENV=production'"
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
