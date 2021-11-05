from flask import Flask, request
import time
import requests
import os
from elasticapm.contrib.flask import ElasticAPM

app = Flask(__name__)
apm = ElasticAPM(app)

@app.route("/", methods=["GET"])
def index():
    downstream_service = os.environ['DOWNSTREAM_SERVICE']
    r = requests.get(f'{downstream_service}/ping')
    return r.text

@app.route("/hi/<name>", methods=["GET"])
def hello(name):
    return f"Hello, {name}"

@app.route("/bye/<name>", methods=["GET"])
def goodbye(name):
    return f"Goodbye, {name}!"

if __name__ == "__main__":
    app.run(debug=False, host='0.0.0.0')
