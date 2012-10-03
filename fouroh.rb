require 'nokogiri'
require 'FileUtils'

def convert_old_prod_config_to_4(web_dir)
  xml = Nokogiri::XML::parse(File.open(web_dir, "r"))

  puts web_dir 

  if(xml.xpath(".//rewriter").length > 0)
    puts "broken errepareably"
    return
  end
  xml.xpath(".//system.serviceModel").remove()
  xml.xpath(".//system.webServer//security/authentication").remove()
  xml.xpath(".//configSections").remove()
  xml.xpath(".//runtime").remove()
  xml.xpath(".//system.web//compilation//assemblies").remove()
  xml.xpath(".//system.web//trace").remove()
  xml.xpath(".//system.webServer//handlers").remove()
  xml.xpath(".//system.web//httpHandlers").remove()
  xml.xpath(".//system.webServer//modules").remove()
  xml.xpath(".//system.web//httpModules").remove()
  xml.xpath(".//system.codedom").remove()
  xml.xpath(".//applicationSettings").remove()
  xml.xpath(".//appSettings//add[@key='EmailHost']").remove()
  xml.xpath(".//appSettings//add[@key='InProduction']").remove()
  xml.xpath(".//appSettings//add[@key='inProduction']").remove()
  xml.xpath(".//appSettings//add[@key='EmailUsername']").remove()
  xml.xpath(".//appSettings//add[@key='EmailPass']").remove()

  adminUrl = xml.xpath(".//appSettings//add[@key='AdminURL']")
  if(!adminUrl.nil? && adminUrl.length > 0)
    puts "admin url value is #{adminUrl.first()["value"]}"
    adminUrl.remove()
  end

  appSettings = xml.xpath(".//appSettings").first()
  puts "what the heck" if appSettings.nil?
  #set up connectionstrings
  conn = xml.xpath(".//connectionStrings//add[@name='SchoolPointe']")
  if(conn.length < 1)
    puts "connection needs set"
    conn = xml.xpath(".//connectionStrings")[0]
    realconn = xml.xpath(".//appSettings//add[@key='ConnectionString']")[0]

    conn.add_child('<add name="SchoolPointe" connectionString="'+realconn["value"]+'" providerName="System.Data.SqlClient" />')
    realconn.remove()
  end


  conn = xml.xpath(".//connectionStrings//add")
  conn.each do |p|
    if(p["name"] != "LoggingConnectionString" && p["name"] != "SchoolPointe")
      p.remove()
    end
  end

  mail = xml.xpath(".//system.net//mailSettings//smtp//network")
  if(!mail.nil?)
    mail = mail[0]
    if(mail["host"] == "mail.digitalschoolnetwork.net")
      mail["host"] = "10.10.1.26"
    end
    
    sender = xml.xpath(".//appSettings//add[@key='EmailServerSenderAddress']")
    if(sender.nil? || sender.length == 0)
      if(mail["host"] == "10.10.1.26")
        appSettings.add_child('<add key="EmailServerSenderAddress" value="donotreply@schoolpointe.com" />')
      else
        appSettings.add_child('<add key="EmailServerSenderAddress" value="'+ mail["userName"]+'" />')
      end
    end

  end

  compilation = xml.xpath(".//system.web//compilation")
  if(!compilation.nil? && compilation.length > 0)
    compilation[0]["targetFramework"] = "4.0"
  end

  #puts xml

  File.open(web_dir, "w+") do |f|
    f.write(xml.to_s)
  end

  #p xml.css("configuration appSettings add[key='ConnectionString']")
end

excludes = ["AbingdonIL", "crestviewoh", "settings.config", "packages.config", "repositories.config", "crestwoodlocal", "multicustomer", "soita"]
#"EdonNorthwest.vbproj", "NorwoodCitySchools.vbproj", "CrestwoodLocal.vbproj" , "OttawaHills.vbproj"]
i = 0
#convert_old_prod_config_to_4(".\\westerville\\westerville\\web.config")
def shouldskip(vb, excludes)
  excludes.each do |e|
    return true if vb.include?(e)
  end

  false
end
if(true)
  Dir["*/**/*.config"].each do |vb|
    skip = true if excludes.include?(File.basename(vb))  || shouldskip(vb, excludes)
      if !skip
      i += 1
      convert_old_prod_config_to_4(vb)
    end
  end
end
#convert_to_old_prod_config_to_4(".\\Westerville\\westerville\\web.config")
