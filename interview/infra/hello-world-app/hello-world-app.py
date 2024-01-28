# from flask import Flask, jsonify
# from datetime import datetime

# app = Flask(__name__)

# @app.route('/')
# def hello_world():
#     return jsonify(message='Hello, World!', timestamp=datetime.now().isoformat())

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080)
# import json
# import traceback

# def lambda_handler(event, context):
#     try:
#         # Your logic here
#         return {
#             'statusCode': 200,
#             'headers': {'Content-Type': 'application/json'},
#             'body': json.dumps({
#                 'message': 'Hello, World!',
#                 # other response details
#             })
#         }
#     except Exception as e:
#         print(traceback.format_exc())  # Print the traceback to CloudWatch logs
#         return {
#             'statusCode': 500,
#             'body': json.dumps({'error': str(e)})
#         }

# def handler(event, context):
#     return {
#         'statusCode': 200,
#         'body': json.dumps({'message': 'Hello World'})
#     }

import json
from datetime import datetime

def handler(event, context):
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


