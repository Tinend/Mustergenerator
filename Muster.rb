#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "/home/ulrich/ruby/blume2-0/umwandeln.rb"
require "/home/ulrich/ruby/blume2-0/felder/Feld3-0.rb"
require "/home/ulrich/ruby/blume2-0/Farben.rb"
require "/home/ulrich/ruby/blume2-0/Zentrum.rb"

hoehe = 480
breite = 480
verkleinerung = 200
verschiebung = breite / 2.0 + Complex::I * hoehe / 2.0
100.times do
  z = 1000 ** 100
  until rand(1000) == 0
    z *= 10
  end
  zufall = rand(z)
  p zufall
  zufallsgenerator = Zufall.new(zufall)
  farbpallette = Farbpallette.new(zufallsgenerator)
  feld = Feld.new(zufallsgenerator, hoehe, breite, verkleinerung, verschiebung, farbpallette)
  bewerter = Bewerter.new
  feld.typdarstellen
  bewertung = bewerter.gesammt_bewerten(farbpallette, feld)
  bewertung_alt = feld.bewertung
  puts
  p bewertung
  feld.felderstellen
  puts "Bild speichern"
  nummern = feld.nummern
  farben = Farben.new(nummern.length)
  version = Feld::VERSION
  puts [feld.schoenheit, bewertung]
  dateiname = "/home/ulrich/ruby/blume2-0/bilder/muster#{version}_#{zufall%(10**30)}.xpm"
  
  umwandeln(feld.feld, dateiname, farben, nummern, zufall, bewertung)
end
