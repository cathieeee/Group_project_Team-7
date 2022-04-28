using CSV
using DataFrames
using MLJ
using LIBSVM
include("get_doc_vectors.jl")
import .DocVector as doc_vec

function read_csv(input_file)
    tweets = String[]
    labels = Int8[]
    reader = open(input_file, "r")
    counter = 1
    for line in readlines(reader)
        if counter != 1
            line_vector = split(line, "|")
            push!(tweets, line_vector[2])
            push!(labels, parse(Int8, line_vector[3]))
        end
        counter += 1
    end
    close(reader)
    return tweets, labels
end

function main()
    println("reading file...")
    input_csv_file = "data/sample_clean_table.csv"
    tweets, labels = read_csv(input_csv_file)
    features = doc_vec.make_features(tweets)

    println("training model...")
    (train_features, test_features), (train_labels, test_labels) = partition((features, labels), 
                 0.8, 
                 rng=123,
                 multi=true,
                 shuffle=true)
    
    svm_model = LIBSVM.fit!(SVC(), train_features, train_labels)
    println("running model...")
    predictions = LIBSVM.predict(svm_model, test_features)
    accuracy = 1 - misclassification_rate(predictions, test_labels)
    println(accuracy)
end

main()