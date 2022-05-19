include("extract_tweets.jl")
import .TweetExtractor as tweet_extractor
using JSON

"""
    get_all_tweets(write_result_path::String, 
                   target_amount::Int, 
                   next_token=nothing)

Writes target_amount of tweets to CSV file, using next_token if applicable 
"""
function get_all_tweets(write_result_path::String, 
                        target_amount::Int, 
                        next_token=nothing)
    new_next_token = next_token
    tweets_collected = 0

    println("0 tweets collected so far")
    while target_amount > tweets_collected
        try
            result_count = 0
            if isnothing(new_next_token)
                result_count, new_next_token = TweetExtractor.extract_tweets(write_result_path)
            else
                result_count, new_next_token = TweetExtractor.extract_tweets(write_result_path, 
                                                                new_next_token)                                
            end
            tweets_collected += result_count
            println(new_next_token)       
            println("$tweets_collected tweets collected so far")
            wait(Timer(4))
        catch e
            println("error caught!:$e")
            println(new_next_token)
            writer = open("data/next_token.txt", "w")
            println(writer, new_next_token)
            close(writer) 
            break
        end
    end
    writer = open("data/next_token.txt", "w")
    println(writer, new_next_token)
    close(writer)
    println("extraction complete")
end

""" Main function to takein program arguments """
function main()
    # program arguments <result csv path> <target_amount> <next_token> (optional)
    target_amount = parse(Int32, ARGS[2])
    num_args = length(ARGS) 

    if num_args == 2
        get_all_tweets(ARGS[1], target_amount)
    elseif num_args == 3
        get_all_tweets(ARGS[1], target_amount, ARGS[3])
    else
        println("incorrect number of arguments")
    end
end

main()