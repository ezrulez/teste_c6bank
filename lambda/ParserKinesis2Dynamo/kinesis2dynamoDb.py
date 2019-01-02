import json
import base64
import boto3
import datetime
import uuid


def lambda_handler(event, context):
    print("Iniciando a leitura do Kinesis")

    for record in event['Records']:
       #Kinesis data is base64 encoded so decode here
       payload = base64.b64decode(
           record["kinesis"]["data"]).decode("utf-8", "ignore")
       #print("Decoded payload: " + str(payload))
       tt = json.loads(payload)
       if(str(type(tt))=="<class 'str'>"):
              tt = json.loads(tt)
       #print(tt)
       usuario = tt["user"]
       print("Lendo Usuario %s " % (usuario["name"]))

       dynamo = boto3.resource("dynamodb")
       s3 = boto3.resource("s3").Bucket("jmsjbucket1")
       print("Escrevendo no S3")
       agora = datetime.datetime.now()
       guid = uuid.uuid4()
       nomeArq = "{0}/{1}/{2}/{3}/{4}/twitter_{1}{2}{3}{4}{5}_{6}.json".format(
           "twitter", agora.year, agora.month, agora.day, agora.hour, agora.minute, guid)
       arq_json = s3.Object(key=nomeArq).put(Body=json.dumps(tt))

       print("Inserindo no Dynamo")
       tabela = dynamo.Table("aggTwitter")

       try:
              i = tabela.get_item(Key={"usuario": usuario["name"]})["Item"]
       except Exception as x:
              i = None

       if i == None:
              i = {"usuario": usuario["name"], "qtdTweet": 1}
       else:
              i["qtdTweet"] = i["qtdTweet"] + 1
       r = tabela.put_item(Item=i)
