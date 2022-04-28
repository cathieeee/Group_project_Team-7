module DocVector
    using TextAnalysis

    #TODO: stil have to handle emojis, numbers, noncharacters 
    function preprocess_corpus(corpus)
        # remove corrupted characters
        remove_corrupt_utf8!(corpus) 
        # strip case
        remove_case!(corpus)
        # strip punctuation and stop words
        # TODO: remove numbers
        prepare!(corpus, strip_punctuation| strip_articles| strip_prepositions| strip_pronouns| strip_stopwords)
        # TODO: Figure out stemmer
        # stem 
        # stem!(corpus)
    end

    function convert_to_bigram(corpus)
        doc_list = []
        for doc in corpus
        push!(doc_list, NGramDocument(doc.text, 2)) 
        end
        return Corpus(doc_list)
    end

    function make_token_index(n_gram_crps)
        token_index = Dict()
        counter = 1
        for doc in n_gram_crps
            for bigram_pair in ngrams(doc)
                bigram = bigram_pair[1]
                if !haskey(token_index, bigram)
                    token_index[bigram] = counter
                    counter += 1
                end
            end
        end
        return token_index
    end

    function make_features(tweet_list)
        doc_list = []
        println("making features...")
        for tweet in tweet_list
            push!(doc_list, StringDocument(tweet))
        end
        crps = Corpus(doc_list)
        preprocess_corpus(crps)
        # convert to corpus with NGramDocuments
        crps = convert_to_bigram(crps)
        # dict of bigram --> corresponding index in feature
        token_index = make_token_index(crps)
        # pre-allocate space? 
        
        num_features = length(tweet_list)
        feature_length = length(token_index)
        features = zeros(Int8, num_features, feature_length)
        for (i, doc) in enumerate(crps)
            for bigram in keys(ngrams(doc))
                index = token_index[bigram]
                features[i, index] = 1
            end
        end
        return features
    end
end