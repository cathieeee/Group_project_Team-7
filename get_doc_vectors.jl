module DocVector
    using TextAnalysis
    using PyCall
    using Pkg
    @pyimport nltk

#    ENV["PYTHON"] = "/Users/elizabethzhang/brown_venvs/biol1555_env/bin/python3"    
#    Pkg.build("PyCall")

    function stem_corpus(corpus)
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

    #TODO: stil have to handle emojis, numbers, noncharacters 
    function preprocess_corpus(corpus)
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

    function convert_to_bigram(corpus)
        doc_list = []
        for doc in corpus
            ## CHANGE NGRAM HERE ##
            push!(doc_list, NGramDocument(doc, 1)) 
        end
        return Corpus(doc_list)
    end

    function make_token_index(n_gram_crps)
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

    function make_features(tweet_list, tkn_dict=nothing)
        doc_list = []
        for tweet in tweet_list
            push!(doc_list, StringDocument(tweet))
        end
        crps = Corpus(doc_list)
        crps = preprocess_corpus(crps)

        # convert to corpus with NGramDocuments
        crps = convert_to_bigram(crps)
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

    function write_token_index(tkn_dict, tkn_csv_path)
        writer = open(tkn_csv_path, "w")
        for (ngram, index) in tkn_dict
            println(writer, "$ngram|$index")
        end
        close(writer)
    end

    function read_token_csv(csv_path)
        token_dict = Dict()
        reader = open(csv_path, "r")
        for line in readlines(reader)
            line_vector = split(line, "|")
            token_dict[line_vector[1]] = parse(Int64, line_vector[2])
        end
        return token_dict
    end

    function make_train_features(tweet_list, tkn_csv_path)
        println("making train features...")
        train_token_index, train_features = make_features(tweet_list)
        # write token_index csv
        write_token_index(train_token_index, tkn_csv_path)
        return train_features
    end

    function make_test_features(tweet_list, tkn_csv_path)
        println("making test features...")
        tkn_dict = read_token_csv(tkn_csv_path)
        test_token_index, test_features = make_features(tweet_list, tkn_dict)
        return test_features
    end
end