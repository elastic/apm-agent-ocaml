from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    return "ping, pong"

@app.route("/hi/<name>", methods=["GET"])
def hello(name):
    return f"Hello, {name}"

@app.route("/bye/<name>", methods=["GET"])
def goodbye(name):
    return f"Goodbye, {name}!"

if __name__ == "__main__":
    app.run()
