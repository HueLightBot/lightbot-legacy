require 'hue'

class Alert
  def initialize
    @group = $hue_client.group($config["bot"]["hue_group"])
    self.trigger
  end

  def trigger

  end
end
