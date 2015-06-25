# -*- coding: utf-8 -*-
require "/home/ulrich/ruby/blume2-0/Version.rb"
require "/home/ulrich/ruby/blume2-0/zufaelle/Zufall3-0.rb"
require "/home/ulrich/ruby/blume2-0/farbpallette/Farbpallette3-0.rb"
require "/home/ulrich/ruby/blume2-0/bewerter/Bewerter3-0.rb"

class Feld

  I = Complex::I
  VERSION = Version.new(3,4)

  def initialize(zufall, hoehe, breite, verkleinerung, verschiebung, farbpallette)
    @schoenheit = 0
    @hoehe = hoehe
    @breite = breite
    @zufall = zufall
    @verkleinerung = verkleinerung
    @verschiebung = verschiebung
    @farbpallette = farbpallette
    zufall.zufall_erstellen
    @verschiebung += @zufall.verwischung / 2 * (1 + I)
    @wandlungen = wandeln
    @feld = []
    @nummern = {}
  end

  attr_reader :feld, :schoenheit, :breite, :hoehe

  def zufallspos
    return (rand(breite) + I * rand(hoehe) - @verschiebung) * @verkleinerung
  end

  def felderstellen
    alt_felderstellen
    @hoehe.times do |y|
      @breite.times do |x|
        farbe = entwischen(x,y)
        @feld[y][x] = farbe
        @nummern[farbe] = 1
      end
      @zufall.verwischung.times do
        @feld[y].pop
      end
    end
    @zufall.verwischung.times do
      @feld.pop
    end
  end

  def entwischen(x,y)
    farbe = [0,0,0]
    @zufall.verwischung.times do |yplus|
      @zufall.verwischung.times do |xplus|
        farbe[0] += @feld[y + yplus][x + xplus][0]
        farbe[1] += @feld[y + yplus][x + xplus][1]
        farbe[2] += @feld[y + yplus][x + xplus][2]
      end
    end
    return (farbe[0] / @zufall.verwischung ** 2 + 0.5).to_i * 65536 + (farbe[1] / @zufall.verwischung ** 2 + 0.5).to_i * 256 + (farbe[2] / @zufall.verwischung ** 2 + 0.5).to_i
  end

  def punkterstellen(x,y)
    pos = ((x - @verschiebung.real) * @verkleinerung.to_f + I * (y - @verschiebung.imag.to_f) * @verkleinerung)
    @wandlungen.each do |w|
      if w.wenn.verschieben?(pos)
        if w.was == :moeb
          pos = moeb(pos, w.wie)
        elsif w.was == :zykel
          pos = zykel(pos, w.wie, w.wo)
        elsif w.was == :spiral
          pos = spiral(pos, w.wie, w.wo)
        elsif w.was == :drehung
          pos = drehen(pos, w.wie, w.wo)
        elsif w.was == :streckung
          pos = streckung(pos, w.wie, w.wo)
        elsif w.was == :invertieren
          pos = invertieren(pos, w.wie, w.wo)
        elsif w.was == :verschiebung
          pos += w.wie
        end
      end
    end
    return @farbpallette.nahfarbe(pos)
  end

  def alt_felderstellen
    (@hoehe + @zufall.verwischung - 1).times do |y|
      @feld.push([])
      (@breite + @zufall.verwischung - 1).times do |x|
        farbe = punkterstellen(x,y)
        @feld[-1].push(farbe)
      end
      puts "#{y}/#{@hoehe}" if @hoehe >= 100 and y % (@hoehe / 100) == 0
    end
  end
  
  def spiral(pos, radius, wo)
    return 0 if pos == 0
    pos -= wo
    pos *= I ** (Math::log(pos.abs) / radius)
    pos += wo
    return pos
  end

  def sehr_klein?(c)
    return klein?(streckung(c, @zufall.faktor, @zentrum))
  end

  
  def moeb(pos, werte)
    return (pos * werte[0] + werte[1]) / (pos * werte[2] + werte[3])
  end

  def invertieren(pos, r, zentrum)
    if zentrum == pos
      return pos
    else
      return (((pos.real - zentrum.real) * r / ((pos.real - zentrum.real) ** 2 + (pos.imag - zentrum.imag) ** 2) + zentrum.real) + (- (pos.imag - zentrum.imag) * r / ((pos.real - zentrum.real) ** 2 + (pos.imag - zentrum.imag) ** 2) + zentrum.imag) * I)
    end
  end

  def zykel(pos, x, zentrum)
    mal, ziel = x
    alpha = winkel(pos) - winkel(ziel)
    beta = alpha - (alpha % (2 * Math::PI / mal))
    drehen(pos, - beta, zentrum)
  end
  
  def streckung(pos, wie, wo)
    (pos.real - wo.real) * wie + wo.real + I * ((pos.imag - wo.imag) * wie + wo.imag)
  end

  def winkel(vec)
    if vec == 0
      return 0
    elsif vec.real == 0 and vec.imag < 0
      return -Math::PI / 2
    elsif vec.real == 0
      return Math::PI / 2
    end
    alpha = Math::atan(vec.imag.to_f / vec.real)
    alpha = alpha - Math::PI if vec.real < 0
    alpha
  end

  def spiralradius
    vorzeichen = @zufall.vorzeichen
    if @zufall.spiralzufall == 0
      return Math::tan((Math::PI - 1) * @zufall.zufaellig(0) / 2 + 0.5) * vorzeichen
    elsif @zufall.spiralzufall == 1
      return Math::exp(2 * @zufall.zufaellig(0)) * vorzeichen
    elsif @zufall.spiralzufall == 2
      return 1 / @zufall.zufaellig(0) * vorzeichen
    end
  end

  def wandeln
    w = []
    a = 1
    b = 0
    c = 0
    d = 1
    if @zufall.erstes == :zykel
      alpha = @zufall.alpha
      mal = @zufall.drehzahl
      w.push(Wandel.new(:zykel, [mal, (Math::sin(alpha) +  Math::cos(alpha) * I)], 0, @zufall.wenn))
    elsif @zufall.erstes == :spiral
      radius = spiralradius
      w.push(Wandel.new(:spiral, radius, 0, @zufall.wenn))
    elsif @zufall.erstes == :mehrfachspiral
      alpha = @zufall.alpha
      mal = @zufall.drehzahl
      w.push(Wandel.new(:zykel, [mal, (Math::sin(alpha) +  Math::cos(alpha) * I)], 0, @zufall.wenn))
      radius = spiralradius
      w.push(Wandel.new(:spiral, radius, 0, @zufall.wenn))
    end
    while @zufall.gross?
      if @zufall.zykelwahl?
        if d != 0
          a /= d
          b /= d
          c /= d
          d = 1
        end
        if [a, b, c, d] != [1, 0, 0, 1]
          w.push(Wandel.new(:moeb, [a, b, c, d], 0, @zufall.wenn))
        end
        a = 1
        b = 0
        c = 0
        d = 1
        alpha = @zufall.alpha
        x = @zufall.pos(10000, 5000)
        y = @zufall.pos(10000, 5000)
        mal = @zufall.drehzahl
        x = 0
        y = 0
        w.push(Wandel.new(:zykel, [mal, (Math::sin(alpha) +  Math::cos(alpha) * I)], (x + I * y), @zufall.wenn))
      elsif @zufall.spiralwahl?
        if d != 0
          a /= d
          b /= d
          c /= d
          d = 1
        end
        if [a, b, c, d] != [1, 0, 0, 1]
          w.push(Wandel.new(:moeb, [a, b, c, d], 0, @zufall.wenn))
        end
        a = 1
        b = 0
        c = 0
        d = 1
        radius = spiralradius
        x = @zufall.pos(2000, 1000)
        y = @zufall.pos(2000, 1000)
        x = 0
        y = 0
        w.push(Wandel.new(:spiral, radius, (x + I * y), @zufall.wenn))
      elsif @zufall.mehrfachspiralwahl?
        if d != 0
          a /= d
          b /= d
          c /= d
          d = 1
        end
        if [a, b, c, d] != [1, 0, 0, 1]
          w.push(Wandel.new(:moeb, [a, b, c, d], 0, @zufall.wenn))
        end
        a = 1
        b = 0
        c = 0
        d = 1
        alpha = @zufall.alpha
        x = @zufall.pos(2000, 1000)
        y = @zufall.pos(2000, 1000)
        mal = @zufall.drehzahl
        x = 0
        y = 0
        w.push(Wandel.new(:zykel, [mal, (Math::sin(alpha) +  Math::cos(alpha) * I)], (x + I * y), @zufall.wenn))
        radius = spiralradius
        w.push(Wandel.new(:spiral, radius, (x + I * y), @zufall.wenn))
    # elsif false
    #    r = (@zufall % 100 + 1) * 0.1
    #    @zufall /= 100
    #    x = (@zufall % 10000 - 5000)
    #    @zufall /= 100
    #    y = (@zufall % 10000 - 5000)
    #    @zufall /= 100 
    #    zahl = x + I * y
    #    a,b,c,d = moeb_invertieren(a, b, c, d, zahl, r)
      elsif @zufall.zufaellig(5) <= 1
        x = @zufall.pos(50000, 25000)
        y = @zufall.pos(50000, 25000)
        a, b, c, d = moeb_verschieben(a,b,c,d, x + I * y)
      else
        x = @zufall.pos(10000, 5000)
        y = @zufall.pos(10000, 5000)
        a, b, c, d = moeb_drehen(a, b, c, d, x + I * y, @zufall.alpha)
      end
    end
    if d != 0
      a /= d
      b /= d
      c /= d
      d = 1
    end
    if [a, b, c, d] != [1, 0, 0, 1]
      w.push(Wandel.new(:moeb, [a, b, c, d], 0, @zufall.wenn))
    end
    w
  end

  def moeb_drehen(a, b, c, d, punkt, winkel)
    a, b, c, d = moeb_verschieben(a, b, c, d, -punkt)
    alpha = Math::cos(winkel) + I * Math::sin(winkel)
    a *= alpha
    b *= alpha
    return moeb_verschieben(a, b, c, d, punkt)
  end

  def moeb_verschieben(a, b, c, d, zahl)
    a += c * zahl
    b += d * zahl
    return [a, b, c, d]
  end

  def moeb_invertieren(a_alt, b_alt, c_alt, d_alt, zahl, r)
    c = a_alt - zahl * c_alt
    d = b_alt - zahl * d_alt
    a = c_alt * r - c * zahl
    b = d_alt * r - d * zahl
    return [a, b, c, d]
  end

  def nummern
    farben = []
    @nummern.each do |n|
      farben.push(n[0])
    end
    farben
  end

  def drehen(pos, alpha, zpos)
    richtung = pos - zpos
    richtung = (richtung.real * Math::cos(alpha) - richtung.imag * Math::sin(alpha)) + I * (richtung.imag * Math::cos(alpha) + richtung.real * Math::sin(alpha))
    return richtung + zpos
  end

  def spiegeln(pos)
    if pos.real.abs > pos.imag.abs
      return pos.real - pos.imag * I
    elsif pos.real.abs < pos.imag
      return -pos.real + I * pos.imag
    end
    return pos
  end

  def typdarstellen
    @wandlungen.each do |w|
      print w.was.to_s + " "
    end
    puts
  end

  def umgebung(pos)
    rueck = []
    3.times do |i|
      3.times do |j|
        rueck.push(pos + (i - 1 + I * j - I) * @verkleinerung)
      end
    end
    return rueck
  end

  def punktumgebungs_bewerten(pos)
    farbe = punkterstellen(pos.real, pos.imag)
    dif = 1.0/0
    3.times do |i|
      3.times do |j|
        if i != 1 or j != 1
          farbe2 = punkterstellen(pos.real - 1 + i, pos.imag - 1 + j)
          dif = [dif, @farbpallette.farbvergleich(farbe, farbe2)].min
        end
      end
    end
    dif
  end

  def bewertung
    farbbewertung = @farbpallette.farbbewertung
    sum = 0
    50.times do
      y = rand(@hoehe) + @zufall.verwischung / 2
      x = (@breite) + @zufall.verwischung / 2
      pos = ((x - @verschiebung.real) * @verkleinerung.to_f + I * (y - @verschiebung.imag.to_f) * @verkleinerung)
      a = punktumgebungs_bewerten(pos) ** 2 * 1000
      sum += a
    end
    puts
    puts farbbewertung
    print 5 - sum
    @schoenheit = farbbewertung + 5 - sum

  end

end


class Wandel
  def initialize(was, wie, wo, wenn)
    @was = was
    @wie = wie
    @wo = wo
    @wenn = wenn
  end
  attr_reader :was, :wie, :wo, :wenn
end
