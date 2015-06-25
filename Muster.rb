#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "/home/ulrich/ruby/blume2-0/Version.rb"
require "/home/ulrich/ruby/blume2-0/umwandeln.rb"
require "/home/ulrich/ruby/blume2-0/felder/Feld3-0.rb"
require "/home/ulrich/ruby/blume2-0/Farben.rb"
require "/home/ulrich/ruby/blume2-0/Zentrum.rb"
require "/home/ulrich/ruby/blume2-0/wenn/Wenn.rb"
require "/home/ulrich/ruby/blume2-0/wenn/Wenn_Punktgitter.rb"

force = false
fzufall = 0
VERSION = Version.new(3,4)
hoehe = 480
breite = 480
verkleinerung = 1000
verschiebung = breite / 2.0 + Complex::I * hoehe / 2.0
version = [Feld::VERSION, Farben::VERSION, Bewerter::VERSION, Farbpallette::VERSION, Zufall::VERSION, VERSION].max.to_s
bewerter = Bewerter.new
100.times do
  z = 1000 ** 100
  until rand(1000) == 0
    z *= 10
  end
  zufall = rand(z)
  if fzufall > 0
    zufall = fzufall
  end
  p zufall
  zufallsgenerator = Zufall.new(zufall)
  farbpallette = Farbpallette.new(zufallsgenerator)
  feld = Feld.new(zufallsgenerator, hoehe, breite, verkleinerung, verschiebung, farbpallette)
  feld.typdarstellen
  bewertung = bewerter.gesammt_bewerten(farbpallette, feld)
  puts
  p bewertung
  if bewertung < 0 and not force and fzufall == 0
    next
  end
  feld.felderstellen
  puts "Bild speichern"
  nummern = feld.nummern
  farben = Farben.new(nummern.length)
  puts [feld.schoenheit, bewertung]
  dateiname = "/home/ulrich/ruby/blume2-0/bilder/muster#{version.to_s}_#{zufall%(10**30)}.xpm"
  
  umwandeln(feld.feld, dateiname, farben, nummern, zufall, bewertung)
  exit if fzufall > 0
end
