# Simple long-polling SQS worker
# - Uses boto3 long polling to receive messages and process them
# - Designed to be run inside Kubernetes as a Deployment

import os
import boto3
import time
import json

SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

if not SQS_QUEUE_URL:
    raise RuntimeError('SQS_QUEUE_URL environment variable must be set')

sqs = boto3.client('sqs', region_name=AWS_REGION)

def process_message(msg_body):
    # Placeholder; replace with real processing logic
    data = json.loads(msg_body)
    print('Processing', data)
    # Simulate work
    time.sleep(1)


def poll():
    while True:
        resp = sqs.receive_message(QueueUrl=SQS_QUEUE_URL, MaxNumberOfMessages=1, WaitTimeSeconds=20)
        messages = resp.get('Messages', [])
        if not messages:
            continue
        for m in messages:
            try:
                process_message(m['Body'])
                sqs.delete_message(QueueUrl=SQS_QUEUE_URL, ReceiptHandle=m['ReceiptHandle'])
            except Exception as e:
                print('Error processing message', e)


if __name__ == '__main__':
    poll()
