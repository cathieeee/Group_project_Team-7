module DocVector
    using TextAnalysis
    using PyCall
    using Pkg
    @pyimport nltk

    """
        stem_corpus(corpus::Corpus)
    
    Return a list of stemmed vectors given a corpus.
    """
    function stem_corpus(corpus::Corpus)
        doc_list = []
        for page in corpus
            nltk = pyimport("nltk")
            stemmer = nltk.stem.porter.PorterStemmer()
            page_tokens = Vector{String}()
            for word in split(page.text)
                python_word = stemmer.stem(PyObject(word), 
                                           to_lowercase=false)
                push!(page_tokens, convert(String, python_word))
            end
            push!(doc_list, join(page_tokens, " "))
        end
        return doc_list
    end

    """
        preprocess_corpus(corpus::Corpus)

    Return a preprocessed corpus given a corpus.
    """
    function preprocess_corpus(corpus::Corpus)
        # remove corrupted characters
        remove_corrupt_utf8!(corpus) 
        # strip case
        remove_case!(corpus)
        # strip punctuation and stop words
        # TODO: remove numbers
        prepare!(corpus, strip_punctuation| strip_articles| strip_prepositions| strip_pronouns| strip_stopwords| strip_numbers)
        # TODO: Figure out stemmer
        # stem 
        return stem_corpus(corpus)
    end

    """
        convert_to_ngram(corpus::Corpus)
    
    Return a corpus of NGramDocuments containing ngrams given a corpus. 
    """
    function convert_to_ngram(corpus::Corpus)
        doc_list = []
        for doc in corpus
            push!(doc_list, NGramDocument(doc, 1)) 
        end
        return Corpus(doc_list)
    end

    """
        make_token_index(n_gram_crps::Corpus)
    
    Return a dictionary of ngram -> feature index given a Corpus with ngrams.
    """
    function make_token_index(n_gram_crps::Corpus)
        token_index = Dict()
        counter = 1
        for doc in n_gram_crps
            for ngram_pair in ngrams(doc)
                ngram = ngram_pair[1]
                if !haskey(token_index, ngram)
                    token_index[ngram] = counter
                    counter += 1
                end
            end
        end
        return token_index
    end

    """
        make_features(tweet_list::Vector, tkn_dict=nothing::Dict)
    
    Return a token dictionary & one-hot encoded ngram features. 

    # Arguments 
        - tweet_list::Vector: vector of Strings of tweets
        - tkn_dict=nothing::Dict: token dictionary of ngrams -> feature index 
           used for creating test features; defaults to nothing for training 
           features
    """
    function make_features(tweet_list::Vector, tkn_dict=nothing)
        doc_list = []
        for tweet in tweet_list
            push!(doc_list, StringDocument(tweet))
        end
        crps = Corpus(doc_list)
        crps = preprocess_corpus(crps)

        # convert to corpus with NGramDocuments
        crps = convert_to_ngram(crps)
        # dict of bigram --> corresponding index in feature
        token_index = nothing
        if isnothing(tkn_dict)
            token_index = make_token_index(crps)
        else
            token_index = tkn_dict
        end

        num_features = length(tweet_list)
        feature_length = length(token_index)
        features = zeros(Int8, num_features, feature_length)
        for (i, doc) in enumerate(crps)
            for ngram in keys(ngrams(doc))
                if haskey(token_index, ngram)
                    index = token_index[ngram]
                    features[i, index] = 1
                end
            end
        end
        return token_index, features
    end

    """
        write_token_index(tkn_dict::Dict, tkn_csv_path::String)
    
    Write token dictionary of ngram -> feature dictionary to tkn_csv_path.
    """
    function write_token_index(tkn_dict::Dict, tkn_csv_path::String)
        writer = open(tkn_csv_path, "w")
        for (ngram, index) in tkn_dict
            println(writer, "$ngram|$index")
        end
        close(writer)
    end

    """
        read_token_csv(csv_path::String)
    
    Return dictionary read from a CSV mapping ngrams to feaure indices at csv_path.
    """
    function read_token_csv(csv_path::String)
        token_dict = Dict()
        reader = open(csv_path, "r")
        for line in readlines(reader)
            line_vector = split(line, "|")
            token_dict[line_vector[1]] = parse(Int64, line_vector[2])
        end
        return token_dict
    end

    """
        make_train_features(tweet_list::Vector, tkn_csv_path::String)

    Return one hot encoded ngram features and write ngrams -> feature index. 

    # Arguments 
        - tweet_list::Vector: vector of Strings representing tweets
        - tkn_csv_path::String: path to write ngrams -> feature index
          dictionary to as CSV in form "ngram|feature"
    """
    function make_train_features(tweet_list::Vector, tkn_csv_path::String)
        println("making train features...")
        train_token_index, train_features = make_features(tweet_list)
        # write token_index csv
        write_token_index(train_token_index, tkn_csv_path)
        return train_features
    end

    """
        make_test_features(tweet)
    
    Return test features given tweet_list and tkn_csv_path with ngram -> feature index.
    """
    function make_test_features(tweet_list, tkn_csv_path)
        println("making test features...")
        tkn_dict = read_token_csv(tkn_csv_path)
        test_token_index, test_features = make_features(tweet_list, tkn_dict)
        return test_features
    end
end