# -*- coding: utf-8 -*-
require "/home/ulrich/ruby/blume2-0/Version.rb"

class Wenn

  VERSION = Version.new(3,3)

  def initialize(pos, zufall, negativ = false)
    @pos = pos
    @negativ = negativ
  end

  #gibt zurück, ob der gegebene Punkt verschoben (o.ä.) werden soll
  def verschieben?(punkt)
    not @negativ
  end

  def xor(x,y)
    if x
      return y == false
    else
      return y
    end
  end
end
