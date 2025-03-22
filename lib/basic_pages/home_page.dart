import 'package:flutter/material.dart';

import '../Utility/sqlite_storage.dart'; 

import 'sub_pages/edit_bus_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _busDetails = [];

  @override
  void initState() {
    super.initState();
    _loadBusDetails();
  }

  Future<void> _loadBusDetails() async {
    try {
      _busDetails = await SqliteStorage.getBusDetails(); // Updated class name
      setState(() {});
    } catch (e) {
      print("Error loading bus details: $e");
      _busDetails = [];
      setState(() {});
    }
  }

  Future<void> _deleteBusDetail(int id) async {
    try {
      await SqliteStorage.deleteBusDetail(id);
      _loadBusDetails(); // Reload the data after deleting
    } catch (e) {
      print("Error deleting bus detail: $e");
      // Handle the error appropriately, e.g., show an error message
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue, // Customize app bar color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[200], // Set a background color for the whole page
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0), // Add padding around the list
        itemCount: _busDetails.length,
        itemBuilder: (context, index) {
          final busDetail = _busDetails[index];
          return Card(
            elevation: 4, // Add a shadow to the card
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0), // Adjust card margin
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Round the corners of the card
            ),
            child: Stack(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.all(16.0), // Adjust padding inside ListTile
                  title: Text(
                    busDetail['busName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stop: ${busDetail['busStop']}'),
                      Text('Time: From ${busDetail['busTimeFrom']} to ${busDetail['busTimeTill']}'),
                      Text('Days: ${(busDetail['days'] as List).join(', ')}'), // Cast to List
                    ],
                  ),
                  onTap: () async {
                    // Navigate to the EditBusPage
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBusPage(busDetail: busDetail),
                      ),
                    );

                    // If the data has been changed, reload the bus details
                    if (result == true) {
                      _loadBusDetails();
                    }
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // Style the delete icon
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: const Text("Are you sure you want to delete this bus detail?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Dismiss the dialog
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteBusDetail(busDetail['id']);
                                  Navigator.of(context).pop(); // Dismiss the dialog
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}