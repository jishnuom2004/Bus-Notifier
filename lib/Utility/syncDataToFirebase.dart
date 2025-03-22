import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Utility/sqlite_storage.dart'; // Import SqliteStorage

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
      print("Syncing ${busDetails.length} bus details to Firebase"); // Add logging

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
        print("Synced bus detail: ${busDetail['busName']} - ${busDetail['busStop']}"); // Add logging

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