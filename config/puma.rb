# encoding: utf-8

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# PIDファイルの出力先を設定
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

before_fork do
  pid_file = File.join(Dir.pwd, 'tmp', 'pids', 'server.pid')
  if File.exist?(pid_file)
    File.delete(pid_file)
    puts "server.pid ファイルを削除しました"
  end
end

plugin :tmp_restart
