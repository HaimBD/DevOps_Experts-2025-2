import json
import boto3
import os

s3 = boto3.client('s3')
sqs = boto3.client('sqs')
rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    try:
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']

            # Analyze the image
            response = rekognition.detect_labels(
                Image={'S3Object': {'Bucket': bucket, 'Name': key}},
                MaxLabels=5,
                MinConfidence=70
            )

            labels = [label['Name'] for label in response['Labels']]

            result = {
                "file": key,
                "labels": labels
            }

            # Push to SQS
            sqs.send_message(
                QueueUrl=os.environ['QUEUE_URL'],
                MessageBody=json.dumps(result)
            )

            print(f"Analyzed {key}: {labels}")

        return {"statusCode": 200, "body": json.dumps("Success")}

    except Exception as e:
        print(e)
        return {"statusCode": 500, "body": str(e)}