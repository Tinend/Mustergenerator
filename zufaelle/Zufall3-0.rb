class Zufall

  Version = "V3-0"

  def initialize(zufall)
    @zufall = zufall
  end

  attr_reader :spiralzufall, :erstes, :spiralwahl, :wahlsumme, :verwischung, :faktor

  def gewaelt
    @zufall /= @wahlsumme
  end

  def gross?
    return @zufall >= 10**22
  end

  def zykelwahl?
    return @zufall % @wahlsumme < @zykelwahl
  end

  def spiralwahl?
    return @zufall % @wahlsumme < @zykelwahl + @spiralwahl
  end
 
  def pos(bereich, schieben)
    x = (@zufall % bereich - schieben)
    @zufall /= bereich
    return x
  end
  
  def mehrfachspiralwahl
    @zufall % @wahlsumme < @zykelwahl + @spiralwahl + @mehrfachspiralwahl
  end

  def kuerzen(x)
    @zufall /= x
  end

  def farbe
    f = ((Math::cos((@zufall % 1000) / 1000.0 * Math::PI) + 1) * 127.5 + 0.5).to_i
    @zufall /= 1000
    return f
  end

  def alpha
    return (@zufall % 314159265359) % (2 * Math::PI)
  end

  def vorzeichen
    e = @zufall % 2 * 2 - 1
    @zufall /= 2
    return e
  end

  def minihoehe
    @zufall % 6 + 1
  end
  
  def minibreite
    @zufall % 5 + 2
  end

  def zufall_erstellen
    @drehzahl = @zufall % 3
    @zufall /= 3
    @spiralzufall = @zufall % 3
    @zufall /= 3
    if @zufall % 3 == 0
      @erstes = :zykel
    elsif @zufall % 3 == 1
      @erstes = :spiral
    elsif @zufall % 3 == 2
      @erstes = :mehrfachspiral
    end
    @zufall /= 3
    @spiralwahl = @zufall % 3
    @zufall /= 3
    @zykelwahl = @zufall % 3
    @zufall /= 3
    @mehrfachspiralwahl = @zufall % 3
    @zufall /= 3
    if @spiralwahl * @zykelwahl * @mehrfachspiralwahl != 0 and @zufall % 4 == 0
      if @zufall % 3 == 0
        @spiralwahl = 0
      elsif @zufall % 3 == 1
        @zykelwahl = 0
      elsif @zufall % 3 == 2
        @mehrfachspiralwahl = 0
      end
    end
    @zufall /= 4
    if @spiralwahl * @zykelwahl + @mehrfachspiralwahl * @zykelwahl + @spiralwahl * @mehrfachspiralwahl != 0 and @zufall % 4 == 0
      if @zufall % 3 == 0
        @spiralwahl = 0
      elsif @zufall % 3 == 1
        @zykelwahl = 0
      elsif @zufall % 3 == 2
        @mehrfachspiralwahl = 0
      end
    end
    @zufall /= 12
    @wahlsumme = @spiralwahl * 5 + @zykelwahl * 5 + @mehrfachspiralwahl * 5 + 1
    @verwischung = @zufall % 2 + 1

    @verwischung = 1


    @faktor = 1.1
    while @zufall % 10 != 0
      @faktor += 0.1
      @zufall /= 10
    end
  end

  def drehzahl
    if @drehzahl == 0
      rueck = @zufall % 7 + 2
      @zufall /= 7
      return rueck
    elsif @drehzahl == 1
      return (- Math::log(zufaellig(0)) * 5 + 2).to_i
    else
      return (4 / (Math::cos(zufaellig(0) * Math::PI) + 1)).to_i
    end
  end

  def zufaellig(x)
    if x > 0
      rueck = @zufall % x
      @zufall /= x
      return rueck
    else
      @zufall /= 3
      return (@zufall % 10 ** 20) / 10.0 ** 20
    end
  end
end
