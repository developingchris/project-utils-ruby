require 'nokogiri'
require 'FileUtils'

def remap_references(vbproj)

  real_refs = Nokogiri::XML::parse(File.open(File.join(File.split(File.expand_path(__FILE__))[0],"vprojsection.temp"), "r"))

  path = File.expand_path(vbproj)

  xml = Nokogiri::XML::parse(File.open(path, "r"))


  node = xml.search("Reference").first.parent

  node.children.each {|n| n.remove}

  #puts real_refs
  real_refs.search("ItemGroup").children.each do |n|
    node << n 
  end


  #xml.search("ItemGroup").each do |g|

  #refs.remove
  File.open(path, 'w') do |f2|
    f2.write(xml.to_s)
  end

end

def remove_items_not_on_disk(vbproj)
  puts vbproj
  path = File.expand_path(vbproj)
  directory = File.dirname(path)
  xml = Nokogiri::XML::parse(File.open(path, "r"))

  xml.search("Content").each do |n|
    check_if_node_exists(directory,n)
  end

  xml.search("EmbeddedResource").each do |n|
    check_if_node_exists(directory,n)
  end

  xml.search("Compile").each do |n|
    check_if_node_exists(directory,n)
  end

  xml.search("None").each do |n|
    check_if_node_exists(directory,n)
  end

  xml.search("Folder").each do |n|
    check_if_node_exists(directory,n)
  end

  xml.search("ItemGroup").each do |group|
    puts group.children.length 
    group.remove if group.children.length == 0
  end



  File.open(path, 'w') do |f2|
    f2.write(xml.to_s.gsub(/\n\s*\n/,"\n"))
  end
end

def check_if_node_exists(directory,n)
  full_name = File.join(directory,n["Include"])
  if(File.exists?(full_name))
    print "." 
  else
    print "F(#{full_name}"
    n.remove
  end
end

def ensure_directory(web_dir, dir)
  dir_path = File.join(File.expand_path(web_dir), dir)
  has_dir = File.exists?(dir_path)

  if(!has_dir)
    puts "making #{dir_path}"
    FileUtils::mkdir(dir_path)
    File.open(File.join(dir_path,"deleteme.txt"), 'w') do |f2|
      f2.write("placeholder")
    end
  end
end

excludes = ["soita.vbproj","npls_web.vbproj"]
#".vbproj", "NorwoodCitySchools.vbproj", "CrestwoodLocal.vbproj" , "OttawaHills.vbproj"]

Dir["*/**/*.vbproj"].each do |vb|
  skip = true if excludes.include?(File.basename(vb))
  if !skip
    puts vb
    #remove_items_not_on_disk(vb)
    remap_references(vb)
  end
  ##web_dir = File.split(vb)[0]
  ##ensure_directory(web_dir, "css")
  ##ensure_directory(web_dir, "js")
end

