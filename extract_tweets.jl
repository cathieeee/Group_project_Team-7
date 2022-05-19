module TweetExtractor 
  using HTTP
  using JSON
  using DataFrames
  using CSV

  """
    get_keys(filename=".final_keys)

  Return dictionary of Twitter API keys.
  """
  function get_keys(filename::String = ".final_keys")
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

  """
    make_get_req(api_keys::Dict, url:String, params::Dict)

  Return response of GET request given api keys, url, and params for the query.
  """
  function make_get_req(api_keys::Dict, url::String, params::Dict)
      response = HTTP.request("GET", url, [
          "Authorization"=>"Bearer "* api_keys["token"],
          "User-Agent"=>"Twitter-API-sample-code"
        ], query=params)
    
      response.status == 200 || exit("Error: " + response.status)
    
      return response
  end

  """
    extract_tweets(write_result_csv::String, next_token=nothing)

  Write tweets to write_result_csv; return result count & next token. 

  # Arguments
   - `write_result_csv::String`: filepath to write the CSV to. 
   - `next_token=nothing`: next token String to use in query, if using
  """
  function extract_tweets(write_result_csv::String, next_token=nothing)
    api_keys = get_keys()
    # these lines create query parameters in the form of a dictionary and a
    # url link to the twitter API
    # https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/main/Recent-Tweet-Counts/recent_tweet_counts.py

    query_academic_no_next = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text",
      "max_results" => "500",
      "start_time" => "2022-4-1T13:00:00.00Z",
      "end_time" => "2022-4-30T13:00:00.00Z")

    query_academic_next_token = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text",
      "max_results" => "500",
      "start_time" => "2022-4-1T13:00:00.00Z",
      "end_time" => "2022-4-30T13:00:00.00Z",
      "next_token" => next_token
      )

    search_url_academic = "https://api.twitter.com/2/tweets/search/all"
    url = search_url_academic
    params = nothing

    if isnothing(next_token)
      params = query_academic_no_next
    else
      url = search_url_academic
      params = query_academic_next_token
    end

    r1 = make_get_req(api_keys, url, params)

    r1_obj = String(r1.body)
    r1_Dict = JSON.parse(r1_obj)

    data_dict = r1_Dict["data"]
    new_next_token = r1_Dict["meta"]["next_token"]
    result_count = r1_Dict["meta"]["result_count"]

    write_unlabeled_tweets(data_dict, write_result_csv)
    return result_count, new_next_token
  end

  """
    replace_delimiters(tweet_dict::Dict)

  Replace "|" with "/" and remove newlines in a tweet_dict of ids to tweets.
  """
  function replace_delimiters(tweet_dict::Dict)
    for (id, text) in tweet_dict
        processed_text = replace(text, "|" => "/")
        removed_new_lines = replace(processed_text, "\n" => " ")
        tweet_dict[id] = removed_new_lines
    end

    return tweet_dict
  end

  """
    json_to_dict(data_dict::Dict)

  Return Json data dictionary as dictionary of id --> tweet text.
  """
  function json_to_dict(data_dict::Dict)
    id_to_text_dict = Dict{String, String}()
    for tweet_dict in data_dict
        id_to_text_dict[tweet_dict["id"]] = tweet_dict["text"]
    end 
    return id_to_text_dict
  end

  """
    write_csv(output_path::String, tweet_dict::Dict)

  Writes CSV to output_path given a tweet_dict of ids to tweets. 
  """
  function write_csv(output_path::String, tweet_dict::String)
    writer = open(output_path, "a")

    for (id, tweet) in tweet_dict
        line = "$id|$tweet"
        println(writer, line)
    end
    close(writer)
  end

"""
  write_unlabeled_tweets(data_dict::Dict, output_csv_path::String)

Write id|tweet_text to CSV at output_csv_path given a data_dict from json 
"""
function write_unlabeled_tweets(data_dict::Dict, output_csv_path::String)
    tweet_dict = json_to_dict(data_dict)
    tweet_dict = replace_delimiters(tweet_dict)
    write_csv(output_csv_path, tweet_dict)
  end
end