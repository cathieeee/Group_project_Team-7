using HTTP
using JSON

#twitter key yprDGNKkvvrQRi5xbPMAMx5Vr
#twitter secret CzYpWybW11MidEPy1LPLhsRqDXM529OHOl3U9HxbFXK4sYPxLJ
#twitter token AAAAAAAAAAAAAAAAAAAAANEdbAEAAAAAwCqU0FBz7vSooTAFlYtMchqmfig%3DMpXnTpJSWYgDpoVdNj3OG4i4PGrYjCkmOoitEmrxC4rtqVb9Ay


# See
#  - https://github.com/twitterdev/Twitter-API-v2-sample-code
#  - https://developer.twitter.com/en/docs/twitter-api
#  - https://juliaweb.github.io/HTTP.jl/stable/public_interface/#Requests

#=
 While we've previously stored our API keys by just placing them into a variable
 in the code, this is extremely insecure and therefore never done in practice, 
 especially not in production. Your options are essentially
  
  a. Store them in a file
  b. Store them in your local environment
 (b) is absolutely the "best" option, though I'm in the habit of (a). If you're
 unfamiliar with (b), briefly, know that you have something structurally similar 
 to a Julia Dict() managed by your Linux system; these are globally accessible,
 and if you type `env` in your terminal, you can see what environment variables 
 are currently set. To set some of your own, try
   
   export <NAME>="<VALUE>"
 where the </> are meant to mark placeholders, and do note the quotes around <VALUE>.
 There are a few other ways to do this, but those are "implementation-specific"/ depend 
 on exactly what you're running (e.g. in your .bashrc or .zshrc files). Julia, at runtime, 
 reads the environment variables into a Dict() of its own called ENV, so acccessing them 
 is very straightforward.
   ENV["<NAME>"]
 retrieves the value of <NAME> from your environment.
=#


# create_TA2C_from_file
# Reads provided file and returns a Dictionary with keys.
#
# For this to work plug-and-play, you need to have a file called ".keys"
# in your "current directory" --- barring technicalities, keep it in the 
# same directory (and run your code from this directory).
#
#   > touch .keys
#   > echo "key=yprDGNKkvvrQRi5xbPMAMx5Vr" > .keys
#   > echo "secret=<CzYpWybW11MidEPy1LPLhsRqDXM529OHOl3U9HxbFXK4sYPxLJ>" >> .keys
#   > echo "token=<AAAAAAAAAAAAAAAAAAAAANEdbAEAAAAAwCqU0FBz7vSooTAFlYtMchqmfig%3DMpXnTpJSWYgDpoVdNj3OG4i4PGrYjCkmOoitEmrxC4rtqVb9Ay>" >> .keys
#
# --------------------------------------------------
# filename :: name of file to read from
#             defaults to .keys in current directory

function create_TA2C_from_file(filename::String = ".keys")::Dict
  keys = Dict()

  isfile(filename) || exit("File not found: " + filename)

  open(filename) do f
    for line in eachline(f)
      line = line.strip()

      line.occursin("=") || continue

      key, value = line.split("=")
      keys[key] = value.strip()
    end
  end

  return keys
end

# create_TA2C_from_env
# Reads environment for API keys, returns a Dictionary
# --------------------------------------------------
# api_key      :: variable name for API key
#                 defaults: TWITTER_KEY
# api_secret   :: variable name for API secret
#                 defaults: TWITTER_SECRET
# bearer_token :: variable name for bearer token
#                 defaults: TWITTER_BEARER_TOKEN

function create_TA2c_from_env(api_key::String = "TWITTER_KEY", 
    api_secret::String = "TWITTER_SECRET", bearer_token::String = "TWITTER_BEARER_TOKEN")::Dict
  keys = Dict()

  keys["key"] = ENV[api_key]
  keys["secret"] = ENV[api_secret]
  keys["token"] = ENV[bearer_token]

  return keys
end
  
# --------------------------------------------------

TA2c = create_TA2c_from_env()

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# recent_tweet_counts
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py

query_params = Dict(
  "query"=>"from:paraga",
  "granularity"=>"day",
)
search_url = "https://api.twitter.com/2/tweets/search/counts/recent"

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# full-archive-search
# https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Full-Archive-Search/full-archive-search.py

_query_params = Dict(
 "query"=>"(from:twitterdev -is:retweet) OR #twitterdev",
 "tweet.fields"=>"author_id"
)
_search_url = "https://api.twitter.com/2/tweets/search/30day/fullarchive"

# - - - - - - - - - - - - - - - - - - - - - - - - - -

# make_GET_req
# Blanket function for simple GET requests. Returns full request object.
#
# This can be copy-pasted...
# --------------------------------------------------
# url    :: URL to make request to
# params :: Dictionary of parameters to send/ body of request

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

# Now, do whatever you need to do with these...

println(r1.status)
println(r2.status)

println(String(r1.body))
println(String(r2.body))