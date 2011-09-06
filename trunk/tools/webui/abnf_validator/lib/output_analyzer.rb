#Here you can insert extra classes or what you need, then you have to include this file in your controller/model

require 'nokogiri'

class XMLOutputParser

	def parse(simulation, filename)
		puts "Read: "+filename
		xmlreader = Nokogiri::XML::Reader.from_io(filename)
		begin
		
		
		rescue Nokogiri::SyntaxError 
			puts $!.inspect		
			puts $!.to_s+" at line:"+$!.line.to_s	
		end
		
		#TODO: chiudere il file nel xml reader
		
		
		puts "Done."
	end
	def read_data(file)
		@result = Hash.new
		rtt = Array.new
		result = Array.new
      xmlreader = Nokogiri::XML::Reader.from_io(file)
		begin
      	xmlreader.each do |l|
      	   case l.attribute("name") 
					when "No Packet Received"
						
					when "Report"
      	      	data = l.attribute("data")
      	      	adata = data.split("],")
      	      	adata.each do|d|
      	      	   d.tr!('[] ','')
      	      	   result << d.split(',')
      	      	end
					when "RTT Report"
						rtt << l.attribute("data")
					else
						#do nothing
      	   end
      	end
		rescue Nokogiri::SyntaxError 
			puts $!.inspect		
			puts $!.to_s+" at line:"+$!.line.to_s	
			exit -1
		end

     	@result["Report"] = result
		@result["RTT"] = rtt
		a = Array.new
		a << result[0][-1]
		a << result[-2][-1]	
		return a
	end
end
