import os
import pymongo
from datetime import datetime
from bson import ObjectId

def get_collection():
    # Get connection info from environment variables
    #CONNECTION_STRING = os.getenv('CONNECTION_STRING')
    #DB_NAME = os.getenv('DB_NAME')
    #COLLECTION_NAME = os.getenv('COLLECTION_NAME')
    CONNECTION_STRING = "mongodb://wordpress:wordpress@52.90.3.46:27017/restaurants_reviews?socketTimeoutMS=360000&connectTimeoutMS=360000&authSource=admin"
    DB_NAME = "restaurants_reviews"
    COLLECTION_NAME = "restaurants_reviews"
    
    # Create a MongoClient
    client = pymongo.MongoClient(CONNECTION_STRING)
    try:
        client.server_info() # validate connection string
    except pymongo.errors.ServerSelectionTimeoutError:
        raise TimeoutError("Invalid API for MongoDB connection string or timed out when attempting to connect")

    db = client[DB_NAME]
    return db[COLLECTION_NAME]

def create_restaurant_record(name, street_address, description):
    ts = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    restaurant_record = {
		"type": "restaurant",
		"name": name,
		"street_address": street_address,
		"description": description,
        "create_date":ts,
    }
    return restaurant_record

def create_review_record(restaurant_id, user_name, rating, review_text):
    ts = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    review_record = {
        "restaurant": ObjectId(restaurant_id),
		"type": "review",
		"user_name": user_name,
		"rating": int(rating),
		"review_text": review_text,
		"review_date": ts,
    }
    return review_record
