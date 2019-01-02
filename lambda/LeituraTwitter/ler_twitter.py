import json
import os
import boto3
import tweepy
from tweepy import OAuthHandler
from base64 import b64decode


def lambda_handler(event, context):

    c_key_enc = os.environ['c_key']
    c_secret_enc = os.environ["c_secret"]
    tkn_env_enc = os.environ['tkn']
    tkn_secret_enc = os.environ["tkn_secret"]
    ultimo_id = os.environ["ultimo_id"]

    c_key = boto3.client('kms').decrypt(
        CiphertextBlob=b64decode(c_key_enc))['Plaintext']
    c_secret = boto3.client('kms').decrypt(
        CiphertextBlob=b64decode(c_secret_enc))['Plaintext']
    tkn = boto3.client('kms').decrypt(
        CiphertextBlob=b64decode(tkn_env_enc))['Plaintext']
    tkn_secret = boto3.client('kms').decrypt(
        CiphertextBlob=b64decode(tkn_secret_enc))['Plaintext']

    twitter_client_id = c_key
    twitter_secret = c_secret
    twitter_token = tkn
    twitter_token_secret = tkn_secret

    auth = OAuthHandler(twitter_client_id, twitter_secret)
    auth.set_access_token(twitter_token, twitter_token_secret)
    auth = OAuthHandler(twitter_client_id, twitter_secret)
    auth.set_access_token(twitter_token, twitter_token_secret)

    api = tweepy.API(auth)

    kinesis = boto3.client('kinesis')

    hashtag = "desafiode"
    lista = tweepy.Cursor(api.search, q=hashtag, since_id=ultimo_id).items()
    ordList = []

    for i in lista:
        ordList.append(i._json)

    ordList = sorted(ordList, key=lambda k: k["id"])

    for t in ordList:
        print("Inserindo registro do usuario %s" % (t["user"]["name"]))
        kinesis.put_record(StreamName="twitter",
                           Data=json.dumps(t), PartitionKey="filler")
        ultimo_id = t["id"]
    client = boto3.client("lambda")    
    client.update_function_configuration(
        FunctionName = 'lerTwitter',
        Environment={
            "Variables":{
                "ultimo_id": str(ultimo_id),
                 "c_key"=c_key_enc,
                 "c_secret" = c_secret_enc,
                  "tkn" = tkn_env_enc,
                  "tkn_secret"= tkn_secret_enc
            }
        }
    )    
    


