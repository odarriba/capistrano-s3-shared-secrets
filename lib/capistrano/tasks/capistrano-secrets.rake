namespace :load do
  task :defaults do
    set :secrets_local_file, 'config/secrets.yml'
    set :secrets_remote_file, 'config/secrets.yml'
    set :setup_bucket, ''
    set :warn_if_no_secrets_file, true
    set :secret_roles, []
  end
end

namespace :app do
  namespace :write do
    desc "write apropiate section of local secrets file to the servers filesystem"
    task :secrets_yml do
      config_file = File.read(File.expand_path(fetch(:secrets_local_file)))
      on roles(fetch(:secret_roles)) do
        upload! StringIO.new(config_file), "#{shared_path}/#{fetch(:secrets_local_file)}"
      end
    end
  end
end

namespace :secrets do
  desc "Uploads local secrets.yml to shared bucket"
  task :upload do
    on :local do
      if File.exist?(File.expand_path(fetch(:secrets_local_file)))
        execute :s3cmd, "put #{fetch(:secrets_local_file)} s3://#{fetch(:setup_bucket)}/#{fetch(:secrets_remote_file)}" 
      else
        puts "WARNING secrets file #{fetch(:secrets_local_file)} not found! nothing uploaded".yellow if fetch(:warn_if_no_secrets_file)
      end
    end
  end

  desc "Compares local secrets with the stored on the shared bucket"
  task :compare do
    on :local do 
      if test :s3cmd, "--force get s3://#{fetch(:setup_bucket)}/#{fetch(:secrets_remote_file)} /tmp/secrets.yml"
        puts capture :diff, "-u /tmp/secrets.yml #{fetch(:secrets_local_file)}; true"
        execute :rm, "/tmp/secrets.yml"
      else
        puts "Error downloading (Maybe there's no shared secrets file at s3://#{fetch(:setup_bucket)}/#{fetch(:secrets_remote_file)} )".red
      end
    end
  end

  desc "Overwrites local secrets with shared bucket version"
  task :get_from_s3 do
    on :local do
      unless test :s3cmd, "--force get s3://#{fetch(:setup_bucket)}/#{fetch(:secrets_remote_file)} #{fetch(:secrets_local_file)}"
        puts "Error downloading (Maybe there's no shared secrets file at s3://#{fetch(:setup_bucket)}/#{fetch(:secrets_remote_file)} )".red
      end
    end
  end
end

after 'load:defaults', 'secrets:load'
