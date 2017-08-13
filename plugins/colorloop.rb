class ColorLoop < Alert
  def trigger
    @group.lights.each do |light|
      light.effect="colorloop"
    end

    sleep 30

    @group.lights.each do |light|
      light.effect="none"
    end
  end
end
