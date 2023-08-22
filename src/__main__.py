from  flask import Falsk, redirect, url_for, render_template, request

app = Flask(__name__)

@app.route("/", methods=["POST", "GET"])
def home():
	'''Home page of the app'''
	return "<h1>Hello World!</h1>"


if __name__ == "__main":
    app.run(debug=True)
