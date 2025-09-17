import boto3

translate = boto3.client("translate", region_name="us-east-1")

result = translate.translate_text(
    Text="גנן גדל גדן בגן",
    SourceLanguageCode="he",
    TargetLanguageCode="en"
)

print(result["TranslatedText"])