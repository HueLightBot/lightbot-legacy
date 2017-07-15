require 'cinch'
require 'active_support'
require 'hue'
require 'color'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :usernotice, :method => :subs

  match /#([0-9a-fA-F]{6})/, use_prefix: false, method: :lights
  match /setlights #([0-9a-fA-F]{6})/, method: :mod_color
  match /off/, method: :off
  match /on/, method: :on

  def lights(m, color)
    $lightbot_logger.info "Detected RGB hex color #{color}"
    if m.tags["bits"].to_i >= $config["bot"]["cheer_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured cheer floor. Setting color."
      temp_color = "#" + color.to_s
      set_color m, temp_color
    end
  end

  def mod_color(m, color)
    $lightbot_logger.info "Detected !setlights command!"
    if mod?(m)
      $lightbot_logger.info "Lights are being set to #{color} by command!"
      temp_color = "#" + color.to_s
      set_color m, temp_color
    end
  end

  def off(m)
    $lightbot_logger.info "Detected !off command!"
    if m.tags["bits"].to_i >= $config["bot"]["off_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured cheer floor for turning the lights off."
      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.off!
      end
    end
  end

  def on(m)
    $lightbot_logger.info "Detected !on command!"
    if m.tags["bits"].to_i >= $config["bot"]["on_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured cheer floor for turning the lights on."
      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.on!
      end
    end
  end

  def subs(m)
    if m.tags["msg-id"] == "resub"
      $lightbot_logger.info "Sub/resub!"
      if /#([0-9a-fA-F]{6})/.match(m.message)
        color = /#([0-9a-fA-F]{6})/.match(m.message)[0]
        $lightbot_logger.info "Resub message includes RGB hex code. Setting lights to color #{color}"
        set_color m, color
      end
    end
  end

  def set_color(m, color)
    rgb = Color::RGB.by_hex color
    rgbxyz = rgb.to_xyz
    totals = rgbxyz[:x] + rgbxyz[:y] + rgbxyz[:z]
    @x = rgbxyz[:x] / totals
    @y = rgbxyz[:y] / totals
    @bri = rgbxyz[:y]

    $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
      light.set_xy @x,@y
      light.brightness = @bri
    end

    $lightbot_logger.info "Opening color text file."
    file = File.open "current_color.txt", 'w'
    $lightbot_logger.info "Writing color value to file."
    file.puts color
    file.flush
    file.close

    m.reply "@#{m.user}, I've set the hue light color to #{color}"
  end
end
