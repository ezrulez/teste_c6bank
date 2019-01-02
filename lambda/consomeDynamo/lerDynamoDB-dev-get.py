import simplejson as json
import boto3


def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb")
    tabela = dynamodb.Table("aggTwitter")
    try:
        i = tabela.scan()["Items"]
    except Exception as x:
        i = None
    if i != None:
        corpo = {
            "statusCode": 200,
            "body": i
        }

    else:
        corpo = {
            "statusCode": 500,
            "body": {"message": "Falha ao ler os registros"}
        }
    return(json.dumps(corpo, indent=5))
