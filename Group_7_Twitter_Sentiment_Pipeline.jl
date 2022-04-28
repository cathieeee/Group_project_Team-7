using HTTP
using JSON
using DataFrames
using CSV

####### get keys ######
# this function makes accessesing our twitter authorization information possible without directly including keys in code
function get_Keys(filename::String = ".keys")::Dict
    keys = Dict()
  
    isfile(filename) || exit("File not found: " + filename)
  
    open(filename) do f
      for line in eachline(f)
        line = strip(line)
  
        occursin("=", line) || continue
  
        key, value = split(line, "=")
        keys[key] = strip(value)
      end
    end
    return keys
end
api_keys = get_Keys()

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# these lines create query parameters in the form of a dictionary and a url link to the twitter API
# recent_tweet_counts
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py
query_params = Dict(
  "query"=>"(ivermectin OR remdesivir OR hydroxychloroquine lang:en)",
  "tweet.fields"=>"text"
)
search_url = "https://api.twitter.com/2/tweets/search/recent"

# - - - - - - - - - - - - - - - - - - - - - - - - - -
####### need to make params dictionary ######
url = search_url
params = query_params

function make_GET_req(url::String, params::Dict)::HTTP.Response
    response = HTTP.request("GET", url, [
        "Authorization"=>"Bearer "* api_keys["token"],
        "User-Agent"=>"Twitter-API-sample-code"
       ], query=params)
  
    response.status == 200 || exit("Error: " + response.status)
  
    return response
end
r1 = make_GET_req(search_url, query_params)

r1_obj = String(r1.body)
r1_Dict = JSON.parse(r1_obj)
r1_json = JSON.json(r1_obj)

r1_Dict_meta = r1_Dict["meta"]
r1_meta_keys = ["oldest_id" "result_count" "newest_id" "next_token"]

r1_Dict_data = r1_Dict["data"]
r1_data_keys = ["id" "text"]

open("api_result.json", "w") do file
  write(file,r1_json)
end

# delimeter = \"
# format
#   {\"data\":[{\"id\":\"string\",\"text\":\"string\"},{\"id\":\"string\",\"text\":\"string\"},{...}],
#    \"meta\":{\"newest_id\":\"string\",\"oldest_id\":\"string\",\"result_count\":number,\"next_token\":\"string\"}}



