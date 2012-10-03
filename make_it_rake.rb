require 'fileutils'
require 'erb'

def render_rakefile(filename, output, siteName)
  tmpl =  ERB.new(File.read(File.expand_path(filename)))

  siteClass = siteName[0].upcase + siteName[1..-1]

  assemblyInfo = tmpl.result(binding)
  #puts assemblyInfo
  File.delete(File.expand_path(output)) if File.exists?(File.expand_path(output))
  
  File.open(File.expand_path(output), 'w') do |f2|
    f2.write(assemblyInfo.to_s)
  end
  
  puts "rakefile success"
end

def render_sln(filename, output, site)
  tmpl =  ERB.new(File.read(File.expand_path(filename)))
  assemblyInfo = tmpl.result(binding)
  #puts assemblyInfo
  File.delete(File.expand_path(output)) if File.exists?(File.expand_path(output))
  
  File.open(File.expand_path(output), 'w') do |f2|
    puts File.expand_path(output)
    f2.write(assemblyInfo.to_s)
  end
  
  puts "sln success"
end

def rake_me(sln)
  FileUtils::copy("rakefile.temp", File.join(File.dirname(sln), "rakefile"))

  siteName = File.basename(sln)
  siteName = siteName.chomp(File.extname(sln))

  puts siteName

  render_rakefile("site.rake.temp", File.join(File.dirname(sln),  siteName.downcase + ".rake"), siteName )

end

def sln_me(dir)
  puts dir 
  render_sln("site.sln.erb", File.join(File.expand_path(dir), "#{dir}.sln"), dir )
end

def inventory_projects(dir, output)
  sln =  File.readlines(File.join(File.expand_path(dir),"#{dir}.sln"))

  projects = {}
  sln.each do |line|
    if(line.start_with? "Project")
      proj_def = line.gsub(/Project\("\{(.*?)\}"\) = "(.*?)",.*$/, '{\1},\2').split(",")
      projects[proj_def[1]] = proj_def[0]
    end
  end

  File.open(File.join(File.expand_path(output), "#{dir}.projs"), 'w') do |f2|
      projects.keys.sort!().each do |key|
        f2.write("#{key}, #{projects[key]}\n")
      end
  end

end




@nogen = []

Dir["*"].each do |site|
# inventory_projects(site, ".") if File.directory?(site)
  if(File.directory?(site))
    puts "*** skipping *** #{site} " if @nogen.include?(site)
    sln_me(site) unless @nogen.include?(site)
    sln = File.join(site,"#{site}.sln")
    rake_me(sln) unless @nogen.include?(File.split(sln)[0])
  end
end

#Dir["**/*.sln"].each do |sln|
#end

#rake_me("WorthGA/WorthGA.sln")
#










