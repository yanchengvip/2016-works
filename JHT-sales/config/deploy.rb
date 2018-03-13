lock '3.6.1'

set :application, 'xxx'
set :repo_url, 'github.com'
set :deploy_to, '/var/www/sales'
set :deploy_user, :deploy

set :scm, :git
set :format, :pretty
set :log_level, :debug


set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

set :rvm_type, :user
set :rvm_ruby_version, '2.2.3'
set :rvm_roles, [:app, :web, :db]

set :keep_releases, 5

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :restart do
    invoke 'unicorn:restart'
  end

end

namespace :logs do
  desc "tail rails logs"
  task :tail do
    on roles(:app) do
      execute "tail -f #{deploy_to}/shared/log/#{fetch(:rails_env)}.log"
    end
  end
end