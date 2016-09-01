require 'telegram_bot'
require 'pp'
require 'logger'

require 'yaml'
require 'daemons'
require 'mysql'
require 'active_record'

env_file = File.join('config','local_env.yml')
YAML.load(File.open(env_file)).each do |key, value|
  ENV[key.to_s] = value
end if File.exists?(env_file)

logger = Logger.new(STDOUT, Logger::DEBUG)

bot = TelegramBot.new(token: ENV['TELEGRAM_BOT_API_KEY'], logger: logger)
logger.debug "starting telegram bot"

ActiveRecord::Base.establish_connection(  
:adapter => "mysql",
:host => ENV['MYSQL_HOST'],
:database => ENV['MYSQL_DB'],
:username => ENV['MYSQL_USER'],
:password => ENV['MYSQL_PASS']

)

class OcAuth < ActiveRecord::Base  
end 

allowed = OcAuth.where(is_allowed: '1', username: 'midincihuy')
logger.info allowed.count