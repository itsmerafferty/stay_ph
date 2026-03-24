import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/listing_model.dart';
import '../../services/listing_service.dart';
import '../../services/favorite_service.dart';

class TenantHomeScreen extends StatefulWidget {
  final UserProfile profile;

  const TenantHomeScreen({super.key, required this.profile});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ListingService _listingService = ListingService();
  final FavoriteService _favoriteService = FavoriteService();
  String _selectedCity = 'All Cities';
  String _selectedRoomType = 'All Types';

  final List<String> _cities = [
    'All Cities',
    'Manila',
    'Quezon City',
    'Makati',
    'Taguig',
    'Pasig',
    'Caloocan',
    'Cebu City',
    'Davao City',
  ];

  final List<String> _roomTypes = [
    'All Types',
    'Bedspace',
    'Room',
    'Apartment',
    'Studio',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Place'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement advanced filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advanced filters coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search boarding houses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),

                // Filter Chips
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            isExpanded: true,
                            icon: const Icon(Icons.location_city, size: 20),
                            items:
                                _cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRoomType,
                            isExpanded: true,
                            icon: const Icon(Icons.bed, size: 20),
                            items:
                                _roomTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoomType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Listings Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshListings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              widget.profile.fullName?[0].toUpperCase() ?? 'T',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${widget.profile.fullName ?? "Tenant"}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Let\'s find your perfect place to stay',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filtered/Search Results Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Listings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedCity != 'All Cities' ||
                          _selectedRoomType != 'All Types')
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Real Listings with FutureBuilder
                  FutureBuilder<List<Listing>>(
                    future: _getFilteredListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48),
                                const SizedBox(height: 16),
                                Text('Error: ${snapshot.error}'),
                              ],
                            ),
                          ),
                        );
                      }

                      final listings = snapshot.data ?? [];

                      if (listings.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No listings found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          ...List.generate(listings.length, (index) {
                            final listing = listings[index];
                            return Column(
                              children: [
                                _buildListingCard(listing),
                                const SizedBox(height: 12),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to map view
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Map view coming soon!')),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
      ),
    );
  }

  Future<List<Listing>> _getFilteredListings() async {
    return _listingService.searchListings(
      city: _selectedCity == 'All Cities' ? null : _selectedCity,
      roomType: _selectedRoomType == 'All Types' ? null : _selectedRoomType,
    );
  }

  Future<void> _refreshListings() async {
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = 'All Cities';
      _selectedRoomType = 'All Types';
    });
  }

  Widget _buildListingCard(Listing listing) {
    final roomIcon = _getRoomTypeIcon(listing.roomType);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Listing details: ${listing.address}')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 180,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Center(
                    child: Icon(roomIcon, size: 60, color: Colors.grey[400]),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: FutureBuilder<bool>(
                      future: _favoriteService.isFavorite(
                        widget.profile.id,
                        listing.id,
                      ),
                      builder: (context, snapshot) {
                        final isFavorite = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                          ),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () async {
                            try {
                              if (isFavorite) {
                                await _favoriteService.removeFavorite(
                                  widget.profile.id,
                                  listing.id,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from favorites'),
                                    ),
                                  );
                                }
                              } else {
                                await _favoriteService.addFavorite(
                                  widget.profile.id,
                                  listing.id,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to favorites!'),
                                    ),
                                  );
                                }
                              }
                              setState(() {});
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.address,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.city,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        listing.roomType.displayName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${listing.price}/month',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (listing.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      listing.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoomTypeIcon(RoomType roomType) {
    switch (roomType) {
      case RoomType.bedspace:
        return Icons.hotel;
      case RoomType.room:
        return Icons.bed;
      case RoomType.apartment:
        return Icons.apartment;
      case RoomType.studio:
        return Icons.home;
    }
  }
}
