require 'hue'

class Blink < Alert
  def trigger
    3.times do
      @group.lights.each do |light|
        light.alert="select"
      end
      sleep 1
    end
  end
end
