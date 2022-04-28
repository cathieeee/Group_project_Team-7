module MLModels
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
    
    function train_svm(train_features, train_labels, test_features, test_labels)
        println("running SVM...")
        svm_model = LIBSVM.fit!(SVC(), train_features, train_labels)
        predictions = LIBSVM.predict(svm_model, test_features)
        accuracy = 1 - misclassification_rate(predictions, test_labels)
        println("SVM accuracy: $accuracy")
    end
    
    function train_forest(train_features, train_labels, test_features, test_labels)
        println("running random forest classifier...")
        predictions, accuracy = train_model(RandomForestClassifier(), train_features, train_labels, test_features, test_labels)
        println("random forest accuracy: $accuracy")
    end
    
    function train_tree(train_features, train_labels, test_features, test_labels)
        println("running decision tree classifier...")
        predictions, accuracy = train_model(DecisionTreeClassifier(), train_features, train_labels, test_features, test_labels)
        println("decision tree accuracy: $accuracy")
    end
    
    function train_model(model, train_features, train_labels, test_features, test_labels)
        ScikitLearn.fit!(model, train_features, train_labels)
        predictions = ScikitLearn.predict(model, test_features)
        accuracy = 1 - misclassification_rate(predictions, test_labels)
        return predictions, accuracy
    end
    
    function train_multinomial_nb(train_features, train_labels, test_features, test_labels)
        println("running multinomial nb...")
        predictions, accuracy = train_model(MultinomialNB(), train_features, train_labels, test_features, test_labels)
        println("multinomial nb accuracy: $accuracy")
    end
    
    function train_knn(train_features, train_labels, test_features, test_labels)
        println("running k nearest neighbors classifier..")
        model = KNeighborsClassifier(weights="distance")
        predictions, accuracy = train_model(model, train_features, train_labels, test_features, test_labels)
        println("multinomial nb accuracy: $accuracy")
    end
    
    
    function run_ml_models(input_csv_file)
        println("reading file...")
        tweets, labels = read_csv(input_csv_file)
    
        features = doc_vec.make_features(tweets)
        (train_features, test_features), (train_labels, test_labels) = partition((features, labels), 
        0.7, 
        rng=123,
        multi=true,
        shuffle=true)  
    
        train_svm(train_features, train_labels, test_features, test_labels)
        train_forest(train_features, train_labels, test_features, test_labels)
        train_tree(train_features, train_labels, test_features, test_labels)
        train_multinomial_nb(train_features, train_labels, test_features, test_labels)
        train_knn(train_features, train_labels, test_features, test_labels)
    end
end