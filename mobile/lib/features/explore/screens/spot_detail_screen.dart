import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/spot.dart';

class SpotDetailScreen extends StatelessWidget {
  final Spot spot;
  const SpotDetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery Header
            SizedBox(
              height: 350,
              child: spot.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: spot.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          spot.images[index].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.white)),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.indigo.shade300,
                      child: const Center(child: Icon(Icons.landscape, size: 100, color: Colors.white)),
                    ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          spot.name,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          spot.category,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    spot.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Details Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      if (spot.entryFee != null && spot.entryFee!.isNotEmpty)
                        _DetailChip(icon: Icons.attach_money, label: spot.entryFee!),
                      if (spot.openingHours != null && spot.openingHours!.isNotEmpty)
                        _DetailChip(icon: Icons.access_time, label: spot.openingHours!),
                      if (spot.parkingAvailable)
                        const _DetailChip(icon: Icons.local_parking, label: 'Parking Available'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Tags
                  if (spot.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: spot.tags.map((t) => Chip(label: Text('#$t'))).toList(),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  Text('Location', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Interactive Map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(spot.latitude, spot.longitude),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('spot_${spot.id}'),
                            position: LatLng(spot.latitude, spot.longitude),
                          )
                        },
                        zoomControlsEnabled: false,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text('Reviews', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('No reviews yet. Be the first to review!'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
