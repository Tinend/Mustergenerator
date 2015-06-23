require "/home/ulrich/ruby/blume2-0/Version.rb"

class Wenn_Punktgitter < Wenn
  VERSION = Version.new(3,3)
  
  def initialize(pos, zufall, negativ = false)
    @pos = pos
    
  end

end
