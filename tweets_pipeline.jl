# program arguments <result csv path>
include("extract_tweets.jl")
import .TweetExtractor as tweet_extractor
using JSON

function sleep(sec, write_result_path)
    sec ≥ 0 || throw(ArgumentError("cannot sleep for $sec seconds"))
    wait(Timer(sec))
    TweetExtractor.extract_tweets(write_result_path)
end

println("hello")
println("sleeping...")
sleep(10, "data/big_unlabeled_tweets")
println("done")

