# -*- coding: utf-8 -*-
require "/home/ulrich/ruby/blume2-0/Version.rb"

# Gitterpunkte werden nicht verschoben (o.ä.)
class Wenn_Punktgitter < Wenn
  VERSION = Version.new(3,3)
  RADIUS = 2000
  ABSTAND = 100000

  def initialize(pos, zufall, negativ = false)
    super(pos, zufall, negativ)
    @radius = zufall.zufaellig(0) * RADIUS
    @verschiebung1 = (zufall.zufaellig(0) + zufall.zufaellig(0) * Complex::I) * ABSTAND
    @verschiebung2 = (zufall.zufaellig(0) + zufall.zufaellig(0) * Complex::I) * ABSTAND
  end

  # gibt streckfaktoren x,y zurück, s.d. @verschiebung1 * x + @verschiebung2 * y = punkt
  def gleichungs_syst(punkt)
    if (@verschiebung1.imag * @verschiebung2.real - @verschiebung1.real * @verschiebung2.imag) != 0
      x = (punkt.imag * @verschiebung2.real - punkt.real * @verschiebung2.imag) / (@verschiebung1.imag * @verschiebung2.real - @verschiebung1.real * @verschiebung2.imag).to_f
    else
      return [nil, nil]
    end
    if (@verschiebung2.imag * @verschiebung1.real - @verschiebung2.real * @verschiebung1.imag) != 0
      y = (punkt.imag * @verschiebung1.real - punkt.real * @verschiebung1.imag) / (@verschiebung2.imag * @verschiebung1.real - @verschiebung2.real * @verschiebung1.imag).to_f
    else
      return [nil, nil]
    end
    return [x,y]
  end

  #gibt zurück, ob der gegebene Punkt verschoben (o.ä.) werden soll
  def verschieben?(punkt)
    punkt -= @pos
    x, y = gleichungs_syst(punkt)
    return true if y == nil
    x_neu = x % 1
    y_neu = y % 1
    x -= x_neu
    y -= y_neu
    r = [
         (@verschiebung1 * x + @verschiebung2 * y - punkt).abs,
         (@verschiebung1 * x + @verschiebung2 * (1 + y) - punkt).abs,
         (@verschiebung1 * (x + 1) + @verschiebung2 * y - punkt).abs,
         (@verschiebung1 * (x + 1) + @verschiebung2 * (1 + y) - punkt).abs
        ].min
    xor(super(punkt), r.abs < @radius)
  end
end
