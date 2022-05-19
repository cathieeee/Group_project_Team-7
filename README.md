# Group 7 "Tweety Birds" —  Using Traditional Machine Learning Models to Classify Twitter Sentiment to COVID-19 Drug Treatments

## Brief Project Description
This program uses the Twitter API to request historical tweets that meet out search criteria and then runs those tweets through a series of pre-processing steps. After pre-processing, this program runs the post-processed tweets through multiple classification machine learning models to map the sentiment (positive, negative or neutral) of each tweet. This program is ready to run as is. However, if users want to search for tweets meeting a separate criteria i.e. a different time period or different languages or types of tweets they can change parameters in the "query_params_academic" object. This program is not compatible with other COVID-19 treatments as the machines in this program are entirely dependent on a predetermined training set restricted to Ivermectin, Hydroxychloroquine and Remdesivir tweets. 

## Noteworthy features
The first useful feature in this project is called get_keys() which obtains API access keys from a file on users machines that should be titled .final_keys. This enables for safe and secure access to critical API access token, secret and key information. Additionally, the next useful feature of this program is the make_GET_req() function. This function takes in the keys from get_keys() a search query parameter, and a url and sends a GET request to the provided URL- in this case the twitter API.

## Project Aim
This program aims to provide insight into public sentiment regarding popular COVID-19 drug treatments. 

Note and briefly describe any key concepts (technical, philosophical, or both) important to the user’s understanding:
Users should be familiar with the Twitter API “lingo” as setting query parameters is dependent on exact language. Users also must have some experience working in the Julia language and should be familiar with Java Script Object Notation. 

## Core Technical Concepts/Inspiration 
The machine learning portions of this program were inspired by published research on other disease indication sentiment analysis using twitter. See DOI: 10.1177/1932296818811679 for an example.

## Why does it exist?
This project exists to help determine the sentiment and emotions twitter users hold for Covid-19 Drug Treatments. This can be very helpful for organizations like the FDA and CDC when determining the public or media’s view on Covid-19 related topics.

**Frame the project for the potential user:**
This project is designed for the researchers using Twitter API to gain specific twitter data as well as process and analyze the raw data for academic research needs. 

**Compare/contrast your project with other, similar projects so the user knows how it is different from those projects:**
Other projects have similarly utilized twitter to determine sentiment of the Covid-19 pandemic and sentiment of how the government was handling it. This project is different since it utilizes Julia to run the Twitter API compared to other projects that have mostly used Python. It also looks more specifically in drug treatment for Covid-19 compared to the pandemic as a whole.

Highlight the technical concepts that your project demonstrates or supports:
This project highlights the potential social media platforms like Twitter have when determining the view of medical treatments.


## Requirements/Dependencies
**Versioning: Services, APIs**
-Julia v1.7.2 
-Academic Research Access to the Twitter API v2 

**Required dependencies:**
-HTTP
-JSON
-CSV
-LibSVM
-ScikitLearn 
-TextAnalysis
-PyCall 

## Getting Started
**Step 1:** Use `tweets_pipeline.jl` to extract tweets from the Twitter v2 API to use for the training set. Writes tweets to a CSV in the format of `id|tweet_text`. 
    
- Command Line Usage: `<csv path> <target amount of tweets> <next token> `
    - `<csv path>`: path to write unlabeled tweets to
    - `<target amount of tweets>`: amount of tweets to extract 
    - `<next token>`: optional argument if resuming extraction (`next token` is an argument that can be passed into the API query in order to get consecutive tweets)

**Step 2:** Hand label extracted tweets with their sentiment. Add a column to the CSV produced from **Step 1** called `sentiment_label`. The coding used for this project was: 
- `0` = negative sentiment, `1` = neutral, `2` = positive

But labels can be adjusted as desired.

**Step 3:** Run `train_ml_models.jl` to 1) partition the hand labeled tweets into a training/validation set, 2) train a traditional ML model on the training set, 3) run the model on a test set of unlabeled tweets. 

Command line usage: `<train tweets csv> <token csv> <test tweets csv>  <predictions csv> <results csv>`
- `<train tweets csv>`: file path to CSV containing labeled tweets in format `id|tweet text|sentiment label`. 
- `<token csv>`: file path to an intermediate CSV mapping *n*-grams to the index of the vector encoding
    - Features are one hot encoded *n*-grams represented as binary vectors. Since the *n*-grams used for the features is determined by the training set corpus, an intermediate CSV mapping *n*-grams to the index of the vector encoding that *n*-gram is necessary to create the test features. 
    - This CSV file is automatically created and read during the program and does not require user interaction. 
- `<test tweets csv>`: file path to CSV containing unlabeled tweets to be used for sentiment analysis; CSV should be in the format `id|tweet text`
- `<predictions csv>:` file path to write the predicted sentiment labels for each tweet. The file will be a CSV in the format `id|predicted label`. 
- `<results csv>:`file path for a CSV file that will contain the proportions of tweets labeled with each sentiment (negative, neutral, and positive).

Usage notes:
- The query used in the Twitter API request can be altered manually by changing the `query_academic_no_next` and `query_academic_next_token` variables in the `extract_tweets`function in `extract_tweets.jl`.
- The choice of using unigrams, bigrams, trigrams etc. can be altered manually in the `convert_to_ngram` function in `get_doc_vectors.jl`.
- Which machine learning model to use for the classifier can be adjusting by commenting the code the in `train_ml_models` function in `train_ml_models.jl`.


### Thank you so much for reading!

### Creator Contact Emails
Elizabeth Zhang (Elizabeth_Zhang1@Brown.edu) 
Weiting Lyu (Weiting_Lyu@Brown.edu) 
Kenneth Bradley (Kenneth_Bradley@Brown.edu) 
Caleb Brodie (Caleb_Brodie@Brown.edu)