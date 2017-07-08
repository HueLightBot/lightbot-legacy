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

  def lights(m, color)
    if m.tags["bits"].to_i >= $config["bot"]["cheer_floor"].to_i
      temp_color = "#" + color.to_s
      rgb = Color::RGB.by_hex temp_color
      rgbxyz = rgb.to_xyz
      totals = rgbxyz[:x] + rgbxyz[:y] + rgbxyz[:z]
      @x = rgbxyz[:x] / totals
      @y = rgbxyz[:y] / totals
      @bri = rgbxyz[:y]

      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.set_xy @x,@y
        light.brightness = @bri
      end

      m.reply "@#{m.user}, I've set the hue light color to ##{color}"
    end
  end

  def mod_color(m, color)
    if mod?(m)
      temp_color = "#" + color.to_s
      rgb = Color::RGB.by_hex temp_color
      rgbxyz = rgb.to_xyz
      totals = rgbxyz[:x] + rgbxyz[:y] + rgbxyz[:z]
      @x = rgbxyz[:x] / totals
      @y = rgbxyz[:y] / totals
      @bri = rgbxyz[:y]

      $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
        light.set_xy @x,@y
        light.brightness = @bri
      end

      m.reply "@#{m.user}, I've set the hue light color to ##{color}"
    end    
  end

  def subs(m)
    if m.tags["msg-id"] == "resub"
      if /#([0-9a-fA-F]{6})/.match(m.message)
        color = /#([0-9a-fA-F]{6})/.match(m.message)
        temp_color = "#" + color.to_s
        rgb = Color::RGB.by_hex temp_color
        rgbxyz = rgb.to_xyz
        totals = rgbxyz[:x] + rgbxyz[:y] + rgbxyz[:z]
        @x = rgbxyz[:x] / totals
        @y = rgbxyz[:y] / totals
        @bri = rgbxyz[:y]

        $hue_client.group($config["bot"]["hue_group"]).lights.each do |light|
          light.set_xy @x,@y
          light.brightness = @bri
        end

        m.reply "@#{m.user}, I've set the hue light color to ##{color}"
      end
    end
  end
end
