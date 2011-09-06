class Simulation < ActiveRecord::Base

	has_many :testcases

	def self.new_simulation(pid, username, filename, output)
		simulation = Simulation.new(:pid => pid, :username => username, :filename => filename, :output => output, :created_at => Time.now, :running => true)
		simulation.save!
	end
		
		
end
