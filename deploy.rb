require 'sshkit'
require 'sshkit/dsl'
include SSHKit::DSL

repo = 'https://github.com/joaomsa/doge.git'

app_name = 'doge'
app_root = '/srv/app'

user = 'joaomsa'

RBENV_ROOT = "/home/#{user}/.rbenv"
SSHKit.config.command_map = Hash.new do |hash, command|
  hash[command] = "PATH=#{RBENV_ROOT}/shims:$PATH #{command}"
end

on %W{ #{user}@doge.joaomsa.com } do |host|

  app_dir = File.join(app_root, app_name)
  execute :mkdir, '-p', app_root
  execute :rm, '-rf', app_dir
  execute :git, 'clone', repo, app_dir

  within app_dir do

    # Install Comic Sans Bold
    fonts_dir = '/usr/share/fonts/truetype/ms-fonts'
    execute :sudo, :mkdir, '-p', fonts_dir
    execute :sudo, :ln, '-nfs', File.join(app_dir, 'comicbd.ttf'), 
                                fonts_dir
    execute :'fc-cache', '-fv'

    # Nginx vhost
    vhosts_dir = '/etc/nginx/sites-enabled'
    execute :sudo, :ln, '-nfs', File.join(app_dir, 'doge.nginxconf'), 
                                File.join(vhosts_dir, app_name)
    execute :sudo, :service, 'nginx', 'reload'

    # Gems
    execute :gem, 'install', 'bundler'
    execute :bundle, 'install'
  end
end
