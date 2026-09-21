# LilleStreetPark — Parking Finder with Flutter

An academic mobile application for exploring parking availability
in the Lille metropolitan area.

Built with Flutter and Dart, the project combines a Google Maps
interface, device geolocation and parking data from Métropole
Européenne de Lille (MEL).

It displays parking facilities and ranks them using distance and
reported availability.

## Features

- **Interactive map:** parking markers with names and available spaces.
- **Device location:** displays the user's position with a custom marker.
- **Availability indicators:** colours reflect the number of free spaces.
- **Recommendations:** sorts parking facilities using proximity and availability.
- **Location search:** converts a searched address into coordinates
  and updates the recommendations.
- **Manual refresh:** reloads parking data from the API.
- **Session favourites:** adds parking facilities to an in-memory list.
- **Demo login:** provides access to the map through a simulated login screen.

## Recommendation logic

Recommendations use the device's location or a searched address
as their reference point.

The sorting rule is:

1. Parking facilities less than 1 km away are ordered by available
   spaces, from highest to lowest.
2. Facilities outside that radius are ordered by distance.
3. Nearby facilities appear before more distant ones.

Distances are calculated from geographical coordinates.
They represent straight-line distances, not driving distances
or journey times.

### Availability colours

| Colour | Reported free spaces |
|---|---:|
| Green | 100 or more |
| Orange | 50–99 |
| Red | Fewer than 50 |

A red marker can therefore represent a parking facility with no
available spaces. Full facilities are not filtered out.

## Data source

The application requests the MEL Open Data dataset
`disponibilite-parkings` using this endpoint:

```text
https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/disponibilite-parkings/records?limit=100
```

The implementation reads:

| Field | Usage |
|---|---|
| `id` | Parking identifier |
| `libelle` | Parking name |
| `ville` | Municipality |
| `dispo` | Reported available spaces |
| `geometry.geometry.coordinates` | Longitude and latitude |

Each request retrieves up to 100 records. Pagination is not implemented.

Data is fetched when a screen opens and when the user presses
refresh. There is no automatic polling, and displayed availability
depends on the source data's update frequency.

The dataset describes parking facilities; the application does not
identify individual vacant street spaces.

## Tech stack

| Area | Technology |
|---|---|
| Application | Flutter and Dart |
| Maps | `google_maps_flutter` |
| Device location | `location` and `geolocator` |
| Address lookup | `geocoding` |
| API requests | `http` |
| Interface | Flutter Material widgets |

The Dart SDK constraint in `pubspec.yaml` is `>=3.0.3 <4.0.0`.
The committed dependency lockfile specifies Flutter `>=3.10.0`.

These constraints do not guarantee compatibility with every newer
Flutter version: the Android project uses a legacy Gradle configuration.

## Project structure

| Path | Responsibility |
|---|---|
| `lib/login_dir/main.dart` | Main entry point, splash screen and navigation to login |
| `lib/login_dir/LoginScreen.dart` | Login interface and simulated credential check |
| `lib/login_dir/Signup.dart` | Registration interface |
| `lib/login_dir/forgotPassword.dart` | Password recovery interface |
| `lib/pages/google_map.dart` | Map, location updates, parking markers and map favourites |
| `lib/searchRecommendation.dart` | Address search, ranking and recommendation favourites |
| `assets/` | Images, logo and marker assets |
| `android/` | Android application configuration |
| `ios/` | iOS application configuration |
| `rapport_app_SEKKOUMI_Samir.pdf` | Academic project report |

## Local setup — Android

### 1. Prerequisites

- Flutter SDK with a compatible Dart SDK.
- Android development tools and SDK.
- An Android emulator with Google APIs or a physical device.
- A Google Cloud project configured for Maps SDK for Android.
- Internet access and device location enabled.

Check the development environment:

```bash
flutter doctor
```

The committed Android configuration uses `compileSdkVersion 33`
and `minSdkVersion 21`.

### 2. Clone the repository

```bash
git clone https://github.com/S3kk0um1/LilleStreetPark.git
cd LilleStreetPark
flutter pub get
```

The internal Flutter package name is currently `introduction`.

### 3. Configure Google Maps

Follow the Google Maps setup instructions to enable the required
service, configure billing and create an API key.

In `android/app/src/main/AndroidManifest.xml`, replace the
`YOUR_KEY_HERE` placeholder in the existing entry:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_KEY_HERE" />
```

Restrict the key to the intended Android application and API.

`lib/consts.dart` also contains a key placeholder, but the current
application does not import or use that constant.

### 4. Run the application

```bash
flutter run -t lib/login_dir/main.dart
```

The explicit entry point is required because the application starts
from `lib/login_dir/main.dart`.

Allow location access when prompted.

### 5. Sign in to the demo

The login screen checks these fixed demonstration values:

| Field | Value |
|---|---|
| Email | `123` |
| Password | `123` |

No authentication server or user database is involved.

## Using the application

1. Sign in to open the map.
2. Select a parking marker to view its name and available spaces.
3. Tap its information window to access **Add to Favorites**.
4. Open the heart icon in the map toolbar to view favourites.
5. Swipe a map favourite to remove it.
6. Use the arrow in the toolbar to open recommendations.
7. Search for an address to change the ranking's reference location.
8. Use the restore-location button to return to the device's position.

The map and recommendation screens currently maintain separate
favourites lists.

## Current limitations

- **Temporary favourites:** favourites are stored in memory, are not
  synchronised between screens and are lost when their state is recreated.
  Their availability values are snapshots.
- **Demonstration account screens:** registration does not create users,
  password recovery does not send emails, and “Remember me” does not
  persist a session.
- **Basic error handling:** network, geocoding and location failures
  have limited user feedback and can leave a loading screen visible.
- **No routing or reservations:** the application does not calculate
  driving routes, reserve spaces or process payments.
- **Platform setup remains incomplete:** iOS requires review of its
  Maps key and location permission configuration. Generated platform
  folders do not establish that all platforms are supported.
- **Release configuration needs review:** the main Android manifest
  does not declare the Internet permission; it is present in the
  development manifests.

## Tests

`test/widget_test.dart` contains the default Flutter counter test.
Its assertions do not match the application's current interface.

There are currently no automated tests covering parking data,
recommendation ordering, geolocation or favourites.

## Learning outcomes

This project provided practice in:

- Building mobile interfaces and navigating between screens.
- Consuming an external JSON API with asynchronous HTTP requests.
- Displaying geographical data on a map.
- Working with device location and address geocoding.
- Implementing a distance-based sorting rule.
- Managing widget state and in-memory collections.

## Author and report

Developed by **Samir Sekkoumi** as an academic mobile application project.

See the [project report](rapport_app_SEKKOUMI_Samir.pdf)
for additional context.
