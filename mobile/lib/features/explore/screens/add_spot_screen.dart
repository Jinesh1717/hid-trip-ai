import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/explore_provider.dart';
import '../services/explore_service.dart';

class AddSpotScreen extends ConsumerStatefulWidget {
  const AddSpotScreen({super.key});

  @override
  ConsumerState<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends ConsumerState<AddSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _feeController = TextEditingController();
  final _hoursController = TextEditingController();
  
  bool _parkingAvailable = false;
  File? _selectedImage;
  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );
    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = ref.read(exploreServiceProvider);
      List<String> imageUrls = [];

      if (_selectedImage != null) {
        final url = await service.uploadImage(_selectedImage!);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      final spotData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "category": _categoryController.text.trim().isEmpty ? "Uncategorized" : _categoryController.text.trim(),
        "tags": _tagsController.text.trim(),
        "latitude": _selectedLocation!.latitude,
        "longitude": _selectedLocation!.longitude,
        "opening_hours": _hoursController.text.trim(),
        "entry_fee": _feeController.text.trim(),
        "parking_available": _parkingAvailable,
        "image_urls": imageUrls,
      };

      final spot = await service.createSpot(spotData);

      if (spot != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spot created successfully!')),
        );
        Navigator.pop(context, true); // Return true to signal refresh
      } else {
        throw Exception('Failed to create spot');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Spot'),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Spot Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: 'Category (e.g. Cafe)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _feeController,
                            decoration: const InputDecoration(labelText: 'Entry Fee', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(labelText: 'Tags (comma separated)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Parking Available'),
                      value: _parkingAvailable,
                      onChanged: (val) => setState(() => _parkingAvailable = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.map),
                      label: Text(_selectedLocation == null ? 'Pick Location on Map' : 'Location Selected!'),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create Spot', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _initialLocation = const LatLng(37.7749, -122.4194); // Default to SF or could use Geolocator
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialLocation, zoom: 12),
        onTap: (location) {
          setState(() {
            _pickedLocation = location;
          });
        },
        markers: _pickedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('picked_loc'),
                  position: _pickedLocation!,
                )
              }
            : {},
      ),
    );
  }
}
