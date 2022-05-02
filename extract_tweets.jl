module TweetExtractor 
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

  function make_GET_req(api_keys, url::String, params::Dict)::HTTP.Response
      response = HTTP.request("GET", url, [
          "Authorization"=>"Bearer "* api_keys["token"],
          "User-Agent"=>"Twitter-API-sample-code"
        ], query=params)
    
      response.status == 200 || exit("Error: " + response.status)
    
      return response
  end

  function extract_tweets(write_result_path)
    api_keys = get_Keys()

    # - - - - - - - - - - - - - - - - - - - - - - - - - -
    # these lines create query parameters in the form of a dictionary and a url link to the twitter API
    # recent_tweet_counts
    # https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py
    query_params = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text")

    search_url = "https://api.twitter.com/2/tweets/search/recent"

    ####### if we get academic access use the below instead
    query_params_academic = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text")

    search_url_academic = "https://api.twitter.com/2/tweets/search/all"

    # - - - - - - - - - - - - - - - - - - - - - - - - - -
    ####### need to make params dictionary ######
    url = search_url
    params = query_params

    r1 = make_GET_req(api_keys, search_url, query_params)

    r1_obj = String(r1.body)
    r1_Dict = JSON.parse(r1_obj)
    # r1_json = JSON.print(r1_obj)


    r1_Dict_meta = r1_Dict["meta"]
    r1_meta_keys = ["oldest_id" "result_count" "newest_id" "next_token"]

    r1_Dict_data = r1_Dict["data"]
    r1_data_keys = ["id" "text"]

    writer = open(write_result_path, "w")
    JSON.print(writer, r1_Dict)
  end
end

function main()
  TweetExtractor.extract_tweets(ARGS[1])
end

main()
# program arguments: <result path>
