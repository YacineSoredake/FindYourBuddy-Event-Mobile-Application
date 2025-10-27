// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import '../../core/constants.dart';

// class MapPickerScreen extends StatefulWidget {
//   const MapPickerScreen({super.key});

//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }

// class _MapPickerScreenState extends State<MapPickerScreen> {
//   LatLng? _selectedPosition;
//   final MapController _mapController = MapController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pick Location"),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               onTap: (tapPosition, point) {
//                 setState(() => _selectedPosition = point);
//               },
//             ),
//             children: [
//               TileLayer(
//                 // ✅ Use Leaflet + open source OSM tiles with proper user-agent
//                 urlTemplate:
//                     "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
//                 subdomains: const ['a', 'b', 'c'],
//                 userAgentPackageName: 'com.yourapp.eventapp', // your app id
//               ),
//               if (_selectedPosition != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       width: 40,
//                       height: 40,
//                       point: _selectedPosition!,
//                       builder: (ctx) => const Icon(
//                         Icons.location_pin,
//                         color: AppColors.secondary,
//                         size: 40,
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),

//           // ✅ Floating confirm button
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.secondary,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               icon: const Icon(Icons.check, color: Colors.white),
//               label: const Text(
//                 "Confirm Location",
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onPressed: _selectedPosition == null
//                   ? null
//                   : () {
//                       Navigator.pop(context, {
//                         'lat': _selectedPosition!.latitude,
//                         'lng': _selectedPosition!.longitude,
//                         'address': 'Selected Location',
//                       });
//                     },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
