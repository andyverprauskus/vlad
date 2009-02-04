require 'vlad'

namespace :vlad do
  ##
  # Mongrel app server

  set :mongrel_address,       "127.0.0.1"
  set :mongrel_clean,         false
  set :mongrel_command,       'mongrel_rails'
  set(:mongrel_conf)          { "#{shared_path}/mongrel_cluster.yml" }

  desc "Prepares application servers for deployment. Mongrel
configuration is set via the mongrel_* variables.".cleanup

  def mongrel(cmd) # :nodoc:
    cmd = "#{mongrel_command} #{cmd} -C #{mongrel_conf}"
    cmd << ' --clean' if mongrel_clean
    STDOUT.puts "Executing: #{cmd}"
    cmd
  end

  desc "(Re)Start the app servers"
  remote_task :start_app, :roles => :app do
    puts run "cd #{current_path}; export RAILS_ENV=#{RAILS_ENV}; script/process/reaper"
    puts run "cd #{current_path}; cp config/#{RAILS_ENV}/mongrel_cluster.yml config/."
    run mongrel("cluster::start")
  end

  remote_task :restart_app => :start_app
  remote_task :mongrel_restart => :start_app

  desc "Stop the app servers"

  remote_task :stop_app, :roles => :app do
    run mongrel("cluster::stop")
    puts run "cd #{current_path}; export RAILS_ENV=#{RAILS_ENV}; script/process/reaper"
  end
end
