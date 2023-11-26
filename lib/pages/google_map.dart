import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../searchRecommendation.dart';

class MyMarker {
  final LatLng position;
  final String markerId;
  final String name;
  final Color markerColor;
  final int freePlaces;

  MyMarker(this.position, this.markerId, this.name, this.markerColor, this.freePlaces);
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  BitmapDescriptor customMarkerIcon = BitmapDescriptor.defaultMarker;
  bool isLoading = true;
  Set<Marker> markers = {};
  List<MyMarker> favoritesList = [];

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  static const LatLng _pGooglePlex = LatLng(50.629250, 3.057256);
  LatLng? _currentP;

  List<MyMarker> myMarkersList = [];

  double colorToHue(Color color) {
    final double hue = HSVColor.fromColor(color).hue;
    return hue;
  }

  Future<void> fetchDataAndConvert() async {
    final response = await http.get(Uri.parse('https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/disponibilite-parkings/records?limit=100'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final jsonData = data['results'];
      myMarkersList = convertJsonDataToMarkers(jsonData);
      for (MyMarker myMarker in myMarkersList) {
        markers.add(
          Marker(
            markerId: MarkerId(myMarker.markerId),
            icon: BitmapDescriptor.defaultMarkerWithHue(colorToHue(myMarker.markerColor)),
            position: myMarker.position,
            infoWindow: InfoWindow(
              title: myMarker.name,
              snippet: 'Free Places: ${myMarker.freePlaces}',
              onTap: () {
                _handleInfoWindowTap(myMarker);
              },
            ),
          ),
        );
      }
    } else {
      throw Exception('Failed to load data');
    }

    setState(() {
      isLoading = false;
    });
  }

  List<MyMarker> convertJsonDataToMarkers(List<dynamic> jsonData) {
    List<MyMarker> markersList = [];

    for (var item in jsonData) {
      List<dynamic> coordinates = item['geometry']['geometry']['coordinates'];
      double longitude = coordinates[0];
      double latitude = coordinates[1];

      String name = item['libelle'];
      String markerId = item['id'];
      int freePlaces = item['dispo'];
      Color markerColor = determineMarkerColor(freePlaces);

      markersList.add(MyMarker(
        LatLng(latitude, longitude),
        markerId,
        name,
        markerColor,
        freePlaces,
      ));
    }

    return markersList;
  }

  Color determineMarkerColor(int freePlaces) {
    if (freePlaces >= 100) {
      return Colors.green;
    } else if (freePlaces >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> refreshPage() async {
    setState(() {
      markers.clear();
      isLoading = true;
    });
    await fetchDataAndConvert();
  }

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    loadCustomMarker();
    fetchDataAndConvert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Page',
          style: TextStyle(
            color: Colors.white, // Set the text color of the app bar title
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refreshPage();
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite), // Heart icon
            onPressed: () {
              _navigateToFavorites(); // Navigate to favorites page
            },
          ),
          IconButton(
            icon: Icon(Icons.navigate_next), // You can use any icon you want
            tooltip: 'Navigate to Another Page', // Tooltip text
            onPressed: () {
              // Navigate to another page here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JsonDataScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      )
          : GoogleMap(
        onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
        initialCameraPosition: CameraPosition(
          target: _currentP ?? _pGooglePlex,
          zoom: 13,
        ),
        markers: {
          if (_currentP != null && customMarkerIcon != null)
            Marker(
              markerId: MarkerId("_currentLocation"),
              icon: customMarkerIcon!,
              position: _currentP!,
            ),
          ...markers,
        },
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
    }

    if (_permissionGranted == PermissionStatus.granted) {
      _locationController.onLocationChanged.listen((LocationData currentLocation) {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
      });
    }
  }

  void loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/car.png');
    final Uint8List byteList = byteData.buffer.asUint8List();
    customMarkerIcon = BitmapDescriptor.fromBytes(byteList);
  }

  void _handleInfoWindowTap(MyMarker myMarker) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _addToFavorites(myMarker);
              },
            ),
          ],
        );
      },
    );
  }

  void _addToFavorites(MyMarker myMarker) {
    if (!favoritesList.contains(myMarker)) {
      favoritesList.add(myMarker);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${myMarker.name} added to Favorites'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${myMarker.name} is already in Favorites'),
        ),
      );
    }
  }

  void _navigateToFavorites() {
    // Navigate to the Favorites screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritesScreen(favoritesList: favoritesList)),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final List<MyMarker> favoritesList;

  FavoritesScreen({required this.favoritesList});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: FavoritesList(favoritesList: widget.favoritesList),
    );
  }
}

class FavoritesList extends StatefulWidget {
  final List<MyMarker> favoritesList;

  FavoritesList({required this.favoritesList});

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.favoritesList.length,
      itemBuilder: (context, index) {
        MyMarker favoriteMarker = widget.favoritesList[index];
        return Dismissible(
          key: Key(favoriteMarker.markerId),
          onDismissed: (direction) {
            setState(() {
              widget.favoritesList.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${favoriteMarker.name} removed from Favorites'),
              ),
            );
          },
          background: Container(
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(favoriteMarker.name),
            subtitle: Text('Free Places: ${favoriteMarker.freePlaces}'),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
