from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello_world():
	return "<h1>Hello World!</h1>"

port = int(os.environ.get('PORT', 5000))
if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=port)
