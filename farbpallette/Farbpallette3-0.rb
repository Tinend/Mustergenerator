class Farbpallette

  I = Complex::I
  VERSION = "3-0"
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

  def farbrueckgabe
    frg = []
    @farben.each do |f|
      frg += f
    end
    return frg
  end

  def farben(pos)
    sum = 0
    farbe = [0,0,0]
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
          staerke = (Math::cos([((pos_hier.real - pos.real) * Math::PI * 2).abs, Math::PI].min) + 1) / 2
          staerke *= (Math::cos([((pos_hier.imag - pos.imag) * Math::PI * 2).abs, Math::PI].min) + 1) / 2
          farbe_hier = @farben[pos_hier_strich.imag][pos_hier_strich.real]
          farbe[0] += (farbe_hier / 65536) * staerke
          farbe[1] += ((farbe_hier / 256) % 256) * staerke
          farbe[2] += (farbe_hier % 256) * staerke
          sum += staerke
        end
      end
    end
    if sum > 0
      farbe.collect! {|f|
        f /= sum
      }
    end
    farbe
  end

  def klein?(c)
    c.real < @breite and c.real >= 0 and c.imag < @hoehe and c.imag >= 0
  end

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

  def nahfarbe(pos)
    faktor = [(pos.real * 2.0 / @breite - 1).abs, (2.0 * pos.imag / @hoehe - 1).abs].max
    verhaeltnis = Math::log(faktor)/Math::log(@zufall.faktor)
    if verhaeltnis > 0
      k = verhaeltnis.to_i + 1
    else
      k = verhaeltnis.to_i
    end
    pos = (pos - @breite / 2.0 - @hoehe / 2.0 * I) / @zufall.faktor ** k + @breite / 2.0 + @hoehe / 2.0 * I
    sum = 1
    farbe = [0,0,0]
    richtung = pos - I * @hoehe / 2.0 - @breite / 2.0
    richtung = richtung / richtung.abs
    klein = [@breite / richtung.real.abs / 2 / @zufall.faktor, @hoehe / richtung.imag.abs / 2 / @zufall.faktor].min
    mittel = ((pos - I * @hoehe / 2.0 - @breite / 2.0) / richtung).abs
    gross = [@breite / richtung.real.abs / 2, @hoehe / richtung.imag.abs / 2].min
    pos_klein = (richtung * klein * (@zufall.faktor - EPSILON) + I * @hoehe / 2.0 + @breite / 2.0)
    pos_gross = (richtung * gross / @zufall.faktor + I * @hoehe / 2.0 + @breite / 2.0)

    farbe = farben(pos)
    staerke = (Math::cos([((gross - mittel) / (gross - klein) * Math::PI * 2).abs, Math::PI].min) + 1) / 2
    sum += staerke
    farben(pos_gross).each_with_index do |f, i|
      farbe[i] += f * staerke
    end
    staerke = (Math::cos([((klein - mittel) / (gross - klein) * Math::PI * 2).abs, Math::PI].min) + 1) / 2
    sum += staerke
    farben(pos_klein).each_with_index do |f, i|
      farbe[i] += f * staerke
    end
    if sum > 0
      farbe.collect! {|f|
        f /= sum
      }
    end
    farbe
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
