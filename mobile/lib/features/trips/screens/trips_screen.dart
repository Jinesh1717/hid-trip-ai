import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_provider.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsyncValue = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      body: tripsAsyncValue.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text('No trips found. Create one!'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tripsProvider),
            child: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(trip.title),
                    subtitle: Text('${trip.destination} • ${trip.durationDays ?? '?'} days'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await ref.read(tripServiceProvider).deleteTrip(trip.id);
                          ref.invalidate(tripsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                    ),
                    onTap: () {
                      // Navigate to trip details later
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, trace) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTripDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTripDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final destController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plan New Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Trip Title (e.g. Summer Vacation)'),
              ),
              TextField(
                controller: destController,
                decoration: const InputDecoration(labelText: 'Destination (e.g. Paris)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text;
                final dest = destController.text;
                if (title.isNotEmpty && dest.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    await ref.read(tripServiceProvider).createTrip(
                      title: title, 
                      destination: dest,
                      durationDays: 3, // Mock data
                      budget: 1000.0,
                    );
                    ref.invalidate(tripsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create trip')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
