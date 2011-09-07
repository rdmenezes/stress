#Here you can insert extra classes or what you need, then you have to include this file in your controller/model

require 'nokogiri'

class XMLTestcase < Nokogiri::XML::SAX::Document

	def initialize(simulation,filename)
		@filename =filename
		@simulation =simulation
	end

	def start_document
		puts "Start parsing XML!"
	end
	
	def end_document
		puts "Parsing END!"
	end

	def start_element name, attrs = []
		position = 0
		data = nil
		case name
		when "testcase"
			id=0
			run=0
			attrs.each do |p|
				id = p.second if p.first =="id"
				run = p.second if p.first =="run"
			end
			@testcase = Testcase.new(:filename => @filename, :id_anomaly => id, :run => run)
			@simulation.testcases << @testcase
			@simulation.save
		when "send"
			position = @testcase.frames.last.position.to_i+1 unless @testcase.frames.last == nil
			attrs.each do |p|
				data = p.second if p.first =="data"
			end
			
			@testcase.frames << SentFrame.new(:data => data, :position => position)
		when "read"
			position = @testcase.frames.last.position.to_i+1 unless @testcase.frames.last == nil
			read = nil
			attrs.each do |p|
				read = p.second if p.first =="name"
				data = p.second if p.first =="data"
			end
			if read == "Data received" 
				@testcase.frames << ReadFrame.new(:data => data, :position => position) 
			else
				@testcase.frames << NoResponse.new(:position => position)
			end
		else
		
		end
	end

#	def end_element name
#		puts "#{name} ended"
#	end

end

class XMLOutputParser

	def parse(simulation, filename)
		puts "Read: "+filename
		
		sax_parse(simulation, filename)
		
		puts "Done."
	end
	
	def sax_parse(simulation, filename)
		# Create a new parser
		parser = Nokogiri::XML::SAX::Parser.new(XMLTestcase.new(simulation,filename))

		# Feed the parser some XML
		parser.parse_file(filename)
	end
	
	def xml_parse(simulation, filename)
		xmlreader = Nokogiri::XML::Reader.from_io(filename)
		begin
		
		
		rescue Nokogiri::SyntaxError 
			puts $!.inspect		
			puts $!.to_s+" at line:"+$!.line.to_s	
		end
		
		#TODO: chiudere il file nel xml reader
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