require 'telegram_bot'
require 'pp'
require 'logger'

require 'yaml'
require 'daemons'

env_file = File.join('config','local_env.yml')
YAML.load(File.open(env_file)).each do |key, value|
  ENV[key.to_s] = value
end if File.exists?(env_file)

logger = Logger.new(STDOUT, Logger::DEBUG)

bot = TelegramBot.new(token: ENV['TELEGRAM_BOT_API_KEY'], logger: logger)
logger.debug "starting telegram bot"

bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /greet/i
      reply.text = "Hello, #{message.from.first_name}!"
    when /test/i
      reply.text = "test, lagi"
    when /check/i
      cmd = "sh execute.sh"
      value = `#{cmd}`
      reply.text = "my ip is : #{value}"
    else
      reply.text = "#{message.from.first_name}, have no idea what #{command.inspect} means."
    end
    logger.info "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end
