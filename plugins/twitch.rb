require 'cinch'
require 'active_support'
require 'hue'
require 'color'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :usernotice, :method => :subs
  listen_to :channel, :method => :lights

  #match /#([0-9a-fA-F]{6})/, use_prefix: false, method: :lights
  match /setlights #([0-9a-fA-F]{6})/, method: :mod_color
  match /dim (\d\.\d)/, method: :dim
  match /off/, method: :off
  match /on/, method: :on
  match /colorloop/, method: :colorloop

  def lights(m, color)
    if m.tags["bits"].to_i > 999
      $lightbot_logger.info "More than 0k bits! Triggering color loop for 30 seconds!"
      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.effect="colorloop"
      end

      sleep 30

      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.effect="none"
      end
    end

    if m.tags["bits"].to_i >= $config["bot"]["cheer_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured cheer floor. Setting color."
      if /#([0-9a-fA-F]{6})/.match(m.message)
        color = /#([0-9a-fA-F]{6})/.match(m.message)[0]
        $lightbot_logger.info "Message includes RGB hex code. Setting lights to color #{color}"
        set_color m, color
      end
    end
  end

  def dim(m, brightness)
    $lightbot_logger.info "Detected dim command"
    if m.tags["bits"].to_i >= $config["bot"]["dim_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured dimming floor. Setting Brightness."
      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.brightness = brightness
      end
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

  def colorloop(m)
    $lightbot_logger.info "Detected !colorloop command!"
    if mod?(m)
      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.effect="colorloop"
      end

      sleep 30

      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.effect="none"
      end
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
    if m.tags["msg-id"] == "resub" || m.tags["msg-id"] == "sub"
      $lightbot_logger.info "Sub/resub!"
      if m.tags["msg-param-sub-plan"].to_i == "3000".to_i || m.tags["msg-param-sub-plan"].to_i == "2000".to_i
        $lightbot_logger.info "Sub is a $24.99 sub! Triggering color loop for 10 seconds!"
        $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
          light.effect="colorloop"
        end

        sleep 30

        $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
          light.effect="none"
        end
      end

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
