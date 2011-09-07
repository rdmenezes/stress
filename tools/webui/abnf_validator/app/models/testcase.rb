class Testcase < ActiveRecord::Base
	belongs_to :simulation
	has_many :frames, :order => :position
	has_many :monitorreports
	
	def printHTML
		out = "ID: "+self.id_anomaly.to_s
		out += " RUN: "+self.run.to_s
		return out
	end
end
