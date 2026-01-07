from flask import Flask, request

app = Flask(__name__)
last_action = ""


@app.route("/event", methods=["POST"])
def event():
    global last_action
    last_action = request.json["action"]
    return "ok"


@app.route("/poll")
def poll():
    global last_action
    a = last_action
    last_action = ""
    return a


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
