require 'open-uri'
require 'nokogiri'
require 'json'
require 'byebug'

module Akaden
	module Clawler
		class Station
			class << self
				def run(station:)
					self.new(station).clawl
				end
			end

			def initialize(station=nil)
				@station = station
				@url = "https://www.entetsu.co.jp/tetsudou/station/#{station}.html"
			end

			def clawl
				{
					**station_info,
					**basic_info
				}
			end

			def station_info
				body = page.css('#stInfo > div.information > table > tr > td')

				{
					address: body[0]&.text,
					business_hours: body[1]&.text,
					phone: body[2]&.text,
					taxi: body[3]&.text
				}
			end

			def basic_info
				body = page.css('#stBasic > div.facilities > table > tr > td')

				{
					toilet: text_parser(body[0]&.text),
					toilet_multipurpose: text_parser(body[1]&.text),
					staff: text_parser(body[2]&.text),
					wheelchair: text_parser(body[3]&.text),
					elevator: text_parser(body[4]&.text),
					pass: text_parser(body[5]&.text),
					bycicle_parking: text_parser(body[6]&.text),
					monthly_parking: text_parser(body[7]&.text),
					daily_parking: text_parser(body[8]&.text),
					coin_locker: text_parser(body[9]&.text),
					public_telephone: text_parser(body[10]&.text),
					aed: text_parser(body[11]&.text),
				}
			end

			def text_parser(text)
				text == '○' || text == '有'
			end

			def page
				@page ||= Nokogiri.HTML(URI.open(@url))
			end
		end
	end
end