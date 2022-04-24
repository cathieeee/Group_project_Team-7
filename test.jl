
using HTTP
using JSON

####### get keys ######
# this function makes accessesing our twitter authorization information possible without directly including keys in code
function create_TA2C_from_file(filename::String = ".keys")::Dict
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

TA2c = create_TA2C_from_file()

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# these lines create query parameters in the form of a dictionary and a url link to the twitter API
# recent_tweet_counts
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py

query_params = Dict(
  "query"=>"ivermectin",
  "granularity"=>"day",
)
search_url = "https://api.twitter.com/2/tweets/search/counts/recent"

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# full-archive-search
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Full-Archive-Search/full-archive-search.py

_query_params = Dict(
 "query"=>"(from:twitterdev -is:retweet) OR #ivermectin",
 "tweet.fields"=>"author_id",
 "tweet.fields" =>"ivermectin",
 "tweet.fields" =>"hydroxychloroquine",
 "tweet.fields" =>"remdesivir"
)
_search_url = "https://api.twitter.com/2/tweets/search/30day/fullarchive"

# make_GET_req
# Blanket function for simple GET requests. Returns full request object.
#
# This can be copy-pasted...
# --------------------------------------------------
# url    :: "https://api.twitter.com/2/tweets/search/30day/fullarchive"
# params :: Dictionary of parameters to send/ body of request

####### need to make params dictionary ######
url = "https://api.twitter.com/2/tweets/search/30day/fullarchive"
params = _query_params

function make_GET_req(url::String, params::Dict)::HTTP.response
    response = HTTP.request("GET", url, [
        "Authorization"=>"Bearer "* TA2c["token"],
        "User-Agent"=>"Twitter-API-sample-code"
       ], query=params)
  
    response.status == 200 || exit("Error: " + response.status)
  
    return response
end

r1 = make_GET_req(search_url, query_params)
r2 = make_GET_req(_search_url, _query_params)

# need to make a dictionionary of tweet criteria

