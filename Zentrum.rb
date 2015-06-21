class Zentrum
  def initialize(position, staerke, richtung)
    @position = position
    @staerke = staerke
    @richtung = richtung
  end
  attr_reader :position, :staerke, :richtung
end
