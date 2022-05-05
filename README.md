Project Group Name:
Group 7 "Tweety Birds" README 

Project Name/Intro:
Using a Multiclass SVM to Classify Twitter Sentiment of COVID-19 Drug Treatments

Brief project Description:
This program uses the twitter API to request historical tweets that meet out search criteria and then runs those tweets through a series of pre-processing steps. After pre-processing, this program runs the post-processed tweets through multiple classification machine learning models to map the sentiment (positive, negative or neutral) of each tweet. This program is ready to run as is. However, if users want to search for tweets meeting a separate criteria i.e. a different time period or different languages or types of tweets they can change parameters in the "query_params_academic" object. This program is not compatible with other COVID-19 treatments as the machines in this program are entirely dependent on a predetermined training set restricted to Ivermectin, Hydroxychloroquine and Remdesivir tweets. 

Noteworthy features: 
The first useful feature in this project is called get_keys() which obtains API access keys from a file on users machines that should be titled .final_keys. This enables for safe and secure access to critical API access token, secret and key information. Additionally, the next useful feature of this program is the make_GET_req() function. This function takes in the keys from get_keys() a search query parameter, and a url and sends a GET request to the provided URL- in this case the twitter API. (Explain any other noteworthy functions (prob other than the machine… maybe explain corpus?)

Project Aim: 
This program aims to provide insight into public sentiment regarding popular COVID-19 drug treatments. 

Note and briefly describe any key concepts (technical, philosophical, or both) important to the user’s understanding:
Users should be familiar with the Twitter API “lingo” as setting query parameters is dependent on exact language. Users also must have some experience working in the Julia language and should be familiar with Java Script Object Notation. 

Core Technical Concepts/Inspiration: 
The machine learning portions of this program were inspired by published research on other disease indication sentiment analysis using twitter. See DOI: 10.1177/1932296818811679 for an example.

Why does it exist?: 
This project exists to help determine the sentiment and emotions twitter users hold for Covid-19 Drug Treatments. This can be very helpful for organizations like the FDA and CDC when determining the public or media’s view on Covid-19 related topics.

Frame your project for the potential user:
This project is designed for the researchers using Twitter API to gain specific twitter data as well as process and analyze the raw data for academic research needs. 

Compare/contrast your project with other, similar projects so the user knows how it is different from those projects:
Other projects have similarly utilized twitter to determine sentiment of the Covid-19 pandemic and sentiment of how the government was handling it. This project is different since it utilizes Julia to run the Twitter API compared to other projects that have mostly used Python. It also looks more specifically in drug treatment for Covid-19 compared to the pandemic as a whole.

Highlight the technical concepts that your project demonstrates or supports:
This project highlights the potential social media platforms like Twitter have when determining the view of medical treatments.

Getting Started/Requirements/Prerequisites/Dependencies Include any essential instructions for:
Download Julia
Create a Twitter Developer account and try to get elevated access or higher
If a project is being done at a college or university, try to see if a professor can help you get academic research access.

Installing the following packages:
HTTP
JSON
Dataframes
CSV
Libsvn
ScikitLearn 
TextAnalysis

Running it (order to run files):
Extract_tweets.jl
train_ml_models.jl

Versioning: Services, APIs, Systems

Thank you for reading this nonsense!

Creator Contact Emails:
 	Elizabeth Zhang (Elizabeth_Zhang1@Brown.edu) 
    Weiting Lyu (Weiting_Lyu@Brown.edu) 
    Kenneth Bradley (Kenneth_Bradley@Brown.edu) 
    Caleb Brodie (Caleb_Brodie@Brown.edu)


