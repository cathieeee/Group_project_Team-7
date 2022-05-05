# program arguments: <result csv path>

module TweetExtractor 
  using HTTP
  using JSON
  using DataFrames
  using CSV
  
  ####### get keys ######
  # this function makes accessesing our twitter authorization information possible without directly including keys in code
  function get_Keys(filename::String = ".final_keys")::Dict
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

  function extract_tweets(write_result_csv, next_token=nothing)
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
    query_academic_no_next = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text",
      "max_results" => "10",
      "start_time" => "2022-4-1T13:00:00.00Z",
      "end_time" => "2022-4-30T13:00:00.00Z")

    query_academic_next_token = Dict(
      "query"=>"((Ivermectin OR Remdesivir OR Hydroxychloroquine OR ivermectin OR remdesivir OR hydroxychloroquine OR #Ivermectin OR #Remdesivir OR #Hydroxychloroquine OR #ivermectin OR #remdesivir OR #hydroxychloroquine) -is:retweet lang:en)",
      "tweet.fields"=>"text",
      "max_results" => "10",
      "start_time" => "2022-4-1T13:00:00.00Z",
      "end_time" => "2022-4-30T13:00:00.00Z",
      "next_token" => next_token
      )

    search_url_academic = "https://api.twitter.com/2/tweets/search/all"

    # - - - - - - - - - - - - - - - - - - - - - - - - - -
    ####### need to make params dictionary ######
    url = search_url_academic
    params = nothing

    if isnothing(next_token)
      params = query_academic_no_next
    else
      url = search_url_academic
      params = query_academic_next_token
    end

    r1 = make_GET_req(api_keys, url, params)

    r1_obj = String(r1.body)
    r1_Dict = JSON.parse(r1_obj)

    data_dict = r1_Dict["data"]
    new_next_token = r1_Dict["meta"]["next_token"]

    write_unlabeled_tweets(data_dict, write_result_csv)

    # write JSON for debugging
    # writer = open("data/result.json", "w")
    # JSON.print(writer, r1_Dict)

    # r1_json = JSON.print(r1_obj)

    # r1_Dict_meta = r1_Dict["meta"]
    # r1_meta_keys = ["oldest_id" "result_count" "newest_id" "next_token"]

    # r1_Dict_data = r1_Dict["data"]
    # r1_data_keys = ["id" "text"]

    return new_next_token
  end

function replace_delimiters(tweet_dict)
  for (id, text) in tweet_dict
      processed_text = replace(text, "|" => "/")
      removed_new_lines = replace(processed_text, "\n" => " ")
      tweet_dict[id] = removed_new_lines
  end

  return tweet_dict
end

function json_to_dict(data_dict)
  id_to_text_dict = Dict{String, String}()
  for tweet_dict in data_dict
      id_to_text_dict[tweet_dict["id"]] = tweet_dict["text"]
  end 
  return id_to_text_dict
end

function write_csv(output_path, tweet_dict)
  #write header 
  writer = open(output_path, "a")

  for (id, tweet) in tweet_dict
      line = "$id|$tweet"
      println(writer, line)
  end
  close(writer)
end

function write_unlabeled_tweets(data_dict, output_csv_path)
    tweet_dict = json_to_dict(data_dict)
    tweet_dict = replace_delimiters(tweet_dict)
    write_csv(output_csv_path, tweet_dict)
  end
end

function main()
  next_token = TweetExtractor.extract_tweets(ARGS[1])
  println(next_token)
end

main()