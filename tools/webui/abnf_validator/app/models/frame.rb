class Frame < ActiveRecord::Base
	belongs_to :testcase
	#acts_as_list :scope => :testcase
	
	def printHTML
		out = self.position.to_s+": "
		out+= self.type
		
		return out
	end
end

class ReadFrame < Frame

end

class SentFrame < Frame

end

class NoResponse < ReadFrame

end
