======
README
======

oh-my-zshを利用していてzsh設定を各環境に配布したい人向けデプロイスクリプト。
oh-my-zshを使わない人はdeploy.rbにあるoh-my-zsh周りのコードを削除すればいい(削除しなくても.zshrcの中で有効にしない限りは無害)。

ディレクトリレイアウト
======================

::

  config-deployer
  ├── Capfile             # デプロイ用の依存関係、ロードするスクリプトを定義するファイル
  ├── Gemfile             # rubyのライブラリの定義ファイル
  ├── config
  │   └── deploy.rb      # 各人毎の設定を記述するファイル
  ├── hosts               # デプロイ対象とするホストを定義するファイル
  └── lib
    └── zconf_deployer.rb # 実際におこなう処理が定義されているファイル

利用方法
========

 1. deploy.rbのrepositoryに自分の設定ファイルが置いてあるリポジトリを設定する(svnは非対応)
    bitbucketなんかの無料privateリポジトリの利用がオススメ

    このリポジトリには直下にinstall.zshが置かれている必要がある。
    install.zshはzsh用設定ファイルを$HOMEに対してシンボリックリンクを貼るようにしたものを想定

    install.zsh 例::

      #!/usr/bin/env zsh
      for rc ($(cd $(dirname $0) && pwd)/.zsh*) ln -sF $rc $HOME && echo "$rc installed."

    リポジトリレイアウト例::

      zsh-dotfiles
      ├── .gitignore
      ├── .zshenv
      ├── .zshrc
      ├── .zshrc.alias
      ├── .zshrc.prompt
      ├── .zshrc.linux
      ├── .zshrc.osx
      ├── .zshrc.local
      └── install.zsh

 2. デプロイ対象とするホスト群をconfig-deployer/hostsに定義する

    例::

      host01
      host02
      host03


 3. ライブラリのインストール

    ::

      $ bundle install --path=vendor/bundle

 4. 最後にデプロイの為のコマンドを実行

    ::

      $ bundle exec cap deploy

