require "/home/ulrich/ruby/blume2-0/Version.rb"
require "/home/ulrich/ruby/blume2-0/wenn/Wenn.rb"
require "/home/ulrich/ruby/blume2-0/wenn/Wenn_Punktgitter.rb"


class Wennspeicher
  def initialize(wenn, wkeit = 0)
    @wenn = wenn
    @wkeit = wkeit
  end
  
  attr_reader :wenn
  attr_accessor :wkeit
end

class Zufall

  VERSION = Version.new(3,5)
  WENNS = [
           Wennspeicher.new(Wenn, 100),
           Wennspeicher.new(Wenn_Punktgitter)
          ]

  def initialize(zufall)
    @zufall = zufall
    @wahl = :nichts
  end

  attr_reader :spiralzufall, :erstes, :spiralwahl, :wahlsumme, :verwischung, :faktor

  def gross?
    return @zufall >= 10**22
  end
  
  def waehlen
    if @zufall % @wahlsumme < @zykelwahl
      @wahl = :zykel
      @zufall /= @wahlsumme
      return
    end
    @zufall -= @zykelwahl
    if @zufall % @wahlsumme < @spiralwahl
      @wahl = :spiral
      @zufall /= @wahlsumme
      return
    end
    @zufall -= @spiralwahl
    if @zufall % @wahlsumme < @mehrfachspiralwahl
      @wahl = :mehrfachspiral
      @zufall /= @wahlsumme
      return
    end
    @zufall /= @wahlsumme
    @wahl = :moeb
  end

  def zykelwahl?
    waehlen
    return @wahl == :zykel
  end

  def spiralwahl?
    return @wahl == :spiral
  end
 
  def pos(bereich, schieben)
    x = (@zufall % bereich - schieben)
    @zufall /= bereich
    return x
  end
  
  def mehrfachspiralwahl?
    return @wahl == :mehrfachspiral
  end

  def kuerzen(x)
    @zufall /= x.to_i
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
    @zufall /= 10
    
    @wennsum = 0
    WENNS.each do |w|
      while @zufall % 2 != 0
        w.wkeit += 1
        w.wkeit *= 2
        @zufall /= 2
      end
      @zufall /= 2
      @wennsum += w.wkeit
    end
  end

  def wenn(was)
    if was != :moeb
      return WENNS[0].wenn.new(0, self)
    end
    wahl = @zufall % @wennsum
    @zufall /= @wennsum
    pos = @zufall % 10000 + Complex::I * (@zufall % 10001) - 5000 - 5000 * Complex::I
    WENNS.each_with_index do |w, i|
      wahl -= w.wkeit
      if wahl < 0
        negativ = false
        if i >= 1
          negativ = true if @zufall % 2 != 0
          @zufall /= 2
        end
        return w.wenn.new(pos, self)
      end
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
      wahl = (@zufall % 10 ** 20) / 10.0 ** 20
      @zufall /= 17
      return wahl
    end
  end

  
end
