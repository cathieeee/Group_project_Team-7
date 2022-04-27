using JSON 
using CSV

function read_file(input_file)
    raw_json = ""

    reader = open(input_file, "r")
    for line in readlines(reader)
        if startswith(line, "{\"data\"")
            raw_json = strip(line)
        end
    end
    close(reader)
    return raw_json
end

function replace_delimiters(tweet_dict)
    for (id, text) in tweet_dict
        processed_tweet_text = strip(replace(text, "|" => "/"))
        tweet_dict[id] = processed_tweet_text
    end

    return tweet_dict
end

function json_to_dict(json)
    j = JSON.parse(json)
    id_to_text_dict = Dict{String, String}()
    for tweet_dict in j["data"]
        id_to_text_dict[tweet_dict["id"]] = tweet_dict["text"]
    end 
    return id_to_text_dict
end

function write_csv(output_path, tweet_dict)
    #write header 
    writer = open(output_path, "w")
    println(writer, "id|tweet_text")

    for (id, tweet) in tweet_dict
        line = "$id|$tweet"
        println(writer, line)
    end
    
    close(writer)
end

function main()
    input_file = "data/api_result.json"
    json = read_file(input_file)
    tweet_dict = json_to_dict(json)
    tweet_dict = replace_delimiters(tweet_dict)
    write_csv("data/unlabeled_tweets.csv", tweet_dict)
end

main()