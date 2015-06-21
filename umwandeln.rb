def umwandeln(feld, dateiname, farben, nummern, zufall, bewertung)
  file = File.open(dateiname, 'w')
  file.puts '/* XPM */'
  file.puts "Zufall:"
  file.puts zufall
  file.puts "Bewertung:"
  file.puts bewertung
  file.puts 'static char * bla2_xpm[] = {'
  file.print '"', feld[0].length, ' ', feld.length, ' ', nummern.length, ' ', farben.laenge, '"'
  file.puts
  nummern.each_with_index do |n, i|
    file.print '"', farben.zeichen_machen(n, i), " c ", farben.farbe(n), '"'
    file.puts
  end
  feld.each_with_index do |zeile, i|
    file.print '"'
    zeile.each do |symbol|
      file.print farben.zeichen_suchen(symbol)
    end
    file.print '"'
    file.puts
  end
end
