# LilleStreetPark – Parking Recommendation Mobile Application

## Abstract

LilleStreetPark is a mobile application developed using Flutter that aims to assist drivers in locating available public parking spaces within the Lille metropolitan area. By combining real-time open data from Lille Métropole with geolocation services and Google Maps, the application seeks to reduce the time spent searching for parking and improve urban mobility.

---

## Objectives

The main objectives of this project are:
- To visualize real-time parking availability on an interactive map
- To recommend parkings based on distance and number of available spaces
- To provide a user-friendly mobile interface for parking search and navigation
- To demonstrate the integration of open data and location-based services in a mobile application

---

## Main Functionalities

The application displays public parking facilities on a Google Map along with the user’s current position. Parking markers are color-coded according to availability levels: green for high availability, orange for medium availability, and red for low availability. Users can view parking details by selecting markers on the map.

A recommendation system ranks parkings based on proximity and availability. Parkings within one kilometer are prioritized by the number of free spaces, while more distant parkings are ranked by distance. Users may also search for a specific location to update recommendations accordingly.

A favorites feature allows users to save frequently used parkings. The application includes authentication-related interfaces (login, signup, password recovery), implemented for demonstration purposes with hardcoded credentials.

---

## Technical Environment

The application is developed using Flutter and the Dart programming language. Google Maps integration is achieved through the `google_maps_flutter` package. Device location is managed using `geolocator` and `location`, while HTTP requests are handled using the `http` package.

---

## Data Source

Parking data is obtained from Lille Métropole OpenData (MEL), using the dataset `disponibilite-parkings`. Data is retrieved through the official MEL API to ensure up-to-date parking availability.

---

## Application Structure

The main entry point of the application is:
lib/login_dir/main.dart

Key components include the map interface and the recommendation logic, located respectively in:
- lib/pages/google_map.dart
- lib/searchRecommendation.dart

---

## Google Maps API Key

This project does not include a Google Maps API key. To run the application, users must provide their own key obtained from Google Cloud Console and enable the Maps SDK for Android.

The API key must be added to:
android/app/src/main/AndroidManifest.xml

And in :
lib/consts.dart

---

## Installation and Execution

The project requires the Flutter SDK and an Android development environment.

To install dependencies:
flutter pub get

To run the application:
flutter run -t lib/login_dir/main.dart

---

## Author

This project was developed by **Samir Sekkoumi** as an academic mobile application project.  
Additional details are available in the accompanying report: `rapport_app_SEKKOUMI_Samir.pdf`.


