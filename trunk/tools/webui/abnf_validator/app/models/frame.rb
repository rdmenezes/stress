class Frame < ActiveRecord::Base
	belongs_to :testcase
	acts_as_list :scope => :testcase
end
class ReadFrame < Frame
end
class SentFrame < Frame
end
