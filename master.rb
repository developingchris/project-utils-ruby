require 'FileUtils'

Dir["*/*/index.aspx"].each do |index|
  #puts index

  directive = ""
  reading = true
  open(File.expand_path(index), "r") do |f|
    while(reading)
      char = f.readchar
      directive << char  unless char == "\n"
      reading = false if directive.include? "%>"
    end
  end

  #puts directive
  match = /masterpagefile="(.+?)"/i.match(directive)

  if(match.nil?)
    puts "fix masterpages for #{index}"
  end    
  #puts match.captures unless match.nil?
end
