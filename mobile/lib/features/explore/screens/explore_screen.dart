import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/explore_provider.dart';
import 'add_spot_screen.dart';
import 'spot_detail_screen.dart';
import '../models/spot.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showMap = false;
  GoogleMapController? _mapController;
  Spot? _selectedMapSpot;

  final List<String> _categories = ['Nature', 'Cafe', 'Historic', 'Viewpoint'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(exploreSearchQueryProvider.notifier).updateQuery(query);
  }

  void _onCategorySelected(String category) {
    final currentCategory = ref.read(exploreCategoryFilterProvider);
    if (currentCategory == category) {
      ref.read(exploreCategoryFilterProvider.notifier).updateCategory(null); // deselect
    } else {
      ref.read(exploreCategoryFilterProvider.notifier).updateCategory(category);
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Advanced Filters', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final parking = ref.watch(exploreParkingFilterProvider);
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Parking Available'),
                    value: parking,
                    onChanged: (val) {
                      ref.read(exploreParkingFilterProvider.notifier).toggle(val);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Apply Filters'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final spotsAsyncValue = ref.watch(exploreSpotsProvider);
    final selectedCategory = ref.watch(exploreCategoryFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Spot',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddSpotScreen()),
              );
              if (result == true) {
                ref.invalidate(exploreSpotsProvider);
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primaryContainer.withOpacity(0.3), theme.colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Search Bar (Glassmorphism style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: const InputDecoration(
                                  hintText: 'Search destinations...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: _showAdvancedFilters,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _onCategorySelected(category),
                          selectedColor: theme.colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    },
                  ),
                ),
                
                // Toggle Map/List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Map View', style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: _showMap,
                        onChanged: (value) => setState(() => _showMap = value),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: spotsAsyncValue.when(
                    data: (spots) {
                      if (spots.isEmpty) {
                        return const Center(child: Text('No spots found.'));
                      }

                      if (_showMap) {
                        Set<Marker> markers = spots.map((spot) {
                          return Marker(
                            markerId: MarkerId(spot.id.toString()),
                            position: LatLng(spot.latitude, spot.longitude),
                            onTap: () {
                              setState(() {
                                _selectedMapSpot = spot;
                              });
                            },
                          );
                        }).toSet();

                        return Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(spots.first.latitude, spots.first.longitude),
                                zoom: 12,
                              ),
                              markers: markers,
                              onMapCreated: (controller) {
                                _mapController = controller;
                                // Can apply dark style here if needed based on theme
                              },
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                            ),
                            if (_selectedMapSpot != null)
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SpotDetailScreen(spot: _selectedMapSpot!)),
                                    );
                                  },
                                  child: Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[300],
                                              image: _selectedMapSpot!.images.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(_selectedMapSpot!.images.first.imageUrl),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: _selectedMapSpot!.images.isEmpty ? const Icon(Icons.image) : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(_selectedMapSpot!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                Text(_selectedMapSpot!.category, style: TextStyle(color: theme.colorScheme.primary)),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        );
                      } else {
                        // List View
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: spots.length,
                          itemBuilder: (context, index) {
                            final spot = spots[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SpotDetailScreen(spot: spot)),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image Header
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        color: Colors.grey[300],
                                        image: spot.images.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(spot.images.first.imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: spot.images.isEmpty
                                          ? const Center(child: Icon(Icons.landscape, size: 40, color: Colors.white))
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  spot.name,
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  spot.category,
                                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios, size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
