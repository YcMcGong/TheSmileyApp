import StringIO
import googlemaps
# from PIL import Image

""" Image Resize """
# def image_resize(img):
    
#     size = (80,80)
#     # image = Image.open(img)
#     # cover = resizeimage.resize_cover(image, [80, 80])
#     image.thumbnail(size, Image.ANTIALIAS)
#     return save_img_to_StringIO(image)

def save_img_to_StringIO(img):
    # import StringIO
    img_io = StringIO.StringIO()
    img.save(img_io, 'JPEG', quality = 100)
    img_io.seek(0)
    return img_io

def address_to_gps(address):
    # import googlemaps
    gmaps = googlemaps.Client(key='AIzaSyBWI6d4t99Hpdxv8DSUXBoPwn1m10QxCCc')
    # Geocoding an address
    gps = gmaps.geocode(address)
    lat = gps[0]['geometry']['location']['lat']
    lng = gps[0]['geometry']['location']['lng']
    return [lat, lng]

def gps_to_address(Lat, Lng):
    # Look up an address with reverse geocoding
    # import googlemaps
    gmaps = googlemaps.Client(key='AIzaSyBWI6d4t99Hpdxv8DSUXBoPwn1m10QxCCc')
    data = gmaps.reverse_geocode((Lat, Lng))
    address = ''
    for i in data[0]['address_components']:
        address = address + i['short_name'] + '\t'
    return address