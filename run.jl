include("extract_tweets.jl")
include("process_json.jl")
include("train_ml_models.jl")

import .TweetExtractor as tweet_extractor
import .TweetJSONReader as json_reader
import .MLModels as ml_models

function make_unlabeled_csv(api_result_path, 
                                  unlabeled_tweets_path)
    tweet_extractor.extract_tweets(api_result_path)
    json_reader.write_unlabeled_tweets(api_result_path, unlabeled_tweets_path)
end

function train_models(labeled_tweets_path)
    ml_models.train_ml_models(labeled_tweets_path)
end

function main()
    make_unlabeled_csv("data/test_api_result.json", 
                             "data/test_unlabeled_tweets.csv")
end

main()