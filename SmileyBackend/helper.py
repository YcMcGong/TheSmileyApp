from googleplaces import GooglePlaces
import StringIO
import googlemaps
import hmac

""" Image Resize """

API_KEY = 'AIzaSyBWI6d4t99Hpdxv8DSUXBoPwn1m10QxCCc'

def save_img_to_StringIO(img):

    img_io = StringIO.StringIO()
    img.save(img_io, 'JPEG', quality = 100)
    img_io.seek(0)
    return img_io

def address_to_gps(address):
    # import googlemaps
    gmaps = googlemaps.Client(key=API_KEY)
    # Geocoding an address
    gps = gmaps.geocode(address)
    lat = gps[0]['geometry']['location']['lat']
    lng = gps[0]['geometry']['location']['lng']
    return [lat, lng]

def gps_to_place_list(Lat, Lng):
    # Set up google places API
    google_places = GooglePlaces(API_KEY)
    # Search for place
    query_result = google_places.nearby_search(lat_lng = {'lat': Lat, 'lng': Lng}, radius = 100,
    type = 'point_of_interest')

    # If found result within radius
    data = []
    if query_result.places:
        
        for place in query_result.places:
            
            name = place.name
            format_lat = float(place.geo_location['lat'])
            format_lng = float(place.geo_location['lng'])
            # place.get_details()
            # address = place.formatted_address
            data.append({'name': name, 'lat': format_lat, 'lng': format_lng})

    else:
        data = '_new'

    return data


def hash_password(imput_password_string):
    SECRET = "imsosecret"    #change this if want to change hash function
    return hmac.new(SECRET,imput_password_string).hexdigest()


def gps_to_address(Lat, Lng):
    # Look up an address with reverse geocoding
    # import googlemaps
    gmaps = googlemaps.Client(key=API_KEY)
    data = gmaps.reverse_geocode((Lat, Lng))
    address = data[0]['formatted_address']
    return address


""" __________________________
###| Legacy Code              |
####__________________________|
"""

# def gps_to_address(Lat, Lng):
#     # Look up an address with reverse geocoding
#     # import googlemaps
#     gmaps = googlemaps.Client(key='AIzaSyBWI6d4t99Hpdxv8DSUXBoPwn1m10QxCCc')
#     data = gmaps.reverse_geocode((Lat, Lng))
#     print(data)
#     # address = ''
#     # for i in data[0]['address_components']:
#     #     address = address + i['short_name'] + '\t'
#     address = data[0]['formatted_address']
#     # print(data)
#     # Check if place existed
#     if data[0]['geometry']['location_type']=='ROOFTOP' or data[0]['geometry']['location_type']=='APPROXIMATE':
#         place_id = data[0]['place_id']
#         test = gmaps.place(place_id)
#         print(test)
#         # name = gmaps.place(place_id)['name']
#         name = test['result']['name']
#     else:
#         name = '_new'
#     return (address, name)



# def gps_to_address(Lat, Lng):
    
#     # Set up google places API
#     google_places = GooglePlaces(API_KEY)
#     # Search for place
#     query_result = google_places.nearby_search(lat_lng = {'lat': Lat, 'lng': Lng}, radius = 70,
#     type = 'point_of_interest')

#     # If found result within radius
#     if query_result:
#         place =  query_result.places[0]
#         name = place.name
#         place.get_details()
#         format_lat = float(place.geo_location['lat'])
#         format_lng = float(place.geo_location['lng'])
#         address = place.formatted_address

#     else:
#         name = '_new'

#     return (address, name, format_lat, format_lng)