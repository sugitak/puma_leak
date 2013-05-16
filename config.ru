require 'puma'
require 'mysql2'

CONN = {
  :host => "localhost",
  :username => "test",
  :password => "test"
}

class WithSQLConnection
  def self.connect
    @@db ||= Mysql2::Client.new(CONN)
  end

  def connections
    return `ls -l /proc/#{$$}/fd | grep socket`
  end

  def reload
    `kill -USR2 #{$$}`
  end

  def call(env)
    reload if env["REQUEST_PATH"] == "/reload"
    [200, {'Content-type' => 'text/plain'},
     ["PID: #{$$}\n",connections]]
  end
end

WithSQLConnection.connect
run WithSQLConnection.new

