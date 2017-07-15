#!/usr/bin/ruby

# Load '.'
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

# require Cinch IRCBot Framwork
require 'cinch'

# require activesupport for various Rails like magics
require 'active_support'

# add Inflector methods and overrides.
include ActiveSupport::Inflector

# require Hue support
require 'hue'

# require YAML for loading the config
require 'yaml'

# require logger to log info about bot actions
require 'logger'

# start up logger
$lightbot_logger = Logger.new('lightbot.log')

# load custom cinch plugins
Dir["./plugins/*.rb"].each {|file| load file}

# Create hue instance.
$lightbot_logger.info "Starting Hue client"
$hue_client = Hue::Client.new

# Load Twitch Plugin
plugins = [constantize("Twitch")]

# Load Config from YAML
$lightbot_logger.info "Loading Config"
$config = YAML.load_file('config.yaml')

# Join Channel
channels = [$config["bot"]["channel"]]

# Configure Bot instance
$lightbot_logger.info "Configuring Bot from config file"
@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = $config["bot"]["nick"]
    c.server = $config["bot"]["server"]
    c.port = $config["bot"]["port"]
    c.ssl.use = false
    c.password = $config["bot"]["password"]
    c.channels = channels
    c.caps = [:"twitch.tv/membership", :"twitch.tv/commands", :"twitch.tv/tags"]
    c.plugins.plugins = plugins
  end
end

# Load plugins
$plugin_list = Cinch::PluginList.new @bot

# Start bot
$lightbot_logger.info "Starting Lightbot"
@bot.start
