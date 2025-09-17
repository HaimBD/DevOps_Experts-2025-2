import boto3
import json
import base64

# Create the client
client = boto3.client("bedrock-runtime", region_name="us-east-1")

# Titan Image Generator expects JSON input
prompt = {
    "taskType": "TEXT_IMAGE",
    "textToImageParams": {
        "text": "A futuristic data center with glowing lights"
    }
}

response = client.invoke_model(
    modelId="amazon.titan-image-generator-v1",
    contentType="application/json",
    accept="application/json",
    body=json.dumps(prompt)   # ✅ proper JSON encoding
)

# Read and parse the JSON response
response_body = json.loads(response["body"].read())
image_base64 = response_body["images"][0]   # Titan returns a list of images

# Save the image
with open("generated_image.png", "wb") as f:
    f.write(base64.b64decode(image_base64))

print("Image saved as generated_image.png")