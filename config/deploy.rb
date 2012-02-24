default_run_options[:pty] = true

set :zconf_repo, "https://cynipe@github.com/cynipe/zsh.git"
set :symlinks, %w(~/.zshrc* ~/.zshenv)

# 対象ホストの設定
# プロジェクト直下のhostsファイルに行単位で列挙されたものを読み込む
role :host, do
  File.read("hosts").each_line.reduce([]) { |res, host| host.strip!; res << host unless host.empty?; res }
end

set :user do
  Capistrano::CLI.ui.ask "user: "
end
set :password do
  Capistrano::CLI.password_prompt "pass[#{user}]: "
end
require "zconf_deployer"
