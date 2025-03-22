import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RouteDetailsPage extends StatefulWidget {
  final String route;

  RouteDetailsPage({super.key, required this.route});

  @override
  State<RouteDetailsPage> createState() => _RouteDetailsPageState();
}

class _RouteDetailsPageState extends State<RouteDetailsPage> {
  final DraggableScrollableController _scrollableController = DraggableScrollableController();
  int? selectedIndex;
  List<Stop> _stops = [];
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _loadStopsFromFirestore();
  }

  Future<void> _loadStopsFromFirestore() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('busRoutes')
          .doc(widget.route) // Use route as document ID
          .get();

      if (!doc.exists) {
        print("Route not found.");
        return;
      }

      List<dynamic> stopsData = doc.get('stops');

      setState(() {
        _stops = stopsData.map((stop) => Stop.fromJson(stop)).toList();
        _drawPolyline();
      });
    } catch (e) {
      print("Error loading stops from Firestore: $e");
    }
  }

  void _drawPolyline() {
    List<LatLng> routePoints = _stops.map((stop) => LatLng(stop.latitude, stop.longitude)).toList();

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(widget.route),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void _centerMapOnStop(Stop stop) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(stop.latitude, stop.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Map Container
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(10.8505, 76.2711), // Replace with the initial position of the route
                zoom: 10.0,
              ),
              markers: _createMarkers(), // Add markers for the stops
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                _applyDarkMapStyle();
              },
            ),
          ),
          // DraggableScrollableSheet for Stops List
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.1, 0.4, 0.9],
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                        child: Text(
                          widget.route,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stops.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selectedIndex == index ? Colors.black : Colors.white,
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                    ),
                                    if (index != _stops.length - 1)
                                      Container(
                                        width: 2,
                                        height: 35, // line height
                                        color: Colors.black,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                      _centerMapOnStop(_stops[index]); // Center map on selected stop
                                    },
                                    child: Text(
                                      _stops[index].name,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Create markers for the stops
  Set<Marker> _createMarkers() {
    return _stops.map((stop) {
      return Marker(
        markerId: MarkerId(stop.name),
        position: LatLng(stop.latitude, stop.longitude), // Use the actual position of the stop
        infoWindow: InfoWindow(title: stop.name),
      );
    }).toSet();
  }

  Future<void> _applyDarkMapStyle() async {
    String style = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
    ''';
    _mapController.setMapStyle(style);
  }
}

class Stop {
  final String name;
  final double latitude;
  final double longitude;

  Stop({required this.name, required this.latitude, required this.longitude});

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}