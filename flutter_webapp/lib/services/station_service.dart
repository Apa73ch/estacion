import '../models/station.dart';

class StationService {
  final List<Station> stations = [];
  int _idCounter = 1;

  StationService() {
    _addInitialData();
  }

  void _addInitialData() {
    createStation('Estación Norte', 'Norte de la Ciudad');
    createStation('Estación Sur', 'Sur de la Ciudad');
    createStation('Estación Este', 'Este de la Ciudad');
    createStation('Estación Oeste', 'Oeste de la Ciudad');
  }

  void createStation(String name, String location) {
    var newStation = Station(
        id: (_idCounter++).toString(),
        name: name,
        location: location,
        creationDate: DateTime.now(),
        lastReadingDate: null,
        isConnected: true,
        sensors: null);
    stations.add(newStation);
  }

  List<Station> getStations() {
    return stations;
  }

  void updateStation(String id, String name, String location) {
    var station = stations.firstWhere((s) => s.id == id,
        orElse: () => Station(
            id: '0',
            name: '',
            location: '',
            creationDate: DateTime.now(),
            sensors: null,
            isConnected: true));
    if (id != '0') {
      station.name = name;
      station.location = location;
    }
  }

  void deleteStation(String id) {
    stations.removeWhere((station) => station.id == id);
  }
}
