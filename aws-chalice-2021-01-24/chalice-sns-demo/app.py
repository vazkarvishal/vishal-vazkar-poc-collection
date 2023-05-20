from chalice import Chalice
import requests

app = Chalice(app_name='chalice-sns-demo', debug=True)


@app.route('/')
def index():
    return {'hello': 'world'}

@app.on_sns_message(topic='MyDemoTopic')
def handle_sns_message(event):
    app.log.debug("Received message with subject: %s, message: %s", event.subject, event.message)
    print("Hello world")
    # response = requests.post('https://hooks.slack.com/services/APIKEY', data='{"website_status":"Hello, World!"}')
    # app.log.info(response)
    
# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
