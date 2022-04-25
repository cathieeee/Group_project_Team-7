using HTTP
using JSON
using DataFrames
using CSV

########################## get keys ################################
# - - - - - - - - - - - - - - - - - - - - - - - - - -
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

########### set search query parameters and search url ##############
# - - - - - - - - - - - - - - - - - - - - - - - - - -
# these lines create query parameters in the form of a dictionary and a url link to the twitter API
# recent_tweet_counts
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py

query_params = Dict(
  "query"=>"ivermectin OR remdesivir OR hydroxychloroquine lang:en",
  "tweet.fields"=>"text"
)
search_url = "https://api.twitter.com/2/tweets/search/recent"

####################### HTTP GET Request ############################
# - - - - - - - - - - - - - - - - - - - - - - - - - -
# make_GET_req
# Blanket function for simple GET requests. Returns full request object.

url = search_url
params = query_params

function make_GET_req(url::String, params::Dict)::HTTP.Response
    response = HTTP.request("GET", url, [
        "Authorization"=>"Bearer "* TA2c["token"],
        "User-Agent"=>"Twitter-API-sample-code"
       ], query=params)
  
    response.status == 200 || exit("Error: " + response.status)
  
    return response
end
#r1_obj = open("r1_obj_text.txt", "w")
r1 = make_GET_req(search_url, query_params)

println(r1)

###################################
# we get a list or an array (unsure exact which i think a list) of responses
# next we probably need to convert it to a DataFrame or whatever datastructure 
# our machine will be compatable with AND one that we will be able to manually
# assign sentiment. The delimeter between tweets/roots is "},{" and between tweet 
# fields/attributes is ","