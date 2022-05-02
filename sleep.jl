include("extract_tweets.jl")
import .TweetExtractor as tweet_extractor

using JSON

function sleep(sec, write_result_path)
    sec ≥ 0 || throw(ArgumentError("cannot sleep for $sec seconds"))
    wait(Timer(sec))
    TweetExtractor.extract_tweets(write_result_path)
end

sleep(10, write_result_path)