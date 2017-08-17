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
  match /setlights/, method: :set_lights
  match /dim (\d\.\d)/, method: :dim
  match /off/, method: :off
  match /on/, method: :on
  match /colorloop/, method: :colorloop

  def lights(m)
    if m.tags["bits"].to_i > $config["bot"]["largecheer"].to_i
      $lightbot_logger.info "More than 0k bits! Triggering alert!"
      determine_alert "largeCheer"
    end

    if m.tags["bits"].to_i >= $config["bot"]["cheer_floor"].to_i
      $lightbot_logger.info "Cheer is higher than configured cheer floor. Setting color."
      if /#([0-9a-fA-F]{6})/.match(m.message)
        colors = m.message.scan(/#[0-9a-fA-F]{6}/)
        $lightbot_logger.info "Message includes RGB hex code. Setting lights to color #{colors}"
        colors.each do |color|
          set_color m, color
          sleep 3
        end
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

  def set_lights(m)
    $lightbot_logger.info "Detected !setlights command!"
    puts permission?(m, "setcolor")
    if permission?(m, "setcolor")
      colors = m.message.scan(/#[0-9a-fA-F]{6}/)
      $lightbot_logger.info "Lights are being set to #{colors} by command!"
      colors.each do |color|
        set_color m, color
        sleep 3
      end
    end
  end

  def colorloop(m)
    $lightbot_logger.info "Detected !colorloop command!"
    if mod?(m)
      ColorLoop.new
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
      case m.tags["msg-param-sub-plan"].to_i
      when "1000"
        determine_alert "sub_1000"
      when "2000"
        determine_alert "sub_2000"
      when "3000"
        determine_alert "sub_3000"
      when "prime"
        determine_alert "prime"
      end

      if /#([0-9a-fA-F]{6})/.match(m.message)
        colors = m.message.scan(/#[0-9a-fA-F]{6}/)
        $lightbot_logger.info "Resub message includes RGB hex code. Setting lights to color #{colors}"
        colors.each do |color|
          set_color m, color
          sleep 3
        end
      end
    end
  end

  private

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

  def determine_alert(event)
    case event
    when "largeCheer"
      event_str = $config["bot"]["alerts"]["cheer"]
    when "prime"
      event_str = $config["bot"]["alerts"]["prime"]
    when "sub_1000"
      event_str = $config["bot"]["alerts"]["sub_1000"]
    when "sub_2000"
      event_str = $config["bot"]["alerts"]["sub_2000"]
    when "sub_3000"
      event_str = $config["bot"]["alerts"]["sub_3000"]
    end

    case event_str
    when "loop"
      @alert = ColorLoop.new
    when "blink"
      @alert = Blink.new
    else
      @alert = nil
    end
  end
end
