require "/home/ulrich/ruby/blume2-0/Version.rb"

class Wenn

  VERSION = Version.new(3,3)

  def initialize(pos, zufall, negativ = false)
    @pos = pos
    @negativ = negativ
  end

  def verschieben?(punkt)
    not @negativ
  end
end
