using CSV
using DataFrames
using TextAnalysis

# TODO: will have to change for actual pipeline
function read_doc_list(input_file)
    doc_list = []
    reader = open(input_file, "r")
    for line in readlines(reader)
        push!(doc_list, StringDocument(line))
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

function make_doc_tensor(ngram_doc, token_index)
    tensor = zeros(length(token_index))
    for bigram_pair in ngrams(ngram_doc)
        bigram = bigram_pair[1]
        tensor[token_index[bigram]] = 1
    end
    return tensor
end

function make_features(doc_list)
    crps = Corpus(doc_list)
    preprocess_corpus(crps)
    # convert to corpus with NGramDocuments
    crps = convert_to_bigram(crps)
    # dict of bigram --> corresponding index in feature
    token_index = make_token_index(crps)
    # pre-allocate space? 
    features = []
    for doc in crps
        push!(features, make_doc_tensor(doc, token_index))
    end
    return features
end

function main()
    csv_file = "data/ivermectin-sample-tweets.csv"
    # list of strings
    doc_list = read_doc_list(csv_file)
    features = make_features(doc_list)
    println(features[1])
end

main()