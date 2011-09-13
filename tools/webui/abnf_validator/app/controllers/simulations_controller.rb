class SimulationsController < ApplicationController
	require 'open3'
	require 'lib/plugin.rb'
	require 'fileutils'

	#INDEX OF SIMULATIONS, LISTS ALL SIMULATIONS
	def index
		@simulations = check_running_simulations
		@plugins = Array.new
		xml_file_list = Dir.glob("app/*.xml")
		xml_file_list.each do |f|
			@plugins << Plugin.new(f)
		end
		respond_to {|format| format.html}
	end
	
	def update_simulations_list
		@simulations = check_running_simulations
		render :partial => "simulations_list"
	end

	#VALIDATE ABNF FILE BEFORE SIMULATION LAUNCH
	def validate_before_simulation
		File.open("script/temp", "w") {|f| f.write(params[:content])}
		stdin, stdout, stderr = Open3.popen3('script/parseabnf -i script/temp')
		@result = stderr.read
		if @result.length == 0
			render :text => "true" and return
		else
			session[:messages] = {:type => "err", :msg => "Not valid abnf!"}
			render :text => "false" and return
		end
	end

	#LAUNCH SIMULATION
	def lunch_simulation
		begin
			raise Exceptions::MissingParameters if params[:address].length < 1 or params[:port].length < 1 or params[:output].length < 1
			raise Exceptions::FileExists if File.exist? "results/#{params[:output]}"
			#raise Exceptions::InvalidIPProvided unless params[:address] =~ /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/
			raise Exceptions::InvalidPortProvided if params[:port].to_i < 1 or params[:port].to_i > 65535
			File.open("script/temp2", "w") {|f| f.write(params[:abnf])}
			Dir.mkdir("results/" + params[:output])
			autoinjection = ""
			if params[:autoinjection] == "true"
				autoinjection = "-j1"
			end
			if params[:monitor] == "true"
				monitor = "-M"
			end
      process = Bj.submit "script/stress -O #{params[:type]} -a script/temp2 -d #{params[:address]} -p #{params[:port]} -o results/#{params[:output]}/#{params[:output]} #{autoinjection} #{monitor}", :tag => "#{session[:username]},#{session[:editor_filename]},#{params[:output]}"
      session[:process_id] = Bj.table.job.find(process[0].id)
      session[:output] = params[:output]
			#f = IO.popen("script/stress -O #{params[:type]} -a script/temp2 -d #{params[:address]} -p #{params[:port]} -o results/#{params[:output]}/#{params[:output]} #{autoinjection}")			
			#puts "script/stress -a script/temp2 -d #{params[:address]} -p #{params[:port]} -o results/#{params[:output]}/"
			#stdin, stdout, stderr, exec = Open3.popen3('script/stress -a script/temp2 -d 127.0.0.1 -p 110 -o results/risultato.xml')
			#f = IO.popen('script/test.sh')
			#Process.detach(f.pid)
			session[:messages] = {:type => "ok", :msg => "Simulation lauched!"}
		rescue Exceptions::MissingParameters
			session[:messages] = {:type => "err", :msg => "Address, port and output needed!"}
		rescue Exceptions::FileExists
			session[:messages] = {:type => "err", :msg => "Output directory already exists!"}
		rescue Exceptions::InvalidIPProvided
			session[:messages] = {:type => "err", :msg => "Invalid IP provided!"}
		rescue Exceptions::InvalidPortProvided
			session[:messages] = {:type => "err", :msg => "Invalid port provided!"}
		rescue
			session[:messages] = {:type => "err", :msg => "Generic error, please contact administrator"}
		end
		render :text => "ok"
	end
	
	def delete_simulation
		begin
			simulation = Simulation.find(params[:id])
			output = simulation.output
			job1 = Bj.table.job.find(:all, :conditions => ["tag like ?", "%,#{output}%"])
			puts job1.class
			puts job1.length
			puts job1.inspect
			job2 = Bj.table.job_archive.find(:all, :conditions => ["tag like ?", "%,#{output}%"])
			if job1.length != 0
				job1[0].delete
			end
			if job2.length != 0
				job2[0].delete
			end
			Simulation.delete(params[:id])
			FileUtils.rm_rf 'results/'+params[:output]
			session[:messages] = {:type => "ok", :msg => "Simulation deleted!"}
		end
		redirect_to :action => :update_simulations_list
	end
	
	def stop_simulation
		begin
			exec("kill #{params[:pid]}")
			session[:messages] = {:type => "ok", :msg => "Simulation stopped!"}
		end
		redirect_to :action => :update_simulations_list
	end
	
	def results_list
		@files = Dir.glob("results/#{params[:output]}/*")
		render :partial => "results_list"
	end
	
	def show_file_content
		file = File.new(params[:file], "r")
		@file_name = params[:file]
		@file_content = file.read
		render :partial => "file_content"
	end
	
	def set_pid
		process = Bj.table.job.find(session[:process_id].id)
		simulation = Simulation.new_simulation(process.pid, session[:username], session[:editor_filename], session[:output])
		render :text => ""
	end
	
#	def indent_output
#		file = File.new(params[:file], "r").read
#		content = file.split("\n")
#		@file_content = indent(content)
#		@file_name = params[:file]
#		render :partial => "file_content"
#	end
	
	private
	
		
	#IT SHOULD VALIDATE ADDRESS INSERTED IN SIMULATION MASK, BUT IT MUST BE IMPROVED
	def validate_url(url)
	  url = URI.parse(url)
  	Net::HTTP.start(url.host, url.port) do |http|
	    return http.head(url.request_uri).code
	  end
	end
	
	def check_running_simulations
		simulations = Simulation.find(:all)
			simulations.each do |s|
				if s.running
					running = File.exist? "/proc/#{s.pid}"
					s.update_attributes(:running => running)
				end
			end
		time = Time.now
		@updated_at = time.strftime("%H:%M:%S")
		return Simulation.find_all_by_username(session[:username])
	end
	
#	def indent(content)
#		@offset = ""
#		@file_content = ""
#		@first_line = true
#		content.each do |line|
#			if @first_line
#				@file_content += line.strip+"\n"
#				@first_line = false
#			elsif line.strip.match(/^[<]{1}[t]{1}.*/) and line.strip.match(/[^\/>]{2}$/)
#				@file_content += @offset+line.strip+"\n"
#				@offset += "\ \ "
#			elsif line.strip.match(/^[<]{1}[s]{1}.*/)
#				@file_content += @offset+line.strip+"\n"
#				@offset += "\ \ "
#			elsif line.strip.match(/^[<]{1}[\/]{1}.*/)
#				@offset = @offset.chomp "\ \ "
#				@file_content += @offset+line.strip+"\n"
#			else
#				@file_content += @offset+line.strip+"\n"
#			end
#		end
#		return @file_content
#	end

end
