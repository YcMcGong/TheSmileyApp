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
    
    def __init__(self, ID, name, marker, cover, lat, lng, intro, score, rating, address, email, date_created):
        self.ID = ID    #0
        self.name = name    #1
        self.marker = marker    #2
        self.cover = cover  #3
        self.lat = lat  #4
        self.lng = lng  #5
        self.intro = intro  #6
        self.address = address  #7
        self.score = score  #8
        self.rating = rating    #9
        self.email = email  #10
        self.date_created = date_created    #11

    def __repr__(self):
        return '<User %r>' % self.name

def Attraction_create(url, Lat, Lng, name='none', discover='none', rating='none'):
    return {'url': url, 'lat': Lat, 'lng': Lng, 'name': name, 'discover': discover, 'rating': rating}

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
    experience = 100
    cursor.execute("""INSERT INTO Users (exp_id, name, email, password, experience) VALUES (%s, %s, %s, %s, %s)""", 
        (exp_id, User.name, User.email, User.password, experience))
    cursor.execute("""COMMIT""")

    # Follow the user him/herself by default
    status = 100
    add_follow(User.email, User.email, status, cursor)
    pass

# Attractions
def insert_new_attraction(attraction, cursor):
    cursor.execute("""
        SELECT 
        ID, name, marker, cover, lat, lng, intro, score, address, email, date_created
        FROM 
        Attractions
        WHERE 
        address = %s""",
        (attraction.address,))
    info = cursor.fetchone()

    # Locatiion Existed
    if info:
        found_attraction_ID = info[0]
        cursor.execute("""
            INSERT INTO 
            Reviews 
            (user_email, attraction_ID, cover_url, marker_url, intro, rating, date_created)
            VALUES 
            (%s, %s, %s, %s, %s, %s, %s)
            """,
            (attraction.email, found_attraction_ID, attraction.cover, attraction.marker, 
            attraction.intro, int(attraction.rating), attraction.date_created)
        ) # BUG MIGHT BE FIXED , COME BACK AND LOOK TMR
        
        cursor.execute("""
            UPDATE Attractions
            SET score = score + %s
            WHERE ID = %s
            """, (int(attraction.rating), found_attraction_ID))

        cursor.execute("""COMMIT""")

    # Location Not Existed
    else:
        cursor.execute("""INSERT INTO Attractions (ID, name, marker, cover, lat, lng, intro, score, address, email, date_created)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            (attraction.ID, attraction.name, attraction.marker, attraction.cover,
             attraction.lat, attraction.lng, attraction.intro, int(attraction.score),
             attraction.address, attraction.email, attraction.date_created))
        cursor.execute("""COMMIT""")

        # Insert an review eventually
        cursor.execute("""
            INSERT INTO 
            Reviews 
            (user_email, attraction_ID, cover_url, marker_url, intro, rating, date_created)
            VALUES 
            (%s, %s, %s, %s, %s, %s, %s)""",
            (attraction.email, attraction.ID, attraction.cover, attraction.marker, attraction.intro, int(attraction.rating), attraction.date_created))
        cursor.execute("""COMMIT""")

    pass

def fetch_attraction(ID, cursor):
    cursor.execute("""SELECT ID, name, marker, cover, lat, lng, intro, score, rating, address, email, date_created
     FROM Attractions WHERE ID = %s""", (ID,))
    info = cursor.fetchone()
    found_attraction = Attraction( info[0], info[1], info[2], info[3], info[4], info[5], info[6], info[7], info[8], info[9], info[10], info[11])
    return found_attraction

""" Read marker for different rules"""
def read_all_marker(cursor):
    cursor.execute("""SELECT marker, lat, lng FROM Attractions""")
    all_markers = cursor.fetchall()
    # Markers format: [0] marker, [1] lat, [2] lng, [3] attraction_name, [4] discover, [5] rating
    data = []
    for result in all_markers:
        data.append(Attraction_create(result[0], result[1], result[2], result[3], result[4], result[5]))
    return data

def read_all_friends_marker(email, cursor, ifNews = True):
    
    like_marker_limit = 5
    global_marker_limit = 5
    # (Discover 15 of them)
    if ifNews:
        
        cursor.execute("""
        SELECT * FROM   
            (
            SELECT marker, lat, lng, attraction_name, name as discover, score + friend_rating as rating
            FROM
            (SELECT marker, lat, lng, name AS attraction_name, user_email, score, friend_rating, date_review
                    FROM Attractions
                    INNER JOIN
                    (SELECT attraction_ID, max(user_email) as user_email, date_review, friend_rating
                    FROM
                    Reviews
                    NATURAL JOIN
                        (
                            SELECT attraction_ID, MAX(date_created) AS date_review, ROUND(AVG(rating)) AS friend_rating
                            FROM 
                                Reviews
                                INNER JOIN Friends
                                ON Reviews.user_email = Friends.to_user_email
                                WHERE Friends.by_user_email = %s
                            GROUP BY attraction_ID
                        )   AS TB1
                        GROUP BY attraction_ID
                    ) AS TB2
                    ON Attractions.ID = TB2.attraction_ID
            ) AS TB3
            INNER JOIN
            Users
            ON TB3.user_email = Users.email
            ORDER BY date_review DESC
            LIMIT 30) AS TB4
        ORDER BY rating DESC
        LIMIT 15
        """, (flask_login.current_user.id,))
        # print(flask_login.current_user.id)

    else:
        cursor.execute("""
        SELECT * FROM   
        (
            SELECT marker, lat, lng, attraction_name, name as discover, score + friend_rating as rating
            FROM
            (SELECT marker, lat, lng, name AS attraction_name, user_email, score, friend_rating, date_review
                    FROM Attractions
                    INNER JOIN
                    (SELECT attraction_ID, max(user_email) as user_email, date_review, friend_rating
                    FROM
                    Reviews
                    NATURAL JOIN
                        (
                            SELECT attraction_ID, MIN(date_created) AS date_review, ROUND(AVG(rating)) AS friend_rating
                            FROM 
                                Reviews
                                INNER JOIN Friends
                                ON Reviews.user_email = Friends.to_user_email
                                WHERE Friends.by_user_email = %s
                            GROUP BY attraction_ID
                        )   AS TB1
                        GROUP BY attraction_ID
                    ) AS TB2
                    ON Attractions.ID = TB2.attraction_ID
            ) AS TB3
            INNER JOIN
            Users
            ON TB3.user_email = Users.email
            ORDER BY date_review DESC
            LIMIT 30) AS TB4
        ORDER BY rating DESC
        LIMIT 15
        """, (flask_login.current_user.id,))
    
    # Fetch all friend markersattractions
    friend_markers = cursor.fetchall()

    # (Based on likes 5)
    cursor.execute("""
    SELECT marker, lat, lng, Attractions.name AS attraction_name, ('based on like') AS discover, CONCAT('liking: ', rating) AS rating
        FROM
        Attractions
        INNER JOIN
        (
            SELECT attraction_ID, SUM(rating) AS rating
            FROM
            Likes
            INNER JOIN
                (
                SELECT * FROM Friends
                WHERE by_user_email = %s
                AND NOT to_user_email = %s
                ) AS TB1
            ON
            Likes.user_email = TB1.to_user_email
            GROUP BY attraction_ID
            ORDER BY rating DESC
            LIMIT 20
        ) AS TB2
        ON
    Attractions.ID = TB2.attraction_ID
    """, (flask_login.current_user.id, flask_login.current_user.id))
    like_markers = cursor.fetchall()

    # (Global Ranking 5)
    cursor.execute("""
    SELECT marker, lat, lng, attraction_name, CONCAT(name, ' :global') AS discover, score AS rating
    FROM 
    (
        SELECT marker, lat, lng, ID, Attractions.name AS attraction_name, email, score
        FROM
        Attractions
        INNER JOIN
        Reviews
        ON
        Attractions.ID = Reviews.attraction_ID
        GROUP BY ID
        ORDER BY MAX(Reviews.date_created) DESC
        LIMIT 100
    ) AS TB1
    INNER JOIN
    Users
    ON TB1.email = Users.email
    ORDER BY score DESC
    LIMIT 20
    """)
    global_markers = cursor.fetchall()

    # Markers format: [0] marker, [1] lat, [2] lng, [3] attraction_name, [4] discover, [5] rating

    data = []
    attraction_counter_to_prevent_repeat = []

    # Append friend markers
    for result in friend_markers:
        attraction_counter_to_prevent_repeat.append(result[0])
        data.append(Attraction_create(result[0], result[1], result[2], result[3], result[4], result[5]))

    # Append Like markers
    for count, result in enumerate(like_markers):
        if count>=like_marker_limit: break
        if result[0] not in attraction_counter_to_prevent_repeat:
            attraction_counter_to_prevent_repeat.append(result[0])
            data.append(Attraction_create(result[0], result[1], result[2], result[3], result[4], result[5]))

    # Append Global markers
    for count, result in enumerate(global_markers):
        if count>=global_marker_limit: break
        if result[0] not in attraction_counter_to_prevent_repeat:
            attraction_counter_to_prevent_repeat.append(result[0])
            data.append(Attraction_create(result[0], result[1], result[2], result[3], result[4], result[5]))

    return data

# Return all attractions for a specific user
def get_attractions(email, rule, cursor): # Return the attractions for a specific user

    # Markers format: [0] marker, [1] lat, [2] lng, [3] attraction_name, [4] discover, [5] rating

    if rule == 'readall':
        # print('readall')
        data = read_all_marker(cursor)
        return data
    
    elif rule == 'default':
        # print('found')
        data = read_all_friends_marker(email, cursor)
        return data
    
    else:
        # print('else')
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
    reviews_data = look_up_reviews_for_a_place(ID, cursor)
    return (return_data, reviews_data)

def look_up_reviews_for_a_place(ID, cursor):
    # Look for all reviews for an attraction ranked by DESC date order
    cursor.execute("""
    SELECT name, cover_url, intro, date_created
    FROM
    (SELECT attraction_ID, user_email, cover_url, intro, date_created FROM Reviews
    WHERE attraction_ID = %s
    ) AS Newest
    LEFT JOIN
    Users
    ON Newest.user_email = Users.email
    ORDER BY date_created DESC
    """, (ID,))
    data = cursor.fetchall()
    reviews_data = []
    for review in data:
        reviews_data.append({'username': review[0], 'cover_url': review[1], 'intro': review[2], 'date_created': review[3]})
    return reviews_data

# Friends
def add_follow(by_email, to_email, status, cursor):
    cursor.execute("""INSERT INTO Friends (by_user_email, to_user_email, relation) VALUES (%s, %s, %s)""", 
    (by_email, to_email, status))

    """
    _____________
    | Need update| 
    _____________"""
    # Temporary Solution... Auto Add Friend
    if to_email!=by_email:
        cursor.execute("""INSERT INTO Friends (by_user_email, to_user_email, relation) VALUES (%s, %s, %s)""", 
        (to_email, by_email, status))
    
    # Commit all the changes
    cursor.execute("""COMMIT""")

def delete_follow(by_email, to_email, cursor):
    cursor.execute("""DELETE FROM Friends WHERE by_user_email = %s AND to_user_email = %s""",(by_email, to_email))
    cursor.execute("""DELETE FROM Friends WHERE by_user_email = %s AND to_user_email = %s""",(to_email, by_email))
    cursor.execute("""COMMIT""")

def show_all_friends(email, cursor):
    cursor.execute("""SELECT name, email, exp_id
    FROM Users
    INNER JOIN Friends
    ON Users.email = Friends.to_user_email
    WHERE Friends.by_user_email = %s
    AND NOT Friends.to_user_email = %s""", (email, email))
    # Because by default a user will follow him/herself, but it is not necessary to show on friendlist

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

def add_like(user_email, attraction_url, rating, date_created, cursor):
    if not fetch_like(user_email, attraction_url, cursor):

        # Add Like
        cursor.execute(
        """
        INSERT INTO Likes (user_email, attraction_ID, rating, date_created)
        VALUES (%s, %s, %s, %s) 
        """,
        (user_email, attraction_url, rating, date_created))

        # Update Score
        cursor.execute(
        """
        UPDATE Attractions
        SET score = score + %s
        WHERE ID = %s
        """, (rating, attraction_url))
        cursor.execute("""COMMIT""") # Update the the score of that attraction as well

def fetch_like(user_email, attraction_ID, cursor):
    # Look up if a like exist
    cursor.execute("""SELECT user_email, attraction_ID, rating 
    FROM Likes 
    WHERE user_email = %s 
    AND attraction_ID = %s""",(user_email, attraction_ID))
    data = cursor.fetchone()
    return data

""" This area is for some backup code"""
    # # Fetch attractions created by the user itself
    # cursor.execute("""
    # SELECT marker, lat, lng, att_name as name, name as discover, score
    # FROM Users
    # INNER JOIN
    # (SELECT marker, lat, lng, name as att_name, score, email
    # FROM Attractions
    # WHERE email =  %s) AS TB1
    # ON Users.email = TB1.email
    # """,(flask_login.current_user.id,))
    # my_markers = cursor.fetchall()