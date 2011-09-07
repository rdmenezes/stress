class OutputAnalyzerController < ApplicationController
	require 'lib/output_analyzer.rb'
	
	#GET NEEDED INFORMATION FOR PLUGIN SYSTEM AND LIBRARIES
	def index
		@simulations = Simulation.find_all_by_username(session[:username])
		@plugins = Array.new
		xml_file_list = Dir.glob("app/*.xml")
		xml_file_list.each do |f|
			@plugins << Plugin.new(f)
		end
		@libraries = Library.find(:all)
		respond_to {|format| format.html}
	end
	
	def select_simulation
		@files = Dir.glob("results/#{params[:output]}/*")
		@files.sort!{|x,y| x.split("/").last <=> y.split("/").last }
		@simulation_selected=params[:output]
		sims = Simulation.find_all_by_output(@simulation_selected)
		simulation = sims.first
		if simulation != nil and simulation.testcases.size == 0
			xmlparser = XMLOutputParser.new
			@files.each do |file|
				#simulation.testcases << Testcase.new(:filename => file)
				xmlparser.parse(simulation, file)
			end
			simulation.save
		end
		render :partial => "output_body"
		#render :update do |page|
         # page.replace_html "right_column", :partial => 'output_body'
        # end
	end
	
	def get_l_distance
		@simulation_selected=params[:output]
		render :text => '<div style="clear:both;"></div> Calcolo della distanza di Levenshtein '+@simulation_selected.to_s
	end
	
	def get_testcase_list
		@simulation_selected=params[:output]
		sims = Simulation.find_all_by_output(@simulation_selected)
		@simulation = sims.first
		render :partial => "testcase_list"
	end
	
	def get_frames_list
		@testcase = Testcase.find(params[:testcase_id])
		render :partial => "frames_list" unless @testcase == nil
	end
	
	def get_frame_content
		@frame = Frame.find(params[:frame_id])
		render :partial => "frame_content" unless @frame == nil
	end
	
	def show_loading
		render :partial => "loading"
	end
	
	#SAVES AN ABNF FILE FROM FORM INFORMATION
#	def save_abnf_file
#		begin
#			file = AbnfFile.create_new_file(file_name, params[:library_id], session[:user_id])
#			abnf_content = "First arg: #{params[:first_arg]}, second_arg: #{params[:second_arg]}"
#			file.update_attributes(:content => abnf_content)
#			session[:messages] = {:type => "ok", :msg => "File Saved!"}
#		rescue Exceptions::MissingParameters
#			session[:messages] = {:type => "err", :msg => "Missing file name!"}
#		rescue Exceptions::InvalidLibraryId
#			session[:messages] = {:type => "err", :msg => "Invalid Library id!"}			
#		rescue
#			session[:messages] = {:type => "err", :msg => "Generic error, please contact administrator"}
#		end
#		render :text => "true"
#	end
	
end
