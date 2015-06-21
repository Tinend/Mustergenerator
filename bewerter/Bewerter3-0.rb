class Bewerter

  VERSION = 3-0
  ABZUGSKONSTANTE = 10000

  def initialize
    @bewertung = 0
  end

  attr_reader :bewertung

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
 
  def farbvergleich(farbarray1, farbarray2)
    return [hell(farbarray1, farbarray2), dunkel(farbarray1, farbarray2), kontrast(farbarray1, farbarray2)]
  end
  
  def bewerte_farben(farben)
    bewertung = 0
    farbarray = farben.farbrueckgabe
    farbarray.each do |farbe1|
      farbarray.each do |farbe2|
        farbarray1 = [farbe1 / 65536, (farbe1 / 256) % 256, farbe1 % 256]
        farbarray2 = [farbe2 / 65536, (farbe2 / 256) % 256, farbe2 % 256]
        vergleich = farbvergleich(farbarray1, farbarray2)
        bewertung += (vergleich[0] * vergleich[1]) ** 0.5 + vergleich[2] 
      end
    end
    bewertung /= (farbarray.length * (farbarray.length - 1)) ** 0.5 * 10
    puts "Farbe", bewertung
    bewertung
  end

  def bewerte_kontrast(bild)
    bewertung = 0
    nullsum = 0
    mindiffsum = 0
    diffsum = 0
    20.times do
      pos = bild.zufallspos
      farbe1 = bild.punkterstellen(pos.real, pos.imag)
      mindiff = []
      punktbewertung = 0.0
      bild.umgebung(pos).each do |b|
        farbe2 = bild.punkterstellen(b.real, b.imag)
        vergleich = farbvergleich(farbe1, farbe2)
        diff = (vergleich[0] * vergleich[1]) ** 0.5 + vergleich[2] 
        if diff == 0
          punktbewertung -= 1
          nullsum += 1
        end
        mindiff.push(diff)
        punktbewertung += diff ** 2 / 1000
        diffsum += diff ** 2 / 1000
      end
      mindiff.sort!
      mindiff.each_with_index do |md, i|
        punktbewertung -= md ** 2 / (70 * 2 ** i)
        mindiffsum += md ** 2 / (70 * 2 ** i)
      end
      bewertung += punktbewertung
    end
    p ["kontrast", bewertung, nullsum, mindiffsum, diffsum]
    return bewertung
  end

  def gesammt_bewerten(farben, bild)
    bewertung1 = bewerte_farben(farben)
    bewertung2 = bewerte_kontrast(bild)
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
