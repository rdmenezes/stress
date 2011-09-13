class Frame < ActiveRecord::Base
	belongs_to :testcase
	#acts_as_list :scope => :testcase
	has_many :faults, :dependent => :destroy
	
	def printHTML
		out = self.position.to_s+": "
		out+= "<b>"+self.type+"</b>:<br>"
		
		return out
	end
end

class ReadFrame < Frame

end

class SentFrame < Frame

end

class NoResponse < ReadFrame

end
