$LOAD_PATH.unshift(File.dirname(__FILE__) + "/libs")

require 'akaden/clawler/timetable'
require 'akaden/clawler/fare'
require 'akaden/clawler/station'

stations = [
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
]

# clawl timetable
stations.each do |station|
	pp ::Akaden::Clawler::Timetable.run(station: station)
end


# clawl stations
# stations.each do |station|
# 	pp ::Akaden::Clawler::Station.run(station: station)
# end

# clawl fares
# stations.each do |station|
# 	pp ::Akaden::Clawler::Fare.run(station: station)
# end