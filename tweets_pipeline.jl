# program arguments <result csv path> <target_amount> <next_token> (optional)
include("extract_tweets.jl")
import .TweetExtractor as tweet_extractor
using JSON

function get_all_tweets(write_result_path, target_amount, next_token=nothing)
    new_next_token = next_token
    tweets_collected = 0

    println("0 tweets collected so far")
    while target_amount > tweets_collected
        try
            # println(new_next_token)
            if isnothing(new_next_token)
                new_next_token = TweetExtractor.extract_tweets(write_result_path)
            else
                new_next_token = TweetExtractor.extract_tweets(write_result_path, 
                                                               new_next_token)
                println(new_next_token)                                       
            end
            tweets_collected += 10
            println("$tweets_collected tweets collected so far")
            wait(Timer(3))
        catch
            writer = open("data/next_token.txt", "w")
            JSON.print(writer, new_next_token)
            close(writer)           
        end
    end
    writer = open("data/next_token.txt", "w")
    JSON.print(writer, new_next_token)
    close(writer)
    println("extraction complete")
end

function main()
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