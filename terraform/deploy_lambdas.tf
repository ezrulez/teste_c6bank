data "archive_file" "lertwitter"{
  type="zip"
  output_path = "../lambda/lertwitter.zip"
  source_dir =  "../lambda/LeituraTwitter"
}
data "archive_file" "kinesis2dynamodb"{
  type="zip"
  output_path = "../lambda/kinesis2dynamodb.zip"
  source_dir =  "../lambda/ParserKinesis2Dynamo"
}



resource "aws_iam_role" "lambda_dynamodb"{
    name = "lambda_dynamodb"
    assume_role_policy = <<REGRA
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
REGRA
}


resource "aws_iam_role" "lambda_kinesis" {
  name = "lambda_kinesis"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dynamodbpolicy"{
    name = "dynamodbpolicy"
    description = "Politica de uso do DynamoDB"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:ListTables",
        "dynamodb:DeleteItem",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:DescribeContinuousBackups",
        "dynamodb:DescribeLimits",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:DescribeStream",
        "dynamodb:UpdateItem",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListStreams",
        "dynamodb:CreateTable",
        "dynamodb:DescribeGlobalTableSettings",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeGlobalTable",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:DescribeBackup",
        "dynamodb:UpdateTable",
        "dynamodb:GetRecords",
        "kinesis:GetRecords",
        "kinesis:PutRecords",
        "kinesis:UpdateShardCount",
        "kinesis:PutRecord",
        "kinesis:GetRecord",
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:ListStreams",
        "s3:AbortMultipartUpload",
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:DeleteBucketWebsite",
        "s3:DeleteObject",
        "s3:DeleteObjectTagging",
        "s3:DeleteObjectVersion",
        "s3:DeleteObjectVersionTagging",
        "s3:GetAccelerateConfiguration",
        "s3:GetAccountPublicAccessBlock",
        "s3:GetAnalyticsConfiguration",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketLocation",
        "s3:GetBucketLogging",
        "s3:GetBucketNotification",
        "s3:GetBucketPolicy",
        "s3:GetBucketPolicyStatus",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketWebsite",
        "s3:GetEncryptionConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetMetricsConfiguration",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectTagging",
        "s3:GetObjectTorrent",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectVersionTorrent",
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:ListBucketByTags",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:ListMultipartUploadParts",
        "s3:PutAccelerateConfiguration",
        "s3:PutAnalyticsConfiguration",
        "s3:PutBucketCORS",
        "s3:PutBucketLogging",
        "s3:PutBucketNotification",
        "s3:PutBucketRequestPayment",
        "s3:PutBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutBucketWebsite",
        "s3:PutEncryptionConfiguration",
        "s3:PutInventoryConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:PutMetricsConfiguration",
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionTagging",
        "s3:PutReplicationConfiguration",
        "s3:ReplicateDelete",
        "s3:ReplicateObject",
        "s3:ReplicateTags",
        "s3:RestoreObject"

    
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}
resource "aws_iam_policy" "kinesispolicy" {
  name        = "kinesispolicy"
  description = "Politica de uso do Kinesis Read/Write"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kinesis:GetRecords",
        "kinesis:PutRecords",
        "kinesis:UpdateShardCount",
        "kinesis:PutRecord",
        "kinesis:GetRecord",
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:ListStreams",
        "lambda:UpdateFunctionConfiguration"
        
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "log para os lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_kinesis" {
  role       = "${aws_iam_role.lambda_kinesis.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
resource "aws_iam_role_policy_attachment" "lambda_logs_dynamodb" {
  role       = "${aws_iam_role.lambda_dynamodb.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
resource "aws_iam_role_policy_attachment" "kinesis_vs_lambda" {
  role       = "${aws_iam_role.lambda_kinesis.name}"
  policy_arn = "${aws_iam_policy.kinesispolicy.arn}"
}

resource "aws_iam_role_policy_attachment" "kinesis_vs_s3" {
  role       = "${aws_iam_role.lambda_kinesis.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_vs_lambda" {
  role       = "${aws_iam_role.lambda_dynamodb.name}"
  policy_arn = "${aws_iam_policy.dynamodbpolicy.arn}"
}

resource "aws_iam_role_policy_attachment" "firehose_s3_role_policy" {
  role       = "${aws_iam_role.role_firehose.name}"
  policy_arn = "${aws_iam_policy.kinesispolicy.arn}"
}


resource "aws_lambda_function" "lerTwitter"{
    function_name = "lerTwitter"
    handler = "ler_twitter.lambda_handler"
    runtime = "python3.7"
    filename = "../lambda/lerTwitter.zip"
    source_code_hash = "${data.archive_file.lertwitter.output_base64sha256}"
    role = "${aws_iam_role.lambda_kinesis.arn}"
    environment {
        variables {
            c_key = "${var.c_key}"
            c_secret = "${var.c_secret}"
            tkn = "${var.tkn}"
            tkn_secret = "${var.tkn_secret}"
            ultimo_id = "0"
        
        }
    }
    lifecycle{
        ignore_changes = [
            "environment"
        ]
    }
    depends_on=[
        "data.archive_file.lertwitter"
    ]
    
    
}

resource "aws_lambda_function" "kinesis2dynamodb"{
    function_name = "kinesis2dynamodb"
    handler = "kinesis2dynamoDb.lambda_handler"
    runtime = "python3.7"
    filename = "../lambda/kinesis2dynamodb.zip"
    source_code_hash = "${data.archive_file.kinesis2dynamodb.output_base64sha256}"
    role = "${aws_iam_role.lambda_dynamodb.arn}"
    depends_on=[
        "data.archive_file.kinesis2dynamodb"
    ]
}



resource "aws_cloudwatch_event_rule" "a_cada_5_minutos" {
    name = "a_cada_5_minutos"
    description = "Chama o Handler a cada 5 minutos"
    schedule_expression = "rate(5 minutes)"
}
resource "aws_cloudwatch_event_rule" "a_cada_hora" {
    name = "a_cada_hora"
    description = "Chama o Handler a cada 1 hora"
    schedule_expression = "rate(60 minutes)"
}


resource "aws_cloudwatch_event_target" "evento_chamada_leitura_twitter" {
    rule = "${aws_cloudwatch_event_rule.a_cada_hora.name}"
    target_id = "lerTwitter"
    arn = "${aws_lambda_function.lerTwitter.arn}"
}

resource "aws_lambda_permission" "permissao_do_cloudwatch_chamar_lertwitter" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lerTwitter.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.a_cada_hora.arn}"
}



resource "aws_s3_bucket" "bucket" {
  bucket = "${var.twitter_bucket}"
  acl    = "private"
}

resource "aws_iam_role" "role_firehose" {
  name = "role_firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_kinesis_stream" "twitter" {
  name = "twitter"
  shard_count = 1
}

resource "aws_lambda_event_source_mapping" "kinesisTrigger" {
  event_source_arn  = "${aws_kinesis_stream.twitter.arn}"
  function_name     = "${aws_lambda_function.kinesis2dynamodb.arn}"
  starting_position = "LATEST"
}