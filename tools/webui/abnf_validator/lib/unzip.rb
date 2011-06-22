require 'rubygems'
require 'zip/zipfilesystem'
require 'rexml/document'

class UnZipThemAll
	attr_accessor :zip_file_path, :to_folder_path, :plugin_name, :migration

	def initialize(zip_file_path, to_folder_path)
		raise Exceptions::MissingParameters if zip_file_path.blank?
		raise Exceptions::NotZipFile if zip_file_path.original_filename[-4,4] != ".zip"
		@zip_file_path = zip_file_path.path
		@to_folder_path = to_folder_path
		@plugin_name = zip_file_path.original_filename[0, zip_file_path.original_filename.length-4]
	end

	def unzip
		raise Exceptions::FileNotFound unless File.exists?(self.zip_file_path)
		zip_file = Zip::ZipFile.open(self.zip_file_path)
		
		#CHECK IF PLUGIN ARCHIVE CONTAINS RIGHT FILES
		Zip::ZipFile.foreach(self.zip_file_path) do |entry|
			file_path = File.join(self.to_folder_path, entry.to_s)
			if entry.is_directory and !File.exists?(file_path)
				good = false
				good = true if entry.to_s == "app/views/#{@plugin_name}/" or entry.to_s.include?("lib/")
				raise Exceptions::MalformedPlugin if good == "false"
			elsif !entry.is_directory and (!entry.to_s.include?("views") or !entry.to_s.include?("lib/"))
				good = false
				good = true if entry == "app/controllers/#{@plugin_name}_controller.rb" or entry == "app/models/#{@plugin_name}.rb" or entry == "app/#{@plugin_name}.xml" or entry.to_s.include? "db/migrate"
				raise Exceptions::MalformedPlugin if good == "false"
			end
		end
		
		#CREATE NEEDED DIRECTORY
		Zip::ZipFile.foreach(self.zip_file_path) do |entry|
			file_path = File.join(self.to_folder_path, entry.to_s)
			if entry.is_directory and !File.exists?(file_path)
				FileUtils.mkdir(file_path)
			end
		end
		
		#FINALLY EXCTRACT FILE
		migration = false
		Zip::ZipFile.foreach(self.zip_file_path) do |entry|
			if !entry.is_directory
				file_path = File.join(self.to_folder_path, entry.to_s)
				if File.exists?(file_path)
					FileUtils.rm(file_path)
				end
				zip_file.extract(entry, file_path)
			end
			if entry.to_s.include?	"#{@plugin_name}.xml"
				xmlfile = File.new(entry.to_s)
				doc = REXML::Document.new(xmlfile)
				doc.root.each_element do |field|
					if field.name == "migration_file"
						migration = true
					end
				end
			end
		end
		main_view = "app/views/layouts/#{@plugin_name}.html.erb"
		FileUtils.copy('app/views/layouts/users.html.erb', main_view)
		return migration
	end
end

