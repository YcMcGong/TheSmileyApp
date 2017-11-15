"""This helper is to wrap the SQL queries as regular python fuction,
   so that it looks neat"""
from flask import Flask, render_template, request, redirect, url_for
import flask_login
import json
from flask import jsonify
#___________________________________________________________________
""" Structure Data"""
class User(flask_login.UserMixin):
    
    def __init__(self, name, email, password, exp_id = 'empty', experience = '-1'):
        self.exp_id = exp_id
        self.name = name
        self.email = email
        self.password = password
        self.experience = experience

    def __repr__(self):
        return '<User %r>' % self.name

class Attraction():
    
    def __init__(self, ID, name, marker, cover, lat, lng, intro, score, address, email, date_created):
        self.ID = ID
        self.name = name
        self.marker = marker
        self.cover = cover
        self.lat = lat
        self.lng = lng
        self.intro = intro
        self.address = address
        self.score = score
        self.email = email
        self.date_created = date_created

    def __repr__(self):
        return '<User %r>' % self.name

def Attraction_create(url, Lat, Lng):
    return {'url': url, 'lat': Lat, 'lng': Lng}

#___________________________________________________________________________________
""" Access SQL"""
# Users
def fetch_user(email, cursor):
    # cursor.execute("""SELECT name, email, password, goal FROM User WHERE email = %s""", (email,))
    cursor.execute("""SELECT exp_id, name, email, password, experience FROM Users WHERE email = %s""", (email,))
    info = cursor.fetchone()
    if info:
        found_user = User(exp_id = info[0], name = info[1], email = info[2], password = info[3], experience = info[4])
    else: found_user = None
    return found_user

def insert_new_user(User, cursor):
    reserved = 15
    cursor.execute("""SELECT * FROM Users""")
    info = cursor.fetchall()
    number_of_user = len(info) + reserved + 1
    exp_id = '000' + str(number_of_user)
    experience = '0'
    cursor.execute("""INSERT INTO Users (exp_id, name, email, password, experience) VALUES (%s, %s, %s, %s, %s)""", 
        (exp_id, User.name, User.email, User.password, experience))
    cursor.execute("""COMMIT""")
    pass

# Attractions
def insert_new_attraction(attraction, cursor):
    cursor.execute("""INSERT INTO Attractions (ID, name, marker, cover, lat, lng, intro, score, address, email, date_created) 
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""", 
        (attraction.ID, attraction.name, attraction.marker, attraction.cover, 
         attraction.lat, attraction.lng, attraction.intro, attraction.score, 
         attraction.address, attraction.email, attraction.date_created))
    cursor.execute("""COMMIT""")
    pass

def fetch_attraction(ID, cursor):
    cursor.execute("""SELECT ID, name, marker, cover, lat, lng, intro, score, address, email, date_created
     FROM Attractions WHERE ID = %s""", (ID,))
    info = cursor.fetchone()
    found_attraction = Attraction( info[0], info[1], info[2], info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10])
    return found_attraction

""" Read marker for different rules"""
def read_all_marker(cursor):
    cursor.execute("""SELECT marker, lat, lng FROM Attractions""")
    all_markers = cursor.fetchall()
    # print(all_markers)
    return all_markers

def read_all_friends_marker(email, cursor):
    cursor.execute("""SELECT marker, lat, lng 
    FROM Attractions
    INNER JOIN Friends
    ON Attractions.email = Friends.to_user_email
    WHERE Friends.by_user_email = %s""", (email,))
    friend_markers = cursor.fetchall()

    cursor.execute("""SELECT marker, lat, lng
    FROM Attractions
    WHERE email = %s""",(flask_login.current_user.id,))
    my_markers = cursor.fetchall()

    all_markers = friend_markers + my_markers

    return all_markers
"""________________________________________________________________________"""

def get_attractions(email, rule, cursor): # Return the attractions for a specific user

    if rule == 'readall':
        print('readall')
        all_markers = read_all_marker(cursor)
        data = []
        for result in all_markers:
            data.append(Attraction_create(result[0], result[1], result[2]))
        return data
    
    elif rule == 'default':
        print('found')
        all_markers = read_all_friends_marker(email, cursor)
        data = []
        for result in all_markers:
            data.append(Attraction_create(result[0], result[1], result[2]))
        return data
    
    else:
        print('else')
        return False
        

def look_up_place_data(ID, cursor):
    # Look up attraction data
    cursor.execute("""SELECT name, address, cover, intro, email FROM Attractions WHERE ID = %s""", (ID,))
    data = cursor.fetchone()
    name = data[0]
    address = data[1]
    cover = data[2]
    intro = data[3]
    email = data[4]
    # Look up poster data
    cursor.execute("""SELECT exp_id, name FROM Users WHERE email = %s""",(email,))
    poster_data = cursor.fetchone()
    exp_id = poster_data[0]
    expname = poster_data[1]
    # Create json data to return
    return_data = ({'url':cover, 'Name':name, 'Address': address, 
    'Intro' : intro, 'ExpID': exp_id, 'ExpName': expname})
    return return_data

# Friends
def add_follow(by_email, to_email, status, cursor):
    cursor.execute("""INSERT INTO Friends (by_user_email, to_user_email, relation) VALUES (%s, %s, %s)""", 
    (by_email, to_email, status))
    cursor.execute("""COMMIT""")

def delete_follow(by_email, to_email, cursor):
    cursor.execute("""DELETE FROM Friends WHERE by_user_email = %s AND to_user_email = %s""",(by_email, to_email))
    cursor.execute("""COMMIT""")

def show_all_friends(email, cursor):
    cursor.execute("""SELECT name, email, exp_id
    FROM Users
    INNER JOIN Friends
    ON Users.email = Friends.to_user_email
    WHERE Friends.by_user_email = %s""", (email,))

    friendlists = cursor.fetchall()

    friendlist = []
    for friend in friendlists:
        friendlist.append({'name': friend[0],'email': friend[1],'explorer_num': friend[2]})

    return friendlist

# Likes
class Like():
    def __init__(self, user_email, attraction_url, rating):
        self.user_email = user_email
        self.attraction_url = attraction_url
        self.rating = rating

def add_like(user_email, attraction_url, rating, cursor):
    if not fetch_like(user_email, attraction_url, cursor):
        cursor.execute("""INSERT INTO Likes (user_email, attraction_url, rating) VALUES (%s, %s, %s)""",(user_email, attraction_url, rating))
        cursor.execute("""COMMIT""")

def fetch_like(user_email, attraction_url, cursor):
    # Look up if a like exist
    cursor.execute("""SELECT user_email, attraction_url, rating 
    FROM Likes 
    WHERE user_email = %s 
    AND attraction_url = %s""",(user_email, attraction_url))
    data = cursor.fetchone()
    return data
