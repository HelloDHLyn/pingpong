import json
import logging
import time

import boto3

logger = logging.getLogger(__name__)


def handle(event, context):
    """
    Update last timestamp.

    Request body:
    {
      "service_name": "string"
    }

    Return:
    null
    """

    req_body = json.loads(event['body'])
    service_name = req_body['service_name']

    client = boto3.client('dynamodb')
    succeed = True
    try:
        client.put_item(
            TableName='Pingpong',
            Item={
                'ServiceName': {'S': service_name},
                'LastTimestamp': {'N': str(int(time.time() * 1000))},
            },
        )
    except Exception:
        logger.exception('Exception raised!')
        succeed = False

    return {
        'statusCode': 200 if succeed else 500,
        'headers': {'content-type': 'application/json'},
        'body': 'null',
    }
