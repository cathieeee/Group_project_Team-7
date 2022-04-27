using CSV
using DataFrames
using MLJ
include("get_doc_vectors.jl")
import .DocVector as doc_vec

function get_features(df)
    # delimit by something else?
    tweet_text_list = Vector(df[!, :tweet_text])
    return doc_vec.make_features(tweet_text_list)
end

function main()
    input_csv_file = "data/unlabeled_tweets.csv"
    df = CSV.read(input_csv_file, DataFrame, header=1, delim='|')
    features = get_features(df)
    print(features)
    feature_size = length(features[1])
    labels = Vector(df[!, :sentiment_label])
    (train_features_vector, test_features_vector), (train_labels, test_labels) = partition((features, labels), 
                 0.8, 
                 rng=123,
                 multi=true,
                 shuffle=true)

    train_features = []
    test_features = []

    model = LIBSVM.fit!(LIBSVM.SVC(), train_features, train_labels)
    predictions = LIBSVM.predict(model, test_features)
    print(misclassification_rate(predictions, test_labels))
end

main()