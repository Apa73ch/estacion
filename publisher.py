from estacion import WeatherStation

import paho.mqtt.client as mqtt
import json
import time
import logging

host="test.mosquitto.org"
port=1883

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

weather_stations = [
        WeatherStation('estacion_1'),
        WeatherStation('estacion_2'),
        WeatherStation('estacion_3')
    ]

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        logging.info("Conectado al broker MQTT")
    else:
        logging.error(f"Error de conexión: {rc}")

    
client = mqtt.Client()
client.on_connect = on_connect
client.connect(host, port, 60)

def run():
    while True:
        for station in weather_stations:
            data = station.generate_data()
            topic = f"/estacion/{station.station_id}/sensores"
            payload = json.dumps(data)
            client.publish(topic, payload)
            logging.info(f"Datos publicados en el tema: {topic}")
            time.sleep(1)
    

if __name__ == '__main__':
    run()

