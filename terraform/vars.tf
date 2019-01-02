variable "region" {
    default = "us-east-1"
}

variable "twitter_bucket"{
    default ="jmsjbucket1"
}
variable "c_key"{
    default  = "<consumer_key>"
}

variable "c_secret"{
    default  = "<consumer_secret>"
}

variable "tkn"{
    default  = "<token>"
}
variable "tkn_secret"{
    default  = "<token_secret>"
}


data "aws_caller_identity" "current" {}

provider "aws"{
    region = "${var.region}"
}

