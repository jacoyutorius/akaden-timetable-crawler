$LOAD_PATH.unshift(File.dirname(__FILE__) + "/libs")

require 'akaden/clawler/timetable'
require 'akaden/clawler/fare'
require 'akaden/clawler/station'
require 'aws-sdk-dynamodb'

module Akaden
	class App
		require 'logger'

		attr_accessor :station, :client, :logger

		def initialize(station:)
			@station = station
      @client = Aws::DynamoDB::Client.new(client_params)
			@logger = Logger.new(STDOUT)
		end

		def generate
			insert_station_info
			insert_timetable
			insert_fare
		end

		private

    def client_params
      client_params = { region: 'ap-northeast-1' }
      client_params[:endpoint] = 'http://localhost:8002' unless ENV.key?('COPILOT_ENVIRONMENT_NAME')
      client_params
    end

		# clawl stations
		# {:address=>"浜松市浜北区於呂3061-2",
		#  :business_hours=>"終日無人駅",
		#  :phone=>nil,
		#  :taxi=>nil,
		#  :toilet=>true,
		#  :toilet_multipurpose=>false,
		#  :staff=>false,
		#  :wheelchair=>false,
		#  :elevator=>false,
		#  :pass=>false,
		#  :bycicle_parking=>true,
		#  :monthly_parking=>false,
		#  :daily_parking=>false,
		#  :coin_locker=>false,
		#  :public_telephone=>true,
		#  :aed=>false}
		def insert_station_info
			data = ::Akaden::Clawler::Station.run(station: station)

			begin
				client.execute_statement({
				  statement: "insert into Timetable value { 
				  	'id': '#{station}-#{version}',
				  	'sk': 'info',
				  	'address': '#{data[:address]}',
				  	'business_hours': '#{data[:business_hours]}',
				  	'phone': '#{data[:phone]}',
				  	'taxi': '#{data[:taxi]}',
				  	'toilet': #{data[:toilet]},
				  	'toilet_multipurpose': #{data[:toilet]},
				  	'staff': #{data[:staff]},
				  	'wheelchair': #{data[:wheelchair]},
				  	'elevator': #{data[:elevator]},
				  	'pass': #{data[:pass]},
				  	'bycicle_parking': #{data[:bycicle_parking]},
				  	'monthly_parking': #{data[:monthly_parking]},
				  	'daily_parking': #{data[:daily_parking]},
				  	'coin_locker': #{data[:coin_locker]},
				  	'public_telephone': #{data[:public_telephone]},
				  	'aed': #{data[:aed]},
				  	'version': #{version}
				  }"
				})
			rescue => e
				logger.error({
					row: data,
					error: e
				})
			ensure
				logger.info({
					row: data
				})
			end
		end

		# clawl timetable
		#  {:station=>"misonochuokoen",
	  # 	:detection=>:downto,
	  # 	:type=>:weekend,
	  # 	:time=>"23:24",
	  # 	:formation=>2},
		def insert_timetable
			timetables = ::Akaden::Clawler::Timetable.run(station: station)
			
			timetables.each do |row|
				begin
					client.execute_statement({
					  statement: "insert into Timetable value { 
					  	'id': '#{station}-#{row[:detection]}-#{row[:type]}-#{version}',
					  	'sk': '#{row[:time]}',
					  	'detection': '#{row[:detection]}',
					  	'type': '#{row[:type]}',
					  	'formation': #{row[:formation]},
					  	'version': #{version}
					  }"
					})
				rescue => e
					logger.error({
						data: row,
						error: e
					})
				ensure
					logger.info({
						data: row
					})
				end
			end
		end

		# [{:to=>"shinhamamatsu",
	  # :fare_adult=>"350円",
  	# :fare_child=>"180円",
  	# :required=>"24分（25分）"},
		def insert_fare
			fares = ::Akaden::Clawler::Fare.run(station: station)
		
			fares.each do |row|
				begin
					client.execute_statement({
					  statement: "insert into Timetable value { 
					  	'id': '#{station}-#{version}',
					  	'sk': '#{row[:to]}',
					  	'fare_adult': '#{row[:fare_adult]}',
					  	'fare_child': '#{row[:fare_child]}',
					  	'required': '#{row[:required]}',
					  	'version': #{version}
					  }"
					})
				rescue => e
					logger.error({
						row: row,
						error: e
					})
				ensure
					logger.info({
						data: row
					})
				end
			end
		end

		# @return Integer
		def version
			Time.now.localtime.year
		end
	end
end

[
	'shinhamamatsu',
	'daiichi-dori',
	'enshubyoin',
	'hachiman',
	'sukenobu',
	'hikuma',
	'kamijima',
	'jidosyagakkomae',
	'saginomiya',
	'sekishi',
	'nishigasaki',
	'komatsu',
	'hamakita',
	'misonochuokoen',
	'kobayashi',
	'shibamoto',
	'gansuiji',
	'nishikajima'
].each do |station|
	::Akaden::App.new(station: station).generate
end