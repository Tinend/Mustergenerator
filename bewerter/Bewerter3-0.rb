# -*- coding: utf-8 -*-
require "/home/ulrich/ruby/blume2-0/Version.rb"

class Bewerter

  VERSION = Version.new(3,0)
  ABZUGSKONSTANTE = 100000
  MAXDIFF = 40
  PUNKTEKONSTANTE = 100

  def initialize
    @bewertung = 0
  end

  attr_reader :bewertung

  # streckt die Farben hoch, sodass ihr durchschnitt 255 ist und vergleicht sie dann.
  def hell(farbe1, farbe2)
    sum1 = 0
    farbe1.each do |f|
      sum1 += f
    end
    if sum1 == 0
      hell1 = [255,255,255]
    else
      hell1 = [farbe1[0] * 255.0 / sum1, farbe1[1] * 255.0 / sum1, farbe1[0] * 255.0 / sum1]
    end
    sum2 = 0
    farbe2.each do |f|
      sum2 += f
    end
    if sum2 == 0
      hell2 = [255,255,255]
    else
      hell2 = [farbe2[0] * 255.0 / sum2, farbe2[1] * 255.0 / sum2, farbe2[0] * 255.0 / sum2]
    end
    sum = 0
    3.times do |i|
      sum += (hell1[i] - hell2[i]).abs
    end
    sum
  end
  
  # streckt die Farben von Weiss(255) nach Schwarz(0) hinunter und vergleicht sie dann.
  def dunkel(farbe1, farbe2)
    sum1 = 0
    farbe1.each do |f|
      sum1 += 255 - f
    end
    if sum1 == 0
      dunkel1 = [255,255,255]
    else
      dunkel1 = [(255 - farbe1[0]) * 255.0 / sum1, (255 - farbe1[1]) * 255.0 / sum1, (255 - farbe1[0]) * 255.0 / sum1]
    end
    sum2 = 0
    farbe2.each do |f|
      sum2 += 255 - f
    end
    if sum2 == 0
      dunkel2 = [255,255,255]
    else
      dunkel2 = [(255 - farbe2[0]) * 255.0 / sum2, (255 - farbe2[1]) * 255.0 / sum2, (255 - farbe2[0]) * 255.0 / sum2]
    end
    sum = 0
    3.times do |i|
      sum += (dunkel1[i] - dunkel2[i]).abs
    end
    sum
  end

  # gibt helligkeitsunterschied der Farben zurück
  def kontrast(farbe1, farbe2)
    sum1 = 0
    farbe1.each do |f|
      sum1 += f
    end
    sum2 = 0
    farbe2.each do |f|
      sum2 += f
    end
    return (sum1 - sum2).abs
  end
  
  # gibt array mit den Vergleichen hell, dunkel, kontrast zurück
  def farbvergleich(farbarray1, farbarray2)
    return [hell(farbarray1, farbarray2), dunkel(farbarray1, farbarray2), kontrast(farbarray1, farbarray2)]
  end
  
  #bewertet die Farbauswahl
  def bewerte_farben(farben)
    bewertung = 0
    farbarray = farben.farbrueckgabe
    farbarray.each do |farbe1|
      farbarray.each do |farbe2|
        farbarray1 = [farbe1 / 65536, (farbe1 / 256) % 256, farbe1 % 256]
        farbarray2 = [farbe2 / 65536, (farbe2 / 256) % 256, farbe2 % 256]
        bewertung += standart_vergleich(farbarray1, farbarray2)
      end
    end
    bewertung /= (farbarray.length * (farbarray.length - 1)) ** 0.5 * 10
    puts "Farbe", bewertung
    bewertung
  end

  # typischer Vergleich zweier Farben.
  def standart_vergleich(farbe1, farbe2)
    vergleich = farbvergleich(farbe1, farbe2)
    return (vergleich[0] * vergleich[1]) ** 0.5 + vergleich[2] 
  end

  #berechnet Kantengewichte eines minimalen aufspannenden Baumes (von 3*3 Farben)
  def prims(punkte)
    baum = [0]
    gewichte = []
    8.times do
      min = 100000
      minpos = 0
      punkte.each_with_index do |p, i|
        unless baum.any? {|b| b == i}
          baum.each do |b|
            wert = standart_vergleich(p, punkte[b])
            if wert < min
              min = wert
              minpos = i
            end
          end
        end
      end
      baum.push(minpos)
      gewichte.push(min)
    end
    gewichte
  end

  # bewertet einen Punkt und die acht umgebenden Punkte
  def punkt_bewerten(pos, umgebung, bild)
    punkte = []
    umgebung.each do |b|
      punkte.push(bild.punkterstellen(b.real, b.imag))
    end
    gewichte = prims(punkte)
    bewertung = gewichte.max
    qm = 0
    gewichte.each do |g|
      qm += (g - 10) * (g - 10).abs / 8.0 + 12.5
    end
    p [qm, gewichte.max]
    bewertung -= qm ** 0.5
    return bewertung
  end

  # bewertet 20 zufällige Punkte in Abhängigkeit von ihrer Umgebung
  def bewerte_kontrast(bild)
    bewertung = 0
    20.times do
      pos = bild.zufallspos
      umgebung = bild.umgebung(pos)
      bewertung += punkt_bewerten(pos, umgebung, bild)
    end
    return bewertung
  end

  # verrechnet die einzelnen Bewertungen
  def gesammt_bewerten(farben, bild)
    bewertung1 = bewerte_farben(farben)
    bewertung2 = bewerte_kontrast(bild)
    puts "Gesammt", bewertung1, bewertung2
    if bewertung1 < 0 and bewertung2 < 0
      @bewertung = - bewertung1 * bewertung2 - ABZUGSKONSTANTE
    elsif bewertung1 < 0 or bewertung2 < 0
      @bewertung = bewertung1 * bewertung2 - ABZUGSKONSTANTE
    else
      @bewertung = bewertung1 * bewertung2 - ABZUGSKONSTANTE
    end
    @bewertung
  end
end
