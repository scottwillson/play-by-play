require 'date'
require "json"
require 'net/http'

# (Date.new(2014, 10, 28)..Date.new(2015, 04, 17)).each do |date|
#   day = date.strftime("%d")
#   month = date.strftime("%m")
#   year = date.strftime("%Y")
#
#   uri = URI("http://stats.nba.com/stats/scoreboardV2?DayOffset=0&LeagueID=00&gameDate=#{month}%2F#{day}%2F#{year}")
#   json = Net::HTTP.get(uri)
#
#   puts "#{date.strftime('%D')} #{json.size}"
#
#   File.write("data/#{year}-#{month}-#{day}.json", json)
# end

Dir.glob("data/days/*.json") do |f|
  json = JSON.parse(File.read(f))
  game_header = json["resultSets"].first {|rs| rs["name"] == "GameHeader"}
  game_header["rowSet"].each do |game|
    game_id = game[2]
    uri = URI("http://stats.nba.com/stats/playbyplayv2?EndPeriod=10&EndRange=55800&GameID=#{game_id}&RangeType=2&Season=2014-15&SeasonType=Regular+Season&StartPeriod=1&StartRange=0")
    json = Net::HTTP.get(uri)
    puts "#{game_id} #{json.size}"
    File.write("data/games/#{game_id}.json", json)
  end
end
