using CSV
using DataFrames
using MLJ
using LIBSVM
    using ScikitLearn
    @sk_import ensemble: RandomForestClassifier
    @sk_import tree: DecisionTreeClassifier
    @sk_import naive_bayes: MultinomialNB
    @sk_import neighbors: KNeighborsClassifier
    include("get_doc_vectors.jl")
    import .DocVector as doc_vec

    """
        read_train_csv(input_file::String)
    
    Return ids, tweets, and labels from CSV at input_file path with labeled tweets.
    """
    function read_train_csv(input_file::String)
        tweets = String[]
        labels = Int8[]
        ids = Set()
        reader = open(input_file, "r")
        for line in readlines(reader)
            line_vector = split(line, "|")
            push!(ids, line_vector[1])              
            push!(tweets, line_vector[2])
            push!(labels, parse(Int8, strip(line_vector[3])))
        end
        close(reader)
        return ids, tweets, labels
    end


    """Return a trained SVM classifier"""
    function train_svm(train_features::Array, 
                       train_labels::Array, 
                       test_features::Array, 
                       test_labels::Array)
        println("running SVM...")
        svm_model = LIBSVM.fit!(SVC(), train_features, train_labels)
        train_preds = LIBSVM.predict(svm_model, train_features)
        val_preds = LIBSVM.predict(svm_model, test_features)
        train_acc = 1 - misclassification_rate(train_preds, train_labels)
        val_acc = 1 - misclassification_rate(val_preds, test_labels)
        println("SVM training accuracy: $train_acc")
        println("SVM validation accuracy: $val_acc")

        return svm_model
    end

    """Return a trained random forest classifier"""
    function train_forest(train_features::Array, 
                          train_labels::Array, 
                          test_features::Array, 
                          test_labels::Array)
        println("running random forest classifier...")

        train_acc, val_acc, model = train_model(
            RandomForestClassifier(), 
            train_features, 
            train_labels, 
            test_features, 
            test_labels
           )
        println("random forest train accuracy: $train_acc")
        println("random forest val accuracy: $val_acc")
        return model
    end

    """Return a trained multinomial naive bayes classifier"""
    function train_tree(train_features::Array, 
                        train_labels::Array, 
                        test_features::Array, 
                        test_labels::Array)
        println("running decision tree classifier...")

        train_acc, val_acc, model = train_model(
            DecisionTreeClassifier(), 
            train_features, 
            train_labels, 
            test_features, 
            test_labels
           )
        println("decision tree train accuracy: $train_acc")
        println("decision tree val accuracy: $val_acc")
        return model
    end
    
    """
        train_model(model,
                    train_features::Array, 
                    train_labels::Array, 
                    test_features::Array, 
                    test_labels::Array)

        Train and return model along with its training & validation accuracies. 
    """
    function train_model(model, 
                        train_features::Array, 
                        train_labels::Array, 
                        test_features::Array, 
                        test_labels::Aray)
        ScikitLearn.fit!(model, train_features, train_labels)
        train_preds = ScikitLearn.predict(model, train_features)
        val_preds = ScikitLearn.predict(model, test_features)
        train_acc = 1 - misclassification_rate(train_preds, train_labels)
        val_acc = 1 - misclassification_rate(val_preds, test_labels)
        return train_acc, val_acc, model
    end

    """Return a trained multinomial naive bayes classifier"""
    function train_multinomial_nb(train_features::Array, 
                                  train_labels::Array, 
                                  test_features::Array, 
                                  test_labels::Array)
        println("running multinomial nb...")
        train_acc, val_acc, model = train_model(
                                                MultinomialNB(), 
                                                train_features, 
                                                train_labels, 
                                                test_features, 
                                                test_labels
                                               )
        println("multinomial nb training accuracy: $train_acc")
        println("multinomial nb validation accuracy: $val_acc")
        return model
    end
    
    """Return a trained k nearest neighbors classifier"""
    function train_knn(train_features::Array, 
                       train_labels::Array, 
                       test_features::Array, 
                       test_labels::Arrays)
        println("running k nearest neighbors classifier..")
        model = KNeighborsClassifier(weights="distance")

        train_acc, val_acc, model = train_model(
                                                KNeighborsClassifier(weights="distance"), 
                                                train_features, 
                                                train_labels, 
                                                test_features, 
                                                test_labels
                                               )
        println("k nearest neighbors training accuracy: $train_acc")
        println("k nearest neighbors validation accuracy: $val_acc")
        return model
    end
    
    """
        train_ml_models(tweets_csv::String, token_csv::String)

    Return ids and trained model given a tweets_csv and ngram token_csv filepaths.
    """
    function train_ml_models(tweets_csv::String, token_csv::String)
        println("reading file...")
        ids, tweets, labels = read_train_csv(tweets_csv)
    
        features = doc_vec.make_train_features(tweets, token_csv)
        (train_features, test_features), (train_labels, test_labels) = partition((features, labels), 
        0.7, 
        rng=123,
        multi=true,
        shuffle=true)  

        # model = train_svm(train_features, train_labels, test_features, test_labels)
        # model = train_multinomial_nb(train_features, train_labels, test_features, test_labels)
        model = train_forest(train_features, train_labels, test_features, test_labels)
        # model = train_knn(train_features, train_labels, test_features, test_labels)
        # model = train_tree(train_features, train_labels, test_features, test_labels)
        return ids, model  
    end

    """
        read_test_csv(test_csv::String, train_ids::Array)
    
    Return test_ids and and tweets as texts given test_csv filepath and train_ids. 
    """
    function read_test_csv(test_csv::String, train_ids::Array)
        tweets = String[]
        test_ids = String[]
        reader = open(test_csv, "r")
        line_num = 0
        try
            for line in readlines(reader)
                line_vector = split(line, "|")
                curr_id = line_vector[1]
                if !(curr_id in train_ids)
                    tweet_text = strip(line_vector[2])
                    push!(test_ids, curr_id)
                    push!(tweets, tweet_text)
                end
                line_num += 1
            end
        catch e
            println("error:$e")
            println("line: $line_num")
        end
        return test_ids, tweets
    end

    """
        test_model(model, token_csv::String, test_csv::String, train_ids::Array)

    Return test ids and their corresponding predicted sentiment labels.

    # Arguments
     - `model`: model used to predict sentiment labels
     - `token_csv::String`: filepath to CSV containing ngrams mapped to feature
        vector index
     - `train_ids`: tweet ids of tweets used for training the model
    """
    function test_model(model, token_csv::String, test_csv::String, train_ids::Array)
        println("generating sentiment labels using trained model...")
        test_ids, tweets = read_test_csv(test_csv, train_ids)
        test_features = doc_vec.make_test_features(tweets, token_csv)
        # return test_ids, LIBSVM.predict(model, test_features)
        return test_ids, ScikitLearn.predict(model, test_features)
    end


    """
        write_predictions(preds_csv::String, test_ids::Array, preds::Array)

    Write test_ids & preds to preds_csv filepath in format 'id|label'
    """
    function write_predictions(preds_csv::String, test_ids::Array, preds::Array)
        writer = open(preds_csv, "w")
        for (id, label) in zip(test_ids, preds)
            println(writer, "$id|$label")
        end
        close(writer)
    end

    """
        write_sentiment_results(output_file::String, preds::Array)

    Write proportion of each label from preds to output_file
    """
    function write_sentiment_results(output_file::String, preds::Array)
        num_tweets = 0
        num_neg = 0
        num_neut= 0
        num_pos = 0

        for label in preds
            if label == 0
                num_neg += 1
            elseif label == 1
                num_neut += 1
            else # label ==2
                num_pos +=1
            end
            num_tweets +=1
        end

        percent_neg = num_neg/ num_tweets
        percent_neut = num_neut / num_tweets
        percent_pos = num_pos / num_tweets
        
        writer = open(output_file, "w")
        println(writer, "negative: $percent_neg")
        println(writer, "neutral: $percent_neut")
        println(writer, "positive: $percent_pos")
        close(writer)
    end

"""Main function to take in program arguments"""
function main()
    # program arguments: <train tweets csv file> <token csv> <test tweets csv file>  <predictions csv> <results csv>
    train_tweets_csv, token_csv, test_tweets_csv, preds_csv, results_csv = ARGS[1], ARGS[2], ARGS[3], ARGS[4], ARGS[5]
    train_ids, svm_model = train_ml_models(train_tweets_csv, token_csv)
    test_ids, predictions = test_model(svm_model, token_csv, test_tweets_csv, train_ids)
    write_predictions(preds_csv, test_ids, predictions)
    write_sentiment_results(results_csv, predictions)
end

main()