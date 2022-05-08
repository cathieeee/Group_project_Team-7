import json
import csv
import linecache
from shutil import copyfile
# import ipywidgets as widgets
# import numpy as np
# import pandas as pd
from panacea_get_metadata import get_metadata

# #Downloads the dataset (compressed in a GZ format)
# #!wget dataset_URL -O clean-dataset.tsv.gz
# wget.download(dataset_URL, out='clean-dataset.tsv.gz')

# #Unzips the dataset and gets the TSV dataset
# with gzip.open('clean-dataset.tsv.gz', 'rb') as f_in:
#     with open('clean-dataset.tsv', 'wb') as f_out:
#         shutil.copyfileobj(f_in, f_out)

# #Deletes the compressed GZ file
# os.unlink("clean-dataset.tsv.gz")

#Gets all possible languages from the dataset

CONSUMER_KEY = 'PoPtatozaqhaI4VVLqAzuHBoi' #@param {type:"string"}
CONSUMER_SECRET_KEY = '4WxV5clEfvRsfvcjbq5LFC8MkuZbSIexZvmbs40wJadOQV9z1p' #@param {type:"string"}
ACCESS_TOKEN_KEY = '1050753081045082112-cfVspqSwIQZ8mU4Yyswbn1KFSlpZcx' #@param {type:"string"}
ACCESS_TOKEN_SECRET_KEY = 'U1e67qiAW4IjSdBPFC6tRCFUgsca2uem1lkIJV0FZFWfk' #@param {type:"string"}
    

def get_dataset(dataset_fn, filtered_language): 
    if filtered_language == "":
        copyfile('data/clean-dataset.tsv', 'data/clean-dataset-filtered.tsv')

    #If language specified, it will create another tsv file with the filtered records
    else:
        filtered_tw = list()
        current_line = 1
        with open(dataset_fn) as tsvfile:
            tsvreader = csv.reader(tsvfile, delimiter="\t")

            if current_line == 1:
                filtered_tw.append(linecache.getline(dataset_fn, current_line))

            for line in tsvreader:
                if line[3] == filtered_language:
                    filtered_tw.append(linecache.getline(dataset_fn, current_line))
                current_line += 1

    print('\033[1mShowing first 5 tweets from the filtered dataset\033[0m')
    print(filtered_tw[1:(6 if len(filtered_tw) > 6 else len(filtered_tw))])

    with open('data/clean-dataset-filtered.tsv', 'w') as f_output:
        for item in filtered_tw:
            f_output.write(item)

def create_json_file():
    # Authenticate
    #Creates a JSON Files with the API credentials
    with open('api_keys.json', 'w') as outfile:
        json.dump({
        "consumer_key":CONSUMER_KEY,
        "consumer_secret":CONSUMER_SECRET_KEY,
        "access_token":ACCESS_TOKEN_KEY,
        "access_token_secret": ACCESS_TOKEN_SECRET_KEY
        }, outfile)

def hydrate_tweets(): 
    # input_fn, output_fn, key_file
    get_metadata("data/clean-dataset-filtered.tsv", "data/hydrated_tweets", "api_keys.json")

def main():
    dataset_filename = "data/2021-09-28_clean-dataset.tsv"
    # creates 'data/clean-dataset.tsv', 'data/clean-dataset-filtered.tsv'
    get_dataset(dataset_filename, "en")
    # creates 'api_keys.json'
    create_json_file()
    # gets metadata using "data/clean-dataset-filtered.tsv", "data/hydrated_tweets", "api_keys.json"
    # creates 'hydrated_tweets.json', 'hydrated_tweets.CSV', 'hydrated_tweets.zip', 'hydrated_tweets_short.json'
    hydrate_tweets()

main()