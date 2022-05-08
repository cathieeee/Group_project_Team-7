using JSON

include("extract_tweets.jl")
include("process_json.jl")
include("train_ml_models.jl")

import .TweetExtractor as tweet_extractor
import .TweetJSONReader as json_reader
import .MLModels as ml_models

### FIX SO THIS WORKS EVENTUALLY

function make_unlabeled_csv(api_result_path, 
                            unlabeled_tweets_path)
    # tweet_extractor.extract_tweets(api_result_path)
    println("extracted tweets")
    json_reader.write_unlabeled_tweets(api_result_path, unlabeled_tweets_path)
end

function train_models(labeled_tweets_path)
    ml_models.train_ml_models(labeled_tweets_path)
end

function main()
    api_result_path = "data/test_api_result.json"
    unlabeled_tweets_path = "data/test_unlabeled.csv"
    tweet_extractor.extract_tweets(api_result_path)
end

main()