# frozen_string_literal: true

require 'json'
require 'date'
require 'net/http'

URL = 'https://www.instagram.com/explore/tags/accessyeg/?__a=1'
BEGIN_OF_CONTEST = '2019-09-30 00:00:00 -0600' # 'Monday, September 30, 2019 at 12:00 am'
END_OF_CONTEST = '2019-10-02 14:00:00 -0600' # 'Wednesday, October 2, 2019 at 2:00 pm'
ACCESSLIBCON_USER = '7953974014'
NUMBER_OF_WINNERS = 2

def contest_duration(published)
  start = DateTime.parse(BEGIN_OF_CONTEST)
  finish = DateTime.parse(END_OF_CONTEST)
  published = published.to_datetime
  return false if published < start
  return false if published > finish

  true
end

def not_us(owner)
  !owner.include? ACCESSLIBCON_USER
end

# get json from instagram.com with hashtag accessyeg
uri = URI(URL)
response = Net::HTTP.get(uri)
data_hash = JSON.parse(response)

# get entries from the graphql json response collecting shortcode, owner and time published
entries = data_hash['graphql']['hashtag']['edge_hashtag_to_media']['edges'].collect do |image|
  {
    shortcode: "http://instagram.com/p/#{image['node']['shortcode']}",
    owner: "https://i.instagram.com/api/v1/users/#{image['node']['owner']['id']}/info",
    timestamp: Time.at(image['node']['taken_at_timestamp'])
  }
end

# find eligible entries
eligible = entries.collect { |entry| entry if contest_duration(entry[:timestamp]) && not_us(entry[:owner]) }.compact

# randomly draws eligible entries for the contest
puts eligible.sample(NUMBER_OF_WINNERS)
