namespace :load do
  task :defaults do
    set :secrets_local_file, 'config/secrets.yml'
    set :setup_bucket, -> {"#{fetch(:application)}-setup"}
    set :warn_if_no_secrets_file, -> { true }
    set :secret_roles, -> { %w(app batch web) }
  end
end

namespace :app do
  namespace :write do
    desc "write secrets.yml"
    task :secrets_yml do
      on roles(fetch(:secret_roles)) do
        yaml = YAML::load_file(File.expand_path(fetch(:secrets_local_file)))
        subset = yaml[fetch(:rails_env).to_s]
        upload! StringIO.new({fetch(:rails_env).to_s => subset}.to_yaml), "#{shared_path}/#{fetch(:secrets_local_file)}"
      end
    end
  end
end

namespace :secrets do
  task :load do
    if File.exist?(File.expand_path(fetch(:secrets_local_file)))
      yaml = YAML::load_file(File.expand_path(fetch(:secrets_local_file)))
      if yaml
        set :secrets, yaml["deploy_#{fetch(:stage)}"]
        puts "WARNING there's no deploy_#{fetch(:stage)} section in #{fetch(:secrets_local_file)}".yellow unless fetch(:secrets)
      else
        puts "WARNING empty secrets file #{fetch(:secrets_local_file)}".yellow if fetch(:warn_if_no_secrets_file)
      end
    else
      puts "WARNING secrets file #{fetch(:secrets_local_file)} not found!".yellow if fetch(:warn_if_no_secrets_file)
    end
  end

  desc "Uploads secrets.yml"
  task :upload do
    on :local do
      if File.exist?(File.expand_path(fetch(:secrets_local_file)))
        execute :s3cmd, "put #{fetch(:secrets_local_file)} s3://#{fetch(:setup_bucket)}/deploy/secrets.yml" 
      else
        puts "WARNING secrets file #{fetch(:secrets_local_file)} not found! nothing uploaded".yellow if fetch(:warn_if_no_secrets_file)
      end
    end
  end

  desc "Compares local secrets with the stored on the bucket"
  task :compare do
    on :local do 
      if test :s3cmd, "--force get s3://#{fetch(:setup_bucket)}/deploy/secrets.yml /tmp/secrets.yml"
        puts capture :diff, "-u /tmp/secrets.yml #{fetch(:secrets_local_file)}; true"
        execute :rm, "/tmp/secrets.yml"
      else
        puts "Error downloading (Maybe there's no shared secrets file at s3://#{fetch(:setup_bucket)}/deploy/secrets.yml )".red
      end
    end
  end

  desc "Overwrites local secrets with bucket version"
  task :get_from_s3 do
    on :local do
      unless test :s3cmd, "--force get s3://#{fetch(:setup_bucket)}/deploy/secrets.yml #{fetch(:secrets_local_file)}"
        puts "Error downloading (Maybe there's no shared secrets file at s3://#{fetch(:setup_bucket)}/deploy/secrets.yml )".red
      end
    end
  end
end

after 'load:defaults', 'secrets:load'
