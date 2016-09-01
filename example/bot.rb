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

ActiveRecord::Base.establish_connection(  
:adapter => "mysql",
:host => ENV['MYSQL_HOST'],
:database => ENV['MYSQL_DB'],
:username => ENV['MYSQL_USER'],
:password => ENV['MYSQL_PASS']

)

class OcAuth < ActiveRecord::Base  
end 

class Command < ActiveRecord::Base
end

bot = TelegramBot.new(token: ENV['TELEGRAM_BOT_API_KEY'], logger: logger)
logger.debug "starting telegram bot"

bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  username = message.from.username
  allowed = OcAuth.where(is_allowed: '1', username: username)
  command = message.get_command_for(bot)
  logger.info allowed
  message.reply do |reply|
    if allowed.count == 1 then
      case command
      when /greet/i
        reply.text = "Hello, #{message.from.first_name}!"
      when /test/i
        reply.text = "test, lagi"
      when /execute/i
        exec = command.split(' ')
        logger.info "Commandnya : #{exec[1]}"
        cmd = "ssh magentovm@172.16.65.11 \"bash -s\" < ./#{exec[1]}.sh"
        logger.info "Request : #{cmd}"
        value = `#{cmd}`
        reply.text = "Response : #{value}"
      when /check/i
        cmd = "sh execute.sh"
        value = `#{cmd}`
        reply.text = "my ip is : #{value}"
      else
        reply.text = "#{message.from.first_name}, have no idea what #{command.inspect} means."
      end
    else
      reply.text = "#{message.from.first_name}, You shouldn't do that."
    end
    logger.info "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end
