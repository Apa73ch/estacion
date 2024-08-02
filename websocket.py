import asyncio
import websockets
from pymongo import MongoClient
import json
import datetime
from bson.objectid import ObjectId

client = MongoClient("mongodb://192.168.100.156:27017/")
db = client.db

async def handler(websocket, path):
    page_size = 10
    try:
        async for message in websocket:
            request = json.loads(message)
            if request['type'] == 'fetch':
                page_number = request.get('page', 1)
                skip_amount = (page_number - 1) * page_size
                
                collection = db.lectura
                total_documents = collection.count_documents({})
                documents = list(collection.find().sort('time', -1).skip(skip_amount).limit(page_size))
                documentsfivehundred = list(collection.find().sort('time', -1).limit(500)) 
                response_data = {
                    'total_count': total_documents,
                    'data': documents,
                    'data_for_stats': documentsfivehundred
                }
                await websocket.send(json.dumps(response_data, default=str))
            elif request['type'] == 'fetchLatest':
                collection = db.lectura
                documents = list(collection.find().sort('time', -1).limit(3600)) 
                response_data = {
                    'total_count': 3600,
                    'data': documents
                }
                await websocket.send(json.dumps(response_data, default=str))
            elif request['type'] == 'createStation':
                station_id = request.get('station_id')
                station_name = request.get('station_name')
                station_location = request.get('station_location')

                if not all([station_id, station_name, station_location]):
                    response_data = {'status': 'error', 'message': 'Missing parameters'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.stations
                collection.create_index('station_id', unique=True)  # Ensure station_id is unique

                station_data = {
                    'station_id': station_id,
                    'station_name': station_name,
                    'station_location': station_location,
                    'creation_date': datetime.datetime.now()
                }

                try:
                    collection.insert_one(station_data)
                    response_data = {'status': 'success', 'message': 'Station created successfully'}
                except Exception as e:
                    response_data = {'status': 'error', 'message': f'Error creating station: {e}'}

                await websocket.send(json.dumps(response_data))
            elif request['type'] == 'updateStation':
                station_id = request.get('station_id')
                station_name = request.get('station_name')
                station_location = request.get('station_location')

                if not all([station_id, station_name, station_location]):
                    response_data = {'status': 'error', 'message': 'Missing parameters'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.stations

                try:
                    result = collection.update_one(
                        {'station_id': station_id},
                        {'$set': {
                            'station_name': station_name,
                            'station_location': station_location
                        }}
                    )
                    if result.matched_count == 0:
                        response_data = {'status': 'error', 'message': 'Station not found'}
                    else:
                        response_data = {'status': 'success', 'message': 'Station updated successfully'}
                except Exception as e:
                    response_data = {'status': 'error', 'message': f'Error updating station: {e}'}

                await websocket.send(json.dumps(response_data))
            elif request['type'] == 'deleteStation':
                station_id = request.get('station_id')

                if not station_id:
                    response_data = {'status': 'error', 'message': 'Missing station_id'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.stations

                try:
                    result = collection.delete_one({'station_id': station_id})
                    if result.deleted_count == 0:
                        response_data = {'status': 'error', 'message': 'Station not found'}
                    else:
                        response_data = {'status': 'success', 'message': 'Station deleted successfully'}
                except Exception as e:
                    response_data = {'status': 'error', 'message': f'Error deleting station: {e}'}

                await websocket.send(json.dumps(response_data))
            elif request['type'] == 'getStations':
                collection = db.stations
                stations = list(collection.find())
                response_data = {
                    'status': 'success',
                    'data': stations
                }
                await websocket.send(json.dumps(response_data, default=str))
            elif request['type'] == 'test':
                await websocket.send('conexion bien')
            elif request['type'] == 'createUser':
                nombre = request.get('nombre')
                apellido = request.get('apellido')
                email = request.get('email')
                contraseña = request.get('password')
                username = request.get('username')

                if not all([nombre, apellido, email, contraseña, username]):
                    response_data = {'status': 'error', 'message': 'Faltan parámetros'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.user
                collection.create_index('username', unique=True)  # Ensure username is unique

                user_data = {
                    'nombre': nombre,
                    'apellido': apellido,
                    'email': email,
                    'password': contraseña,
                    'username': username,
                    'fecha_creacion': datetime.datetime.now()
                }

                try:
                    collection.insert_one(user_data)
                    response_data = {'status': 'success', 'message': 'User created successfully'}
                except Exception as e:
                    response_data = {'status': 'error', 'message': f'Error creating user: {e}'}

                await websocket.send(json.dumps(response_data))
            elif request['type'] == 'getUsers':
                collection = db.user
                users = list(collection.find())
                
                response_data = {
                    'status': 'success',
                    'data': users
                }
                # Usar la función default_converter para manejar datetime
                await websocket.send(json.dumps(response_data, default=str))
            elif request['type'] == 'updateUser':
                user_id = request.get('id')
                updates = request.get('updates')
                if not user_id or not updates:
                    response_data = {'status': 'error', 'message': 'Faltan parámetros'}
                    await websocket.send(json.dumps(response_data))
                    continue
                try:
                    collection = db.user
                    result = collection.update_one({'_id': ObjectId(user_id)}, {'$set': updates})
                except Exception as e:
                    response_data = {'status': 'error', 'message': f'Error updating user: {e}'}
                if result.matched_count == 0:
                    response_data = {'status': 'error', 'message': 'User not found '+user_id}
                else:
                    response_data = {'status': 'success', 'message': 'User updated successfully'}
                await websocket.send(json.dumps(response_data))    
            elif request['type'] == 'deleteUser':
                user_id = request.get('id')
                if not user_id:
                    response_data = {'status': 'error', 'message': 'Missing user_id'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.user
                result = collection.delete_one({'_id': ObjectId(user_id)})
                if result.deleted_count == 0:
                    response_data = {'status': 'error', 'message': 'User not found'}
                else:
                    response_data = {'status': 'success', 'message': 'User deleted successfully'}
                await websocket.send(json.dumps(response_data))
            elif request['type'] == 'login':
                username = request.get('username')
                password = request.get('password')
                
                if not username or not password:
                    response_data = {'status': 'error', 'message': 'Username and password are required'}
                    await websocket.send(json.dumps(response_data))
                    continue

                collection = db.user
                user = collection.find_one({'username': username})

                if user and user.get('password') == password:
                    response_data = {'status': 'success', 'authenticated': True}
                else:
                    response_data = {'status': 'success', 'authenticated': False}

                await websocket.send(json.dumps(response_data))
    except websockets.ConnectionClosed:
        print("Connection Closed")
    except Exception as e:
        print(f"Error: {e}")

async def main():
    async with websockets.serve(handler, "0.0.0.0", 8888):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
