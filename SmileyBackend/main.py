# coding=utf-8
from flask import jsonify

from flask import Flask, render_template, request, redirect, url_for, flash, current_app
from werkzeug.utils import secure_filename
import flask_login
from SQL_helper import *
# from helper import image_resize, address_to_gps, gps_to_address
from helper import *
import MySQLdb
import config
import json
import os
import storage
import datetime
import logging

app = Flask(__name__)

# Create flask login manager
app.secret_key = 'testing_secret_key'
login_manager = flask_login.LoginManager()
login_manager.init_app(app)

# # Connect to Google Cloud SQL
app.config.from_object(config)   

# Connection Function
def connect_to_cloudsql():
    db = config.connect_to_cloudsql()# Deployment
    return db

# db = connect_to_cloudsql()
# cursor = db.cursor()
# cursor.execute("""USE Smiley""") # Specifies the name of DB

"""
#  ________________________________________
# |Definition of the Login Class           |
# |________________________________________|
"""

class Login(flask_login.UserMixin):
    
    def __init__(self):
        self.exp_id = ''
        self.experience = 0
    # pass

@login_manager.user_loader
def user_loader(email):
    user = Login()
    user.id = email
    return user

# Routing from here
@app.route('/', methods=['GET', 'POST'])
def test():
    return jsonify({'one':1, 'two':2})

"""
#  ________________________________________
# |User & Login Related Sessions           |
# |________________________________________|
"""
# Login function
@app.route('/user', methods=['GET', 'POST'])
def user_login():
    if request.method == 'POST':
        # Read data
        email = request.form.get('email')
        password = request.form.get('password')

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        found_user = fetch_user(email, cursor)
        cursor.close()
        db.close()

        if found_user:  # User located
            hashed_password = hash_password(password)  #get the hashed password from typed password
            if found_user.password == hashed_password:  #compare stored hashed password with hased typed password
                
                user = Login()
                user.id = email
                user.experience = found_user.experience
                user.exp_id = found_user.exp_id

                flask_login.login_user(user)
                # print(flask_login.current_user.experience)
                return jsonify({'status': 'success'}), 201
        return "", 400

    else:
        return "", 400

# Logout function
@app.route('/user_logout', methods=['GET'])
def user_logout():
    if request.method == 'GET':
        logout_user()
        return jsonify({'status': 'success'})

# Create User
@app.route('/create_user', methods=['GET', 'POST'])
def create_user():
    if request.method == 'POST':
        # Read data
        email = request.form.get('email')
        password = request.form.get('password')
        name = request.form.get('name')
       
        if email and password and name:
            # Check if the user has been created
            db = connect_to_cloudsql()
            cursor = db.cursor()
            cursor.execute("""USE Smiley""") # Specifies the name of DB
            found_user = fetch_user(email, cursor)
            if found_user:
                cursor.close()
                db.close()
                return "", 400
            
            # Create guest
            hashed_password = hash_password(password) #store hashed password after sign up
            guest = User(name = name, email=email, password=hashed_password)
            insert_new_user(guest, cursor) # Insert Guest into the DB
            found_user = fetch_user(email, cursor)
            cursor.close()
            db.close()

            # Automatically log in the use after sign up
            user = Login()
            user.id = email
            user.experience = found_user.experience
            user.exp_id = found_user.exp_id
            flask_login.login_user(user)

            return jsonify({'status': 'success'}), 201
        else:
            return "", 400
    else:
        return "", 400

"""
#  ________________________________________
# | Profile Session                        |
# |________________________________________|
"""

@app.route('/profile', methods=['GET', 'POST'])
@flask_login.login_required
def get_profile():
    if request.method == 'GET':
        # Read data
        email = request.form.get('email')

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        found_user = fetch_user(flask_login.current_user.id, cursor)
        cursor.close()
        db.close()
        return jsonify({'ID':found_user.exp_id, 'experience': found_user.experience, 'name': found_user.name, 'email': found_user.email})
    else:
        return "", 400

"""
#  ________________________________________
# | Friend & Relationship Section          |
# |________________________________________|
"""

@app.route('/friendlist', methods=['GET', 'POST', 'DELETE'])
@flask_login.login_required
def get_friendlist():
    if request.method == 'GET':
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        friendlist = show_all_friends(flask_login.current_user.id, cursor)
        cursor.close()
        db.close()        
        return jsonify(friendlist)

    elif request.method == 'POST':
        to_email = request.form.get('email')
        status = 1

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        add_follow(flask_login.current_user.id, to_email, status, cursor)
        cursor.close()
        db.close()
        return jsonify({'status': 'success'}), 201

    elif request.method == 'DELETE':
        email = request.args.get('email')

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        delete_follow(flask_login.current_user.id, email, cursor)
        cursor.close()
        db.close()
        return jsonify({'status': 'success'}), 201

    else:
        return "", 400


"""
#  ________________________________________
# | Map related Session                    |
# |________________________________________|
"""
# Map view
@app.route('/map', methods=['GET', 'POST'])
@flask_login.login_required
def get_map():
    if request.method == 'GET':
        
        rule = request.form.get('rule')
        if not rule: rule = 'default' # Set default rule

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        data = get_attractions(flask_login.current_user.id, rule, cursor)
        cursor.close()
        db.close()

        return jsonify(data)
    else:
        return "", 400

"""
#  ________________________________________
# | Attraction related Session             |
# |________________________________________|
"""

# Attraction View
@app.route('/attraction', methods=['GET', 'POST'])
@flask_login.login_required
def create_a_new_place_post():
    if request.method == 'POST':
        # Read Data
        name = request.form.get('name')
        lat = request.form.get('lat')
        lng = request.form.get('lng')
        intro = request.form.get('intro')
        rating = request.form.get('rating')
        cover_file = request.files.get('cover')
        marker_file = request.files.get('marker')

        marker = upload_image_file(marker_file)
        cover = upload_image_file(cover_file)
        # print(marker)

        # Calculate the score based on the user experience and the rating
        score = int(float(flask_login.current_user.experience)/10.0 * (float(rating) + 10))
        
        ID = marker
        email = flask_login.current_user.id
        # address, map_name, lat, lng = gps_to_address(float(lat), float(lng))
        address = gps_to_address(float(lat), float(lng))

        # # If the place already exist, use the name from google map
        # if map_name != '_new':
        #     name = map_name

        date_created = get_date()

        # Connect to SQL
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        # Fetch user experience
        found_user = fetch_user(flask_login.current_user.id, cursor)
        score = found_user.experience
        # Create an attraction
        attraction = Attraction(ID, name, marker, cover, lat, lng, intro, score, rating, address, email, date_created)

        insert_new_attraction(attraction, cursor)
        cursor.close()
        db.close()

        return jsonify({'status': 'success'}), 201

    else:
        return '', 404
    # return marker

def get_date():

    date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return date


def upload_image_file(file):
    # Upload the user-uploaded file to Google Cloud Storage and retrieve its
    # publicly-accessible URL.

    public_url = storage.upload_file(
    file.read(),
    file.filename,
    file.content_type
    )

    return public_url

"""
#  ________________________________________
# | Location Service section               |
# |________________________________________|
"""
# Return the places nearby to the front end for selection
@app.route('/selectPlacesNearby', methods=['GET'])
def get_list_of_places_near_a_coordinate():
    if request.method == 'GET':
        lat = request.args.get('lat')
        lng = request.args.get('lng')
        place_list = gps_to_place_list(lat, lng)
        if place_list != "_new":
            return jsonify(place_list)
        else:
            return "", 400
        
"""
#  ________________________________________
# | Liking section                         |
# |________________________________________|
"""
# Liking 
@app.route('/like', methods=['GET', 'POST'])
@flask_login.login_required
def like_a_place():
    if request.method == 'POST':
        # Read Data
        attraction = request.form.get('attraction')
        like = request.form.get('like')
        # like = int(like)

        # Temporary Solution
        if like == '1':
            like = 2
        else:
            like = -1

        email = flask_login.current_user.id

        if attraction and like and email:
            date_created = get_date()
            db = connect_to_cloudsql()
            cursor = db.cursor()
            cursor.execute("""USE Smiley""") # Specifies the name of DB
            add_like(email, attraction, like, date_created, cursor)
            cursor.close()
            db.close() # Close the cursor and db connection
            return jsonify({'status': 'success'}), 201

        return "", 400

    elif request.method == 'GET':
        # Read Attraction ID
        attraction_ID = request.args.get('attraction')
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        data = fetch_like(flask_login.current_user.id, attraction_ID, cursor)
        cursor.close()

        if data:
            return_data = {'rating': data[2]}
        else:
            return_data = {'rating': 0}

        return jsonify(return_data)

    return "", 400

"""
#  ________________________________________
# |All Web Relation Content below this line|
# |________________________________________|
"""
# No login required
@app.route('/LookUpPlace', methods=['GET'])
def request_place_look_up():
    if request.method == 'GET':
        
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        ID = request.args.get('attraction')
        # print(ID)
        place_info, reviews_data = look_up_place_data(ID, cursor)
        cursor.close()
        db.close()

        rendered_template = render_place_data_template(place_info, reviews_data)
        return rendered_template
        # return jsonify(place_info)

def render_place_data_template(place_info, reviews_data):
    
    # return render_template('profile.html', name = found_user.name, email = found_user.email, \
    # goal = found_user.goal, group = json.dumps(data))
    reviews_data = reviews_data[0:-1] # Get rid of the earlist review, which is created by the explorer
    return render_template('place_template.html', place = place_info, reviews = reviews_data)

# Table Setting Functions
# Function handlers
@app.route('/init_all_this_is_a_secret_key_not_posting_here')
def init_all_tables():
    
    # db = connect_to_cloudsql()
    # cursor = db.cursor()
    # cursor.execute("""USE Smiley""") # Specifies the name of DB

    # # Clean all tables
    # cursor.execute("""SET FOREIGN_KEY_CHECKS = 0""")
    # cursor.execute("""DROP TABLE IF EXISTS Users""")
    # cursor.execute("""DROP TABLE IF EXISTS Attractions""")
    # cursor.execute("""DROP TABLE IF EXISTS Friends""")
    # cursor.execute("""DROP TABLE IF EXISTS Likes""")
    # cursor.execute("""DROP TABLE IF EXISTS Reviews""")
    # cursor.execute("""SET FOREIGN_KEY_CHECKS = 1""")

    # # Create all Tables
    # cursor.execute("""CREATE TABLE Users (
    # exp_id varchar(15),
    # name varchar(50),
    # email varchar(50),
    # password varchar(255),
    # experience int,
    # PRIMARY KEY(email)
    # )""")

    # cursor.execute("""CREATE TABLE Attractions (
    # ID varchar(255) PRIMARY KEY,
    # name varchar(255),
    # marker varchar(255),
    # cover varchar(255),
    # lat double,
    # lng double,
    # intro varchar(800),
    # score float,
    # address varchar(255),
    # email varchar(50),
    # date_created DATETIME
    # )""")
    # # !!!
    # # A bug in the data_created, need further investigation
    # # !!!

    # cursor.execute("""CREATE TABLE Friends (
    # by_user_email varchar(50) NOT NULL,
    # to_user_email varchar(50) NOT NULL,
    # relation float,
    # FOREIGN KEY (by_user_email) REFERENCES Users(email)
    # ON DELETE CASCADE ON UPDATE CASCADE,
    # FOREIGN KEY (to_user_email) REFERENCES Users(email)
    # ON DELETE CASCADE ON UPDATE CASCADE,
    # UNIQUE (by_user_email, to_user_email) )""")

    # cursor.execute("""CREATE TABLE Likes (
    # user_email varchar(50),
    # attraction_ID varchar(255),
    # rating float,
    # date_created DATETIME,
    # FOREIGN KEY (user_email) REFERENCES Users(email)
    # ON DELETE CASCADE ON UPDATE CASCADE,
    # FOREIGN KEY (attraction_ID) REFERENCES Attractions(ID)
    # ON DELETE CASCADE ON UPDATE CASCADE
    # )""")

    # cursor.execute("""CREATE TABLE Reviews (
    # user_email varchar(50),
    # attraction_ID varchar(255),
    # cover_url varchar(255),
    # marker_url varchar(255),
    # intro varchar(800),
    # rating float,
    # FOREIGN KEY (user_email) REFERENCES Users(email)
    # ON DELETE CASCADE ON UPDATE CASCADE,
    # date_created DATETIME,
    # FOREIGN KEY (attraction_ID) REFERENCES Attractions(ID)
    # ON DELETE CASCADE ON UPDATE CASCADE
    # )""")
    # cursor.close()
    # db.close()

    return jsonify({'Set up': 'Done'}), 200

if __name__ == '__main__':
    # app.debug = True
    app.run(host = '0.0.0.0', port = 5000)
