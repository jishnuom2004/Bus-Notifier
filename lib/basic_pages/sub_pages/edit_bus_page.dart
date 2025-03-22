import 'package:flutter/material.dart';
import '../../Utility/sqlite_storage.dart';

class EditBusPage extends StatefulWidget {
  final Map<String, dynamic> busDetail;

  const EditBusPage({Key? key, required this.busDetail}) : super(key: key);

  @override
  State<EditBusPage> createState() => _EditBusPageState();
}

class _EditBusPageState extends State<EditBusPage> {
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final TextEditingController _busStopController = TextEditingController();
  final TextEditingController _busNameController = TextEditingController();
  final TextEditingController _busTimeFromController = TextEditingController();
  final TextEditingController _busTimeTillController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _loadData();
    _busStopController.text = widget.busDetail['busStop'];
    _busNameController.text = widget.busDetail['busName'];
    _busTimeFromController.text = widget.busDetail['busTimeFrom'];
    _busTimeTillController.text = widget.busDetail['busTimeTill'];

    // Initialize selected days
    final List<String> days = List<String>.from(widget.busDetail['days']);
    for (int i = 0; i < _days.length; i++) {
      if (days.contains(_days[i])) {
        _selectedDays[i] = true;
      }
    }
  }

  Future<void> _loadData() async {
    _busNames = await SqliteStorage.getBusNames();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bus Details'),
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
            // Bus Stop (Read-Only)
            TextField(
              controller: _busStopController,
              enabled: false, // Make it read-only
              decoration: InputDecoration(
                labelText: 'Bus Stop',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16.0),

            // Bus Name
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _busNames.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _busNameController.text = selection,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                // Set the initial value of the text field
                textEditingController.text = _busNameController.text; // Add this line

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Bus Name',
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

            // Time From
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _busTimes.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _busTimeFromController.text = selection,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                // Set the initial value of the text field
                textEditingController.text = _busTimeFromController.text; // Add this line

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Time From',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),

            // Time Till
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _busTimes.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) => _busTimeTillController.text = selection,
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                // Set the initial value of the text field
                textEditingController.text = _busTimeTillController.text; // Add this line

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Time Till',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1.0), borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => textEditingController.clear()),
                  ),
                );
              },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel and go back
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validate the fields
                    if (_busNameController.text.isEmpty ||
                        _busTimeFromController.text.isEmpty ||
                        _busTimeTillController.text.isEmpty ||
                        _selectedDays.every((element) => element == false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in all fields')),
                      );
                      return; // Prevent saving if any field is empty
                    }
                    // Save the edited details
                    final selectedDays = _days.asMap().entries.where((entry) => _selectedDays[entry.key]).map((entry) => entry.value).toList();

                    final updatedBusDetail = {
                      'id': widget.busDetail['id'], // Keep the original ID
                      'busStop': widget.busDetail['busStop'], // Bus stop is not editable
                      'busName': _busNameController.text,
                      'busTimeFrom': _busTimeFromController.text,
                      'busTimeTill': _busTimeTillController.text,
                      'days': selectedDays,
                    };

                    // Update the bus detail in the database
                    await SqliteStorage.updateBusDetail(updatedBusDetail);

                    Navigator.pop(context, true); // Go back to HomePage and signal data change
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}