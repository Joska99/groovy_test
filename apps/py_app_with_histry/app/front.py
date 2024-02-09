from flask import Flask, render_template, request, redirect, jsonify
from back import get_api
import json
import os

app = Flask(__name__)


@app.route("/")
def root():
    """
        Root redirect to /home
    """
    return redirect("home")


# Defining the home page of our site
@app.route("/home", methods=['GET', 'POST'])
def home():
    """
        Home HTML page with input from user
    """
    # If form submitted, then redirect to a city page
    if request.method == "POST":
        return redirect("city")

    BG_COLOR = os.getenv('BG_COLOR')

    return render_template('home.html', name="Joseph", title="weather-home", color=BG_COLOR)


@app.route("/city", methods=['GET', 'POST'])
def user():
    """
        HTML page with weather stat 7 days forward
    """
    city_input = request.form.get("city_input")
    # Test for empty input
    if city_input == "":
        city_input = "London"
    try:
        # Use Back module to get API
        list_days = get_api(city_input)
    except Exception:
        return redirect("error")
    
    # Write history
    data_json = {
        'city': city_input,
    }
    # TODO: UNCOMENT
    # with open('history.json', 'a') as f:
    #     json.dump(data_json, f)
    #     f.write('\n')

    return render_template('city.html',  city=city_input, title=city_input, list=list_days, back="/")


@app.route("/error")
def err():
    """
        Error page
    """
    return render_template("error.html",  title="error-page", back="/")

@app.route("/history")
def history():
    """
        History page
    """
    data = ''
    # TODO: UNCOMENT
    # TODO: ADD DOWNLOAD FILE
    # with open('history.json', 'r') as f:
    #     data = f.readlines()

    return render_template("history.html",  title="history-page", back="/", json=data)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
