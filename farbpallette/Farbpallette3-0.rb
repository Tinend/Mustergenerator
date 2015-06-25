# -*- coding: utf-8 -*-
require "/home/ulrich/ruby/blume2-0/Version.rb"
class Farbpallette

  I = Complex::I
  VERSION = Version.new(3,0)
  EPSILON = 0.00000001

  def initialize(zufall)
    @zufall = zufall
    @hoehe = zufall.minihoehe
    @breite = zufall.minibreite
    @zentrum = @hoehe / 2.0 * I + @breite / 2.0
    @farben = farbenerstellen
    @farben.each do |m|
      p m
    end

  end

  # gibt alle Farben zurück
  def farbrueckgabe
    frg = []
    @farben.each do |f|
      frg += f
    end
    return frg
  end

  # ordnet einer Komplexen Zahl eine Zahl zu, beachtet die notwendigen Streckungen nicht, ausserdem sind Farbwerte nicht ganzzahlig
  def farben(pos)
    sum = 0
    farb_wahl = []
    gewichte = []
    3.times do |i|
      3.times do |j|
        if i != 1
          x = pos.real.to_i + i / 2
          x_strich = pos.real.to_i + (i / 2) * 2 - 1
        else 
          x = pos.real
          x_strich = pos.real.to_i
        end
        if j != 1
          y = pos.imag.to_i + j / 2
          y_strich = pos.imag.to_i + (j / 2) * 2 - 1
        else
          y = pos.imag
          y_strich = pos.imag.to_i
        end
        pos_hier = x + I * y
        pos_hier_strich = x_strich + I * y_strich
        if klein?(pos_hier_strich)
          gewicht = ((Math::cos([((pos_hier.real - pos.real) * Math::PI * 2).abs, Math::PI].min) + 1) / 2) ** 2
          gewicht *= ((Math::cos([((pos_hier.imag - pos.imag) * Math::PI * 2).abs, Math::PI].min) + 1) / 2) ** 2
          farbe_hier = @farben[pos_hier_strich.imag][pos_hier_strich.real]
          farb_wahl.push([farbe_hier / 65536 % 256, farbe_hier / 256 % 256, farbe_hier % 256])
          sum += gewicht
          gewichte.push(gewicht)
        end
      end
    end
    gewichte.collect! {|g| g / sum}
    farbe = durchschnitt(gewichte, farb_wahl)
    farbe
  end

  # gewichteter Farbdurchschnitt, erhält Kräftigkeit der Farben sowie deren Helligkeit
  def durchschnitt(gewichte, farb_wahl)
    hell = 0.0
    sum = [0,0,0]
    kraft = 0
    farb_wahl.each_with_index do |f,i|
      hell += (f[0] + f[1] + f[2]) * gewichte[i]
      sum[0] += f[0] * gewichte[i]
      sum[1] += f[1] * gewichte[i]
      sum[2] += f[2] * gewichte[i]
      kraft += kraeftig(f) * gewichte[i]
    end
    sum[0] -= hell / 3
    sum[1] -= hell / 3
    sum[2] -= hell / 3
    minus_max_sum = sum.min
    plus_max_sum = sum.max
    if minus_max_sum != 0
      faktor = [[(kraft - 1.0 / 3) * hell / minus_max_sum, (kraft - 1.0 / 3) * (765 - hell) / minus_max_sum].min, [(1.0 / 3 - kraft) * hell / plus_max_sum, (1.0 / 3 - kraft) * (765 - hell) / plus_max_sum].min].min
    else
      faktor = 1
    end
    farbe = [faktor * sum[0] + hell / 3, faktor * sum[1] + hell / 3, faktor * sum[2] + hell / 3]
    return farbe
  end

  # Funktion zur Berechnung, wie kräftig eine Farbe ist
  def kraeftig(farbe)
    hell = farbe[0] + farbe[1] + farbe[2]
    if hell == 0 or hell == 765
      return 1 / 3.0
    end
    min_rot = [(255 - farbe[0]) / (765.0 - hell), farbe[0] / hell.to_f].min
    min_blau = [(255 - farbe[1]) / (765.0 - hell), farbe[1] / hell.to_f].min
    min_gruen = [(255 - farbe[2]) / (765.0 - hell), farbe[2] / hell.to_f].min
    return [min_rot, min_blau, min_gruen].min
  end

  # gibt zurück, ob eine Komplexe Zahl bereits im Rechteck drinnen ist, in dem die Farben bestimmt sind.
  def klein?(c)
    c.real < @breite and c.real >= 0 and c.imag < @hoehe and c.imag >= 0
  end

  # erstellt die Farbmatrix
  def farbenerstellen
    m = []
    @hoehe.times do
      m.push([])
      @breite.times do
        r = @zufall.farbe
        b = @zufall.farbe
        g = @zufall.farbe
        m[-1].push(g * 65536 + b * 256 + r)
      end
    end
    m
  end

  # ordnet einer Reellen Zahl eine Farbe zu, beachtet die Streckungen, Rückgaben ganzzahlig
  def nahfarbe(pos)
    faktor = [(pos.real * 2.0 / @breite - 1).abs, (2.0 * pos.imag / @hoehe - 1).abs].max
    verhaeltnis = Math::log(faktor)/Math::log(@zufall.faktor)
    if verhaeltnis > 0
      k = verhaeltnis.to_i + 1
    else
      k = verhaeltnis.to_i
    end
    pos = (pos - @breite / 2.0 - @hoehe / 2.0 * I) / @zufall.faktor ** k + @breite / 2.0 + @hoehe / 2.0 * I
    gewichte = []
    farb_wahl = []
    richtung = pos - I * @hoehe / 2.0 - @breite / 2.0
    richtung = richtung / richtung.abs
    klein = [@breite / richtung.real.abs / 2 / @zufall.faktor, @hoehe / richtung.imag.abs / 2 / @zufall.faktor].min
    mittel = ((pos - I * @hoehe / 2.0 - @breite / 2.0) / richtung).abs
    gross = [@breite / richtung.real.abs / 2, @hoehe / richtung.imag.abs / 2].min
    pos_klein = (richtung * klein * (@zufall.faktor - EPSILON) + I * @hoehe / 2.0 + @breite / 2.0)
    pos_gross = (richtung * gross / @zufall.faktor + I * @hoehe / 2.0 + @breite / 2.0)

    farb_wahl.push(farben(pos))
    farb_wahl.push(farben(pos_gross))
    farb_wahl.push(farben(pos_klein))
    gewichte.push(1)
    gewichte.push(((Math::cos([((gross - mittel) / (gross - klein) * Math::PI * 2).abs, Math::PI].min) + 1) / 2) ** 2)
    gewichte.push(((Math::cos([((klein - mittel) / (gross - klein) * Math::PI * 2).abs, Math::PI].min) + 1) / 2) ** 2)
    sum = 0
    gewichte.each do |g|
      sum += g
    end
    gewichte.collect! do |g|
      g / sum
    end
    farbe = durchschnitt(gewichte, farb_wahl)
    farbe.collect! {|f| (f + 0.5).to_i}
    return farbe
  end

  def farbvergleich(farbe1, farbe2)
    punkte = 0.0
    farbe1.each_with_index do |f, i|
      punkte += (f - farbe2[i]).abs
    end
    return punkte
  end


  def farb_umgebungsvergleich(x, y, farbe)
    punkte = []
    vony = [y - 1, 0].max
    bisy = [y + 1, @farben.length - 1].min
    @farben[vony .. bisy].each do |farbzeile|
      vonx = [x - 1, 0].max
      bisx = [x + 1, farbzeile.length - 1].min
      farbzeile[vonx .. bisx].each do |mx|
        farbe_neu = [mx / 256 ** 2 % 256, mx / 256 % 256, mx % 256]
        punkte.push(farbvergleich(farbe, farbe_neu))
      end
    end
    punkte
  end

  def farbbewertung
    farbbewertungen = []
    @farben.each_with_index do |farbzeile, y|
      farbzeile.each_with_index do |einzelfarbe, x|
        farbe = [einzelfarbe / 256 ** 2 % 256, einzelfarbe / 256 % 256, einzelfarbe % 256]
        farbbewertungen += farb_umgebungsvergleich(x, y, farbe)
      end
    end
    schnitt = 0.0
    farbbewertungen.each do |fb|
      schnitt += fb
    end
    schnitt /= farbbewertungen.length
    abweichungen = 0.0
    farbbewertungen.each do |fb|
      abweichungen += (schnitt - fb).abs / farbbewertungen.length
    end
    Math::log((abweichungen - 128).abs / 10) * 5
  end


end
