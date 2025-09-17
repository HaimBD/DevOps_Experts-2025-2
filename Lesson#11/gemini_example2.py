import boto3
import json
from botocore.exceptions import ClientError
from google import genai
from google.genai import types


def get_secret(secret_name="api", region_name="us-east-1") -> str:
    """Retrieve the Gemini API key from AWS Secrets Manager."""
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise RuntimeError(f"Failed to retrieve secret {secret_name}: {e}")

    secret = get_secret_value_response["SecretString"]

    # Handle both JSON and plain text secrets
    try:
        json_secret = json.loads(secret)
        return json_secret['API']
    except (KeyError, json.JSONDecodeError):
        return secret.strip()


def main():
    # Fetch the Gemini API key securely
    api_key = get_secret()

    # Initialize Gemini client with the key from Secrets Manager
    client = genai.Client(api_key=api_key)

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents="What is the weather in Tel Aviv right now?",
        config=types.GenerateContentConfig(
            thinking_config=types.ThinkingConfig(thinking_budget=0)  # disables 'thinking'
        ),
    )

    print(response.text)


if __name__ == "__main__":
    main()

