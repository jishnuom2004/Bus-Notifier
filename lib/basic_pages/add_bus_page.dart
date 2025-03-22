import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Utility/sqlite_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utility/syncDataToFirebase.dart';

class AddBusPage extends StatefulWidget {
  const AddBusPage({Key? key}) : super(key: key);

  @override
  State<AddBusPage> createState() => _AddBusPageState();
}

class _AddBusPageState extends State<AddBusPage> {
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final TextEditingController _busStopController = TextEditingController();
  final TextEditingController _busNameController = TextEditingController();
  final TextEditingController _busTimeFromController = TextEditingController();
  final TextEditingController _busTimeTillController = TextEditingController();

  List<String> _busStops = [];
  List<String> _busNames = [];
  final List<String> _busTimes = [
  '12:00 AM', '12:15 AM', '12:30 AM', '12:45 AM',
  '1:00 AM', '1:15 AM', '1:30 AM', '1:45 AM',
  '2:00 AM', '2:15 AM', '2:30 AM', '2:45 AM',
  '3:00 AM', '3:15 AM', '3:30 AM', '3:45 AM',
  '4:00 AM', '4:15 AM', '4:30 AM', '4:45 AM',
  '5:00 AM', '5:15 AM', '5:30 AM', '5:45 AM',
  '6:00 AM', '6:15 AM', '6:30 AM', '6:45 AM',
  '7:00 AM', '7:15 AM', '7:30 AM', '7:45 AM',
  '8:00 AM', '8:15 AM', '8:30 AM', '8:45 AM',
  '9:00 AM', '9:15 AM', '9:30 AM', '9:45 AM',
  '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM',
  '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
  '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM',
  '1:00 PM', '1:15 PM', '1:30 PM', '1:45 PM',
  '2:00 PM', '2:15 PM', '2:30 PM', '2:45 PM',
  '3:00 PM', '3:15 PM', '3:30 PM', '3:45 PM',
  '4:00 PM', '4:15 PM', '4:30 PM', '4:45 PM',
  '5:00 PM', '5:15 PM', '5:30 PM', '5:45 PM',
  '6:00 PM', '6:15 PM', '6:30 PM', '6:45 PM',
  '7:00 PM', '7:15 PM', '7:30 PM', '7:45 PM',
  '8:00 PM', '8:15 PM', '8:30 PM', '8:45 PM',
  '9:00 PM', '9:15 PM', '9:30 PM', '9:45 PM',
  '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM',
  '11:00 PM', '11:15 PM', '11:30 PM', '11:45 PM',
];
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    
  }

  Future<void> _loadData() async {
    await _fetchBusStopsAndNamesFromFirebase();
    await _loadBusStopsAndNamesFromSQLite();
  }

  Future<void> _fetchBusStopsAndNamesFromFirebase() async {
  try {
    // Fetch bus stops from Firebase
    QuerySnapshot busStopsSnapshot = await FirebaseFirestore.instance.collection('busRoutes').get();
    for (var doc in busStopsSnapshot.docs) {
      try {
        // Get the stop name from the 'stops' field
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('stops')) {
          final stops = data['stops'];
          if (stops is Map<String, dynamic>) { // Check if 'stops' is a Map
            if (stops.containsKey('name')) {
              final stopName = stops['name'] as String?;
              if (stopName != null) {
                await SqliteStorage.insertBusStop(stopName);
              } else {
                print("Warning: stopName is null for document ${doc.id}");
              }
            } else {
              print("Warning: 'stops' map is missing 'name' field for document ${doc.id}");
            }
          } else if (stops is String) {
            // If 'stops' is a String, use it as the stop name
            await SqliteStorage.insertBusStop(stops);
          } else if (stops is List) {
            // If 'stops' is a List, process each item in the list
            for (var stop in stops) {
              if (stop is Map<String, dynamic>) {
                 if (stop.containsKey('name')){
                    final stopName = stop['name'] as String?;
                    if (stopName != null){
                      await SqliteStorage.insertBusStop(stopName);
                    } else {
                      print("Warning: stopName is null for document ${doc.id}");
                    }
                 } else {
                   print("Warning: 'name' key is missing in stop map for document ${doc.id}");
                 }
              }
              else {
                print("Warning: Invalid stop type in list for document ${doc.id}");
              }
            }
          }
           else {
            print("Warning: 'stops' is not a Map or String or List for document ${doc.id}");
          }
        } else {
          print("Warning: 'stops' field is missing for document ${doc.id}");
        }
      } catch (e) {
        print("Error processing bus stop data for document ${doc.id}: $e");
      }
    }

    // Fetch bus names from Firebase
    QuerySnapshot busNamesSnapshot = await FirebaseFirestore.instance.collection('busRoutes').get();
    for (var doc in busNamesSnapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('buses')) {
          final busList = data['buses'];
          if (busList is List) {
            for (var busName in busList) {
              if (busName is String) {
                await SqliteStorage.insertBusName(busName);
              } else {
                print("Warning: Invalid bus name type: ${busName.runtimeType} for document ${doc.id}");
              }
            }
          } else {
            print("Warning: 'buses' is not a List for document ${doc.id}");
          }
        } else {
          print("Warning: 'buses' field is missing for document ${doc.id}");
        }
      } catch (e) {
        print("Error processing bus name data for document ${doc.id}: $e");
      }
    }
  } catch (e) {
    print("Error fetching data from Firebase: $e");
  }
}

  Future<void> _loadBusStopsAndNamesFromSQLite() async {
    _busStops = await SqliteStorage.getBusStops();
    _busNames = await SqliteStorage.getBusNames();
    setState(() {});
  }

  Future<bool> isConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}
  Future<void> syncDataToFirebase() async {
  if (await isConnected()) {
    try {
      // Get the current user's email address
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in. Cannot sync data.");
        return;
      }
      final userEmail = user.email;

      // Get all bus details from SQLite
      List<Map<String, dynamic>> busDetails = await SqliteStorage.getBusDetails();

      // Loop through each bus detail and upload it to Firebase
      for (var busDetail in busDetails) {
        // Create a Firebase document in the user's collection
        await FirebaseFirestore.instance
            .collection(userEmail!) // Use user's email as collection name
            .add({
          'stopName': busDetail['busStop'],
          'busName': busDetail['busName'],
          'timeFrom': busDetail['busTimeFrom'],
          'timeTill': busDetail['busTimeTill'],
          'repeat': busDetail['days'],
        });

        // Optionally, delete the data from SQLite after successful sync
        // await SqliteStorage.deleteBusDetail(busDetail['id']);
      }

      print("Data synced to Firebase successfully!");
    } catch (e) {
      print("Error syncing data to Firebase: $e");
    }
  } else {
    print("No internet connection. Data will be synced when online.");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bus Details'),
      backgroundColor: Colors.blue, // Customize app bar color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _busStops.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _busStopController.text = selection,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Enter Bus Stop Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _busNames.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _busNameController.text = selection,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Enter Bus Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.directions_bus),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _busTimes.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) => _busTimeFromController.text = selection,
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _busTimes.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) => _busTimeTillController.text = selection,
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Till',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                          prefixIcon: const Icon(Icons.access_time),
                          suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Repeat', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: List<Widget>.generate(
                _days.length,
                (int index) => ChoiceChip(
                  label: Text(_days[index]),
                  selected: _selectedDays[index],
                  onSelected: (bool selected) => setState(() => _selectedDays[index] = selected),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_busStopController.text.isEmpty ||
                      _busNameController.text.isEmpty ||
                      _busTimeFromController.text.isEmpty ||
                      _busTimeTillController.text.isEmpty ||
                      _selectedDays.every((element) => element == false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return; // Prevent adding if any field is empty
                  }
                  final selectedDays = _days.asMap().entries.where((entry) => _selectedDays[entry.key]).map((entry) => entry.value).toList();

                  final Map<String, dynamic> busDetails = { // Define busDetails here
                    'busStop': _busStopController.text,
                    'busName': _busNameController.text,
                    'busTimeFrom': _busTimeFromController.text,
                    'busTimeTill': _busTimeTillController.text,
                    'days': selectedDays,
                  };


                   try {
                    await SqliteStorage.insertBusDetail(busDetails);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bus details added')),
                    );
                    // Clear the fields after successful insertion
                    _busStopController.clear();
                    _busNameController.clear();
                    _busTimeFromController.clear();
                    _busTimeTillController.clear();
                    setState(() {
                      _selectedDays.fillRange(0, _selectedDays.length, false);
                  });

                    if (FirebaseAuth.instance.currentUser != null) {
                      await syncDataToFirebase(); // CALL THIS HERE
                    } else {
                      print("User not logged in.  Cannot sync to Firebase.");
                    }

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Duplicate entry found')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}