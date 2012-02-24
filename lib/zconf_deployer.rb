Capistrano::Configuration.instance(:must_exist).load do

  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

  _cset(:zconf_repo) { abort "Please specify the repository url for zsh dotfiles, set :zconf_repo, 'https://example.com/zsh-dotfiles.git'"}
  _cset(:symlinks) { abort "Please specify the symlinks for dotfiles that should be cleaned up before installing, set :symlinks, %w(~/.zshrc* ~/.zshenv)" }

  _cset(:deploy_to) { { :zconf => "~/dotfiles/zsh", :omz => "~/.oh-my-zsh" } }
  _cset(:zconf_file) { "zconf.tar" }
  _cset(:omz_file) { "omz.tar" }

  # logs the command then executes it locally.
  # returns the command output as a string
  def run_locally(cmd)
    logger.trace "executing locally: #{cmd.inspect}" if logger
    `#{cmd}`
  end

  def tmp_dir(type)
    dir = "/tmp/cap-#{hash}"
    case type
    when :remote then run "mkdir -p #{dir}"
    when :local then run_locally "mkdir -p #{dir}"
    else ArgumentError
    end
    dir
  end

  def hash
    alpha ||=  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;
    (0..50).map{ alpha[rand(alpha.length)]  }.join
  end

  namespace :deploy do

    desc "Deploys oh-my-zsh and zsh dotfile according to the settings."
    task :default do
      clear!
      prepare
      install
    end

    task :clear! do
      targets = deploy_to.values + symlinks
      run "rm -rf #{targets.join(" ")}"
    end

    task :prepare do
      tmp = tmp_dir(:local)
      omz_down_dir = "#{tmp}/omz"
      zconf_down_dir = "#{tmp}/zconf"

      run_locally "mkdir #{omz_down_dir} #{zconf_down_dir}"

      run_locally "git clone https://github.com/robbyrussell/oh-my-zsh.git #{omz_down_dir} && cd #{omz_down_dir} && git archive HEAD --format=tar -o #{tmp}/#{omz_file}"
      run_locally "git clone #{zconf_repo} #{zconf_down_dir} && cd #{zconf_down_dir} && git archive HEAD --format=tar -o #{tmp}/#{zconf_file}"

      set :upload_dir, tmp_dir(:remote)
      upload("#{tmp}/zconf.tar", upload_dir, :via => :scp)
      upload("#{tmp}/omz.tar", upload_dir, :via => :scp)
    end

    task :install do
      run "mkdir -p #{deploy_to[:omz]} && tar xvf #{upload_dir}/#{omz_file} -C #{deploy_to[:omz]}"
      run "mkdir -p #{deploy_to[:zconf]} && tar xvf #{upload_dir}/#{zconf_file} -C #{deploy_to[:zconf]} && zsh #{deploy_to[:zconf]}/install.zsh"
    end

  end
end # Capistrano::Configuration.instance(:must_exist).load do
