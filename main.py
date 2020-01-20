import os
import json
from flask import Flask, request, jsonify, redirect, url_for
from pymongo import MongoClient

app = Flask(__name__)

client = MongoClient('mongo', 27017)
db = client.mind_map_db
collection = db.mind_map_collection

@app.route('/api/maps', methods=['POST'])
def maps():
    try:
        response = {}
        request_key_number = len(request.get_json().keys())
        if request_key_number <= 1:
            for k,v in request.get_json().items():
                if k == 'map_id':
                   query = { "map_id": v }
                   check_elem = collection.find(query)
                   if check_elem.count() == 0:
                       response["status"] = "Maps named {} successfully created".format(v)
                       data = { k: v, 'leafs': []}
                       collection.insert_one(data)
                       return response
                   else:
                       res = ('Map name '+ v + ' already exists')
                       raise Exception(res)
 
                else:
                   res = ('Attribute named '+ k + ' not suppported')
                   raise Exception(res)
        else:
            res = ('Too much attribute')
            raise Exception(res)
    except Exception as e:
        return str(e), 500
      

@app.route('/api/maps/<path:map_id>', methods=['POST'])
def leaf(map_id):
    try:
        response = {}

        #Retrieve object based on map_id passed in curl request 
        query = { "map_id": map_id }
        row = collection.find(query)
        
        #Check if row is empty
        if row.count() == 0:
            response["status"] = "Error: map_id named {} not found".format(map_id)
            res = ('Error: map_id named ' + map_id + ' not found')
            raise Exception(res)
        #If a leaf path already exists is not gonna override
        else:
            new_leaf = {}
            request_element = request.get_json()
            request_key = request_element.keys()
            request_key_number = len(request_key)
        
            if(request_key_number <= 1 or request_key_number >2):
                response["status"] = "Error: Please provide only two data keys (path and text)"
                res = ('Error: Please provide only two data keys (path and text)')
                raise Exception(res)

            if("path" in request_key and "text" in request_key):
                for k,v in request_element.items():
                    if(k == 'path'):
                        for elem in row:
                            for leaf in elem["leafs"]:
                                if(v == leaf["path"]):
                                    res = ('Path already exists')
                                    raise Exception(res)
                    new_leaf.update({k: v})
                    #row.insert_one({k: v})

                #Update row with new leaf in db (in leaf list)
                collection.update(query, {"$push": { 'leafs': new_leaf }})
                response["status"] = "Success: leaf {} created in {}".format(new_leaf, map_id)
            else:
                res = ('Error: Please provide exactly those two keys (path and text)')
                raise Exception(res)            

        return response
    
    except Exception as e:
        return str(e), 500
    

@app.route('/api/maps/<path:map_id>', methods=['GET'])
def display_tree(map_id):
    try:
        response = {}
    
        query = {"map_id": map_id}
        row = collection.find(query)

        if row.count() == 0:
            response["status"] = "Error: map_id named {} not found".format(map_id)
            res = ('Error: map_id named ' + map_id  + ' not found')
            raise Exception(res)
        else:
            for elem in row:
                all_leaf = ""
                for leaf in elem["leafs"]:
                    leaf_tab = leaf["path"].split('/')
                    
                    for i in range(len(leaf_tab)):
                        all_leaf += (i*'\t'+'/'+leaf_tab[i]+'\n')
                
                response["status"] = "Result: \n {} ".format(all_leaf)
                return response["status"]  
        return response        
    except Exception as e:
        return str(e), 500

@app.route('/api/maps/<path:map_id>/<path:path_id>', methods=['GET'])
def get_maps(map_id, path_id):
    try:
        response = {}

        query = {"map_id": map_id}
        row = collection.find(query)
    
        #Check if row is empty
        if row.count() == 0:
            response["status"] = "Error: map_id named {} not found".format(map_id)
            res = ('Error: map_id named ' + map_id  + ' not found')
            raise Exception(res)
        else: 
            for elem in row:
                for leaf in elem["leafs"]:
                    if(leaf["path"] == path_id):
                        response["status"] = "Success: leaf {} exist in {}".format(leaf, map_id)
                        return response
                    else:
                        res = ('Error: Path ' + path_id + ' not exist in ' + map_id)
                raise Exception(res)
    except Exception as e:
        return str(e), 500

@app.route('/')
@app.route('/<path:path>')
def index(path):
    help_message = """<h1>Welcome to BNC API Mind Map</h1>
<p>Please find the following API call available :</br>
        - http_request_type: POST, entry_point: localhost/api/maps, data_type: {id_map}</br>
        - http_request_type: POST, entry_point: localhost/api/maps/{id_map}, data_type: {[path, text]}, </br>
        - http_request_type: GET, entry_point: localhost/api/maps/{id_map}/{path}</br></p>"""

    return help_message


if __name__ == '__main__':
    app.run(host='0.0.0.0', port='8080')

