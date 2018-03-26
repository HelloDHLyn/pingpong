import json
import logging
import os
import time

import boto3
import botocore.vendored.requests.packages.urllib3 as urllib3

logger = logging.getLogger(__name__)
http = urllib3.PoolManager()


def _notifiy_slack(service_name, delay):
    data = {
        'text': f"Service \"{service_name}\" has stopped! (Delay: {delay}s)",
    }

    response = http.request(
        'POST',
        url=os.environ['SLACK_URL'],
        headers={'content-type': 'application/json'},
        body=json.dumps(data),
    )

    if response.status != 200:
        logger.error(
            f"Slack integration error({response.status}), {response.data}"
        )


def handle(event, context):
    """
    Check last timestamps and send notification if there are some delays.

    Environment variables:
      - MAX_DELAY_SECONDS (default: 300)
      - SLACK_URL
    """

    client = boto3.client('dynamodb')

    response = client.scan(TableName='Pingpong')
    for item in response['Items']:
        service_name = item['ServiceName']['S']
        last_timestamp = int(item['LastTimestamp']['N'])
        delay = int(time.time() - last_timestamp / 1000)

        if delay >= int(os.environ.get('MAX_DELAY_SECONDS', 300)):
            if 'SLACK_URL' in os.environ:
                _notifiy_slack(service_name, delay)
