module TweetJSONReader
    using JSON 
    using CSV

    function read_file(input_file)
        raw_json = ""

        reader = open(input_file, "r")
        for line in readlines(reader)
            raw_json = line
        end
        close(reader)
        return raw_json
    end

    function replace_delimiters(tweet_dict)
        for (id, text) in tweet_dict
            processed_text = replace(text, "|" => "/")
            removed_new_lines = replace(processed_text, "\n" => " ")
            tweet_dict[id] = removed_new_lines
        end

        return tweet_dict
    end

    function json_to_dict(json)
        j = JSON.parse(json)
        id_to_text_dict = Dict{String, String}()
        for tweet_dict in j["data"]
            id_to_text_dict[tweet_dict["id"]] = tweet_dict["text"]
        end 
        println(id_to_text_dict)
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

    function write_unlabeled_tweets(input_json_path, output_csv_path)
        json = read_file(input_json_path)
        tweet_dict = json_to_dict(json)
        tweet_dict = replace_delimiters(tweet_dict)
        write_csv(output_csv_path, tweet_dict)
    end
end