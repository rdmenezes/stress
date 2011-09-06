class Testcase < ActiveRecord::Base
	belongs_to :simulation
	has_many :frames, :order => :position
	has_many :monitorreports
end
