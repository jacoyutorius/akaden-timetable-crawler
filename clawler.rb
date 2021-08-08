require 'open-uri'
require 'nokogiri'
require 'ostruct'
require 'json'
require 'byebug'

class Timetable
	attr_accessor :station, :detection, :type, :time, :formation

	def initialize(station:, detection:, type:, time:, formation:)
		@station = station
		@detection = detection
		@type = type
		@time = time
		@formation = formation
	end

	def to_hash
		{
			station: station,
			detection: detection,
			type: type,
			time: time,
			formation: formation
		}
	end
end

class Clawler
	class << self
		def run(station:)
			self.new(station).clawl
		end
	end

	def initialize(station=nil)
		@station = station
		@url = "https://www.entetsu.co.jp/tetsudou/timetable/#{station}.html"
	end

	def clawl
		[
			clawling(type: :weekday, detection: :upto),
			clawling(type: :weekday, detection: :downto),
			clawling(type: :weekend, detection: :upto),
			clawling(type: :weekend, detection: :downto)
		].flatten.compact.map(&:to_hash)
	end

	private

	# @param type[String] :weekday(平日) or :weekend(土日祝)
	# @param detection[String] :upto(上り、新浜松行き) or :downto(下り、西鹿島行き)
	def clawling(type:, detection:)
		type_xpath = case type
			when :weekday then 'table[1]'
			when :weekend then 'table[2]'
		end

		path = "//*[@id='tTable']/#{type_xpath}/tbody/tr"

		page.xpath(path).map do |row|
			hour = row.xpath("td[2]").text

			detection_xpath = case detection
			when :upto then 'td[1]/span'
			when :downto then 'td[3]/span'
			end

			
			row.xpath(detection_xpath).map do |col|
				return nil if col.text == ""

				time = "#{hour}:#{col.text}"

				formation = case col.attributes['class']&.value
					when 'week', 'weekend' then 4
					else 2
				end

				Timetable.new(
					station: @station,
					detection: detection,
					type: type,
					time: time,
					formation: formation
				)
			end
		end.flatten
	end

	def page
		@page ||= Nokogiri.HTML(URI.open(@url))
	end
end


# pp Clawler.run(station: "daiichi-dori")
pp Clawler.run(station: "shinhamamatsu")
