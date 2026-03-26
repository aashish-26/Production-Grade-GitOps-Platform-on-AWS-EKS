# Simple Flask API that accepts POST /job and pushes to SQS
# - Uses environment variables for configuration (no secrets hardcoded)
# - Designed for clarity and production adaptation (retry, metrics, tracing can be added)

from flask import Flask, request, jsonify
import os
import boto3
import json

app = Flask(__name__)

# Configuration via env vars
SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

if not SQS_QUEUE_URL:
    raise RuntimeError('SQS_QUEUE_URL environment variable must be set')

sqs = boto3.client('sqs', region_name=AWS_REGION)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})

@app.route('/job', methods=['POST'])
def create_job():
    payload = request.get_json(force=True)
    if not payload:
        return jsonify({'error': 'invalid payload'}), 400
    # Minimal validation
    message_body = json.dumps(payload)
    resp = sqs.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=message_body)
    return jsonify({'message_id': resp.get('MessageId')}), 202

if __name__ == '__main__':
    # For production use Gunicorn with multiple workers
    app.run(host='0.0.0.0', port=8080)
