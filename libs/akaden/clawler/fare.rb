require 'open-uri'
require 'nokogiri'
require 'json'
require 'byebug'

module Akaden
	module Clawler
		class Fare
			class << self
				def run(station:)
					self.new(station).clawl
				end
			end

			def initialize(station=nil)
				@station = station
				@url = "https://www.entetsu.co.jp/tetsudou/fare/#{station}.html"
			end

			def clawl
				fare
			end

			private


			def fare
				page.css('#fareBox > div.fareTbl > table > tbody > tr').map do |tr|
					doc = tr.css('td')


					{
						to: doc[0].children.attribute("class").value,
						fare_adult: doc[1].text,
						fare_child: doc[2].text,
						required: doc[3].text
					}
				end
			end

			def page
				@page ||= Nokogiri.HTML(URI.open(@url))
			end
		end
	end
end