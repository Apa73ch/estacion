import json
import logging
import asyncio
import paho.mqtt.client as mqtt
from pymongo import MongoClient
from estacion import WeatherStation

weather_stations = [
    WeatherStation('estacion_1'),
    WeatherStation('estacion_2'),
    WeatherStation('estacion_3')
]
#192.168.100.156
# Reemplaza 'mongodb://localhost:27017/' con tu cadena de conexión si es diferente
uri = "mongodb://192.168.100.156:27017/"
client = MongoClient(uri)
db = client.db
collection = db.lectura

#result = collection.delete_many({})
#print(f"Documentos eliminados: {result.deleted_count}")

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def on_message(client, userdata, message):
    try:
        payload = json.loads(message.payload.decode('utf-8'))
    except json.JSONDecodeError :
        logging.error(f"Error al decodificar el JSON en el tema: {message.topic}")

        return

    try:
        collection.insert_one(json.loads(message.payload))
      #  notify_clients(json.loads(message.payload))
        logging.info("Mensaje recibido y guardado correctamente en MongoDB")
    except Exception :
        logging.error(f"Error en la inserción en MongoDB: {e}")


def mqtt_server():
    mqtt_client = mqtt.Client(protocol=mqtt.MQTTv311)
    mqtt_client.on_message = on_message

    try:
        mqtt_client.connect("test.mosquitto.org", 1883, 60)
        for station in weather_stations:
            mqtt_client.subscribe(f"/estacion/{station.station_id}/sensores")
        mqtt_client.loop_forever()
    except OSError as e:
        logging.error(f"Error en la conexión MQTT: {e}")

if __name__ == '__main__':
    asyncio.run(mqtt_server())