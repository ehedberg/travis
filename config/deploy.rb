require 'mongrel_cluster/recipes'

set :application, "travis"
set :repository,  "https://svn.office.gdi/development/travis/trunk/"
set :deploy_to, "/var/apps/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
default_run_options[:pty] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "buildbox.office.gdi"
role :web, "buildbox.office.gdi"
role :db,  "buildbox.office.gdi", :primary => true

after 'deploy:update_code', 'deploy:symlink_configs'
namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_configs do
    sudo "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    sudo "ln -nfs #{shared_path}/config/solr.yml #{release_path}/config/solr.yml"
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
  
  desc "restarts solr"
  task :restart do
    stop
    start
  end

end

