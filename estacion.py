import random
from datetime import datetime

class WeatherStation:
    def __init__(self, station_id):
        self.station_id = station_id

    def generate_data(self):
        temperature = random.uniform(15, 35)  # Temperatura en grados Celsius
        humidity = random.randint(30, 80)  # Humedad en %
        atmospheric_pressure = random.uniform(990, 1030)  # Presión atmosférica en hPa
        rainfall = random.uniform(0, 50)  # Pluvialidad en mm
        wind_speed = random.uniform(0, 20)  # Velocidad del viento en km/h
        wind_direction = random.randint(0, 360)  # Dirección del viento en grados

        data = {
            'station_id': self.station_id,
            'temperature': temperature,
            'humidity': humidity,
            'atmospheric_pressure': atmospheric_pressure,
            'rainfall': rainfall,
            'wind_speed': wind_speed,
            'wind_direction': wind_direction,
            'time': datetime.now().timestamp
        }

        return data
    