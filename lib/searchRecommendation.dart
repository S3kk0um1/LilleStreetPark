import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MaterialApp(
    home: JsonDataScreen(),
  ));
}

class JsonDataScreen extends StatefulWidget {
  const JsonDataScreen({Key? key}) : super(key: key);

  @override
  _JsonDataScreenState createState() => _JsonDataScreenState();
}

class _JsonDataScreenState extends State<JsonDataScreen> {
  List<dynamic>? jsonData;
  Position? currentLocation;
  String searchLocation = '';
  List<MyMarker> favoriteSpots = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/disponibilite-parkings/records?limit=100'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        jsonData = data['results'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final isLocationServiceEnabled = await GeolocatorPlatform.instance.isLocationServiceEnabled();

      if (isLocationServiceEnabled) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          currentLocation = position;
        });
      } else {
        // Handle case when location service is not enabled.
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  double? calculateDistance(lat1, lon1, lat2, lon2) {
    if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    } else {
      return null;
    }
  }

  Future<void> searchAndRecommend(String locationName) async {
    try {
      final locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        final userLocation = locations.first;
        setState(() {
          currentLocation = Position(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude,
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
            timestamp: DateTime.now(),
          );
          searchLocation = locationName;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void reinitialize() {
    getCurrentLocation();
    searchLocation = '';
  }

  void addToFavorites(MyMarker marker) {
    if (!favoriteSpots.contains(marker)) {
      favoriteSpots.add(marker);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${marker.name} added to Favorites'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${marker.name} is already in Favorites'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (jsonData == null || currentLocation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Location search'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: fetchData,
            ),
          ],
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    jsonData!.sort((a, b) {
      final freeSpotsA = a['dispo'] ?? 0;
      final freeSpotsB = b['dispo'] ?? 0;
      final distanceA = calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        a['geometry']['geometry']['coordinates'][1],
        a['geometry']['geometry']['coordinates'][0],
      );

      final distanceB = calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        b['geometry']['geometry']['coordinates'][1],
        b['geometry']['geometry']['coordinates'][0],
      );

      if (distanceA != null && distanceA < 1 && distanceB != null && distanceB < 1) {
        // Sort by free spots within 1km.
        return freeSpotsB - freeSpotsA;
      } else {
        // Sort by distance for spots farther than 1km.
        return distanceA != null && distanceB != null ? distanceA.compareTo(distanceB) : 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          ),
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: reinitialize,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (searchLocation.isNotEmpty) {
                      searchAndRecommend(searchLocation);
                    }
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchLocation = value;
                });
              },
            ),
          ),
          Text(
            'Current Location: $searchLocation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: jsonData!.length,
              itemBuilder: (context, index) {
                final item = jsonData![index];
                final title = item['libelle'] ?? 'N/A';
                final ville = item['ville'] ?? 'N/A';

                final distance = calculateDistance(
                  currentLocation!.latitude,
                  currentLocation!.longitude,
                  item['geometry']['geometry']['coordinates'][1],
                  item['geometry']['geometry']['coordinates'][0],
                );

                int freeSpots = item['dispo'] ?? 0;
                Color color;

                if (freeSpots >= 100) {
                  color = Colors.green;
                } else if (freeSpots >= 50) {
                  color = Colors.orange;
                } else {
                  color = Colors.red;
                }

                return ListTile(
                  title: Text(title),
                  subtitle: Text(
                    'Ville: $ville, Distance: ${distance?.toStringAsFixed(2) ?? 'N/A'} km, Dispo: $freeSpots',
                    style: TextStyle(color: color),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () {
                      addToFavorites(MyMarker(
                        LatLng(
                          item['geometry']['geometry']['coordinates'][1],
                          item['geometry']['geometry']['coordinates'][0],
                        ),
                        item['id'],
                        title,
                        color,
                        freeSpots,
                      ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoritesPage(favoriteSpots)),
          );
        },
        child: Icon(Icons.favorite),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<MyMarker> favoriteSpots;

  FavoritesPage(this.favoriteSpots);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Spots'),
      ),
      body: ListView.builder(
        itemCount: favoriteSpots.length,
        itemBuilder: (context, index) {
          final marker = favoriteSpots[index];
          return ListTile(
            title: Text(marker.name),
            subtitle: Text('Free Places: ${marker.freePlaces}'),
          );
        },
      ),
    );
  }
}

class MyMarker {
  final LatLng position;
  final String markerId;
  final String name;
  final Color markerColor;
  final int freePlaces;

  MyMarker(this.position, this.markerId, this.name, this.markerColor, this.freePlaces);
}
