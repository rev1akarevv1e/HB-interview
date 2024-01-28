import json
from datetime import datetime

def handler(event, context):
    #raise Exception("Test exception for CloudWatch alarm")

    # Get the current date and time
    current_time = datetime.now().isoformat()

    # Create a response message
    response_message = {
        'message': 'Hello, World!',
        'timestamp': current_time
    }

    # Return the response
    return {
        'statusCode': 200,
        'body': json.dumps(response_message),
        'headers': {
            'Content-Type': 'application/json'
        }
    }


