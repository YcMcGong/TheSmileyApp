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

""" Login related---------------------------------------------------------"""
class Login(flask_login.UserMixin):
    
    def __init__(self):
        self.exp_id = ''
        self.experience = ''
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
                print(flask_login.current_user.experience)
                return jsonify({'status': 'success'}), 201
        return "", 400

    else:
        return "", 400


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

@app.route('/friendlist', methods=['GET', 'POST', 'DELETE'])
@flask_login.login_required
def get_friendlist():
    if request.method == 'GET':
        # if request.form.get('rule') == 'default':
        # test = []
        # test.append({'name':'Mike', 'email': 'baba@gmail.com', 'explorer_num': '00012'})
        # test.append({'name':'Kate', 'email': 'kitea@gmail.com', 'explorer_num': '00032'})
        # test.append({'name':'Bob', 'email': 'boli@gmail.com', 'explorer_num': '00071'})
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        friendlist = show_all_friends(flask_login.current_user.id, cursor)
        cursor.close()
        db.close()        
        return jsonify(friendlist)

    elif request.method == 'POST':
        to_email = request.form.get('email')
        status = 'follow'

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

# Map view
@app.route('/map', methods=['GET', 'POST'])
@flask_login.login_required
def get_map():
    if request.method == 'GET':
        # if request.form.get('rule') == 'default':
        # test = []
        # test.append({'url':'https://storage.googleapis.com/smileyappios.appspot.com/marker-2017-10-10-212652.jpg', 'lat': '33.7926977', 'lng': '-84.36952639999998'})
        # test.append({'url':'https://storage.googleapis.com/smileyappios.appspot.com/marker-2017-10-12-002946.jpg', 'lat': '33.7563179', 'lng': '-84.37345149999999'})
        # test.append({'url':'https://storage.googleapis.com/smileyappios.appspot.com/marker-2017-10-09-182320.jpg', 'lat': '33.7036039', 'lng': '-84.39714939999999'})
        
        rule = request.form.get('rule')
        if not rule: rule = 'default' # Set default rule

        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        data = get_attractions(flask_login.current_user.id, rule, cursor)
        cursor.close()
        db.close()

        # data.append({'url':'https://storage.googleapis.com/smileyappios.appspot.com/marker-2017-10-10-212652.jpg', 'lat': '33.7926977', 'lng': '-84.36952639999998'})
        return jsonify(data)
    else:
        return "", 400

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
        cover_file = request.files.get('cover')
        marker_file = request.files.get('marker')

        marker = upload_image_file(marker_file)
        cover = upload_image_file(cover_file)

        # score = flask_login.current_user.experience
        ID = marker
        email = flask_login.current_user.id
        address, map_name = gps_to_address(float(lat), float(lng))

        # If the place already exist, use the name from google map
        if map_name != '_new':
            name = map_name

        date_created = get_date()

        # Connect to SQL
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        # Fetch user experience
        found_user = fetch_user(flask_login.current_user.id, cursor)
        score = found_user.experience
        # Create an attraction
        attraction = Attraction(ID, name, marker, cover, lat, lng, intro, score, address, email, date_created)

        insert_new_attraction(attraction, cursor)
        cursor.close()
        db.close()

        return jsonify({'status': 'success'}), 201

    elif request.method == 'GET':
        
        db = connect_to_cloudsql()
        cursor = db.cursor()
        cursor.execute("""USE Smiley""") # Specifies the name of DB
        ID = request.args.get('attraction')
        place_info = look_up_place_data(ID, cursor)

        # place_info = {
        #     'url': 'https://storage.googleapis.com/smileyappios.appspot.com/cover-2017-10-10-212653.jpg',
        #     'Name':'Georgia State Fair',
        #     'Address': '2009 Test Drive, Atlanta 30309',
        #     'ExpID': '00001',
        #     'ExpName':'Smiley Baby',
        #     'Intro': 'A great event'
        # }

        cursor.close()
        db.close()

        return jsonify(place_info)
    else:
        return '', 404
    # return marker

def get_date():
    today = datetime.datetime.today()

    # Zero padding dates
    if today.month<10:
        month = '0'+str(today.month)
    else:
        month = str(today.month)

    if today.day<10:
        day = '0'+str(today.day)
    else:
        day = str(today.day)
    date = str(today.year) + month + day
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

# Liking 
@app.route('/like', methods=['GET', 'POST'])
@flask_login.login_required
def like_a_place():
    if request.method == 'POST':
        # Read Data
        attraction = request.form.get('attraction')
        like = request.form.get('like')
        email = flask_login.current_user.id

        if attraction and like and email:
            db = connect_to_cloudsql()
            cursor = db.cursor()
            cursor.execute("""USE Smiley""") # Specifies the name of DB
            add_like(email, attraction, like, cursor)
            cursor.close()
            db.close() # Close the cursor and db connection
            return jsonify({'status': 'success'}), 201

        return "", 400
        
    return "", 400

# Function handlers
@app.route('/init_all_this_is_a_secret_key_not_posting_here')
def init_all_tables():
    
    db = connect_to_cloudsql()
    cursor = db.cursor()
    cursor.execute("""USE Smiley""") # Specifies the name of DB

    # cursor.execute("""DROP TABLE Users""")
    # cursor.execute("""CREATE TABLE Users (
    # exp_id varchar(15),
    # name varchar(50),
    # email varchar(50) PRIMARY KEY,
    # password varchar(255),
    # experience varchar(10)
    # )""")

    # cursor.execute("""DROP TABLE Attractions""")
    # cursor.execute("""CREATE TABLE Attractions (
    # ID varchar(255) PRIMARY KEY,
    # name varchar(255),
    # marker varchar(255),
    # cover varchar(255),
    # lat varchar(50),
    # lng varchar(50),
    # intro varchar(255),
    # score varchar(15),
    # address varchar(255),
    # email varchar(50),
    # date_created varchar(15)
    # )""")

    # cursor.execute("""DROP TABLE Friends""")
    # cursor.execute("""CREATE TABLE Friends (
    # by_user_email varchar(50),
    # to_user_email varchar(50),
    # relation varchar(15)
    # )""")

    # cursor.execute("""DROP TABLE Likes""")
    # cursor.execute("""CREATE TABLE Likes (
    # user_email varchar(50),
    # attraction_url varchar(255),
    # rating varchar(15)
    # )""")

    # # cursor.execute("""DROP TABLE Reviews""")
    # cursor.execute("""CREATE TABLE Reviews (
    # user_email varchar(50),
    # attraction_url varchar(255),
    # image_url varchar(255),
    # intro varchar(255),
    # rating varchar(15)
    # )""")

    cursor.close()
    db.close()

    return jsonify({'Set up': 'Done'}), 200

if __name__ == '__main__':
    # app.debug = True
    app.run(host = '0.0.0.0', port = 5000)
