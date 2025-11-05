from flask import Flask, request, jsonify
import boto3, psycopg2, os, json

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({'message': 'Flask app running on EKS!'})

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    bucket = os.environ['S3_BUCKET']
    s3 = boto3.client('s3')
    s3.upload_fileobj(file, bucket, file.filename)
    return jsonify({'status': 'uploaded', 'file': file.filename})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
