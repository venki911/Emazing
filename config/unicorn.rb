root = "/home/deployer/apps/emazing/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/production.log"
stdout_path "#{root}/log/production.log"

listen "#{root}/tmp/sockets/unicorn.sock"
worker_processes 2
timeout 360

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end