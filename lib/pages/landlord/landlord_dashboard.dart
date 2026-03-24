import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/listing_model.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../services/listing_image_service.dart';
import '../../services/message_service.dart';
import '../../services/inquiry_service.dart';
import '../login_page.dart';

class LandlordDashboard extends StatefulWidget {
  final UserProfile profile;

  const LandlordDashboard({super.key, required this.profile});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _LandlordHomeTab(profile: widget.profile),
      _LandlordListingsTab(landlordId: widget.profile.id),
      _LandlordMessagesTab(landlordId: widget.profile.id),
      _LandlordProfileTab(profile: widget.profile, onSignOut: _handleSignOut),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined),
            activeIcon: Icon(Icons.home_work),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _LandlordHomeTab extends StatefulWidget {
  final UserProfile profile;

  const _LandlordHomeTab({required this.profile});

  @override
  State<_LandlordHomeTab> createState() => _LandlordHomeTabState();
}

class _LandlordHomeTabState extends State<_LandlordHomeTab> {
  final ListingService _listingService = ListingService();
  final MessageService _messageService = MessageService();
  final InquiryService _inquiryService = InquiryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.apartment)),
              title: Text('Welcome, ${widget.profile.fullName ?? "Landlord"}'),
              subtitle: const Text('Manage your properties and tenant leads.'),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<int>(
            future: _listingService
                .getLandlordListings(widget.profile.id)
                .then((l) => l.length),
            builder: (context, snapshot) {
              return _metricCard(
                context,
                'Active Listings',
                snapshot.data?.toString() ?? '0',
                Icons.home_work,
                snapshot.connectionState == ConnectionState.waiting,
              );
            },
          ),
          FutureBuilder<int>(
            future: _messageService.getUnreadMessageCount(widget.profile.id),
            builder: (context, snapshot) {
              return _metricCard(
                context,
                'Unread Messages',
                snapshot.data?.toString() ?? '0',
                Icons.mark_chat_unread,
                snapshot.connectionState == ConnectionState.waiting,
              );
            },
          ),
          FutureBuilder<int>(
            future: _inquiryService.getPendingInquiriesCount(widget.profile.id),
            builder: (context, snapshot) {
              return _metricCard(
                context,
                'Pending Inquiries',
                snapshot.data?.toString() ?? '0',
                Icons.trending_up,
                snapshot.connectionState == ConnectionState.waiting,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isLoading,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}

class _LandlordListingsTab extends StatefulWidget {
  final String landlordId;

  const _LandlordListingsTab({required this.landlordId});

  @override
  State<_LandlordListingsTab> createState() => _LandlordListingsTabState();
}

class _LandlordListingsTabState extends State<_LandlordListingsTab> {
  final ListingService _listingService = ListingService();
  final ListingImageService _imageService = ListingImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: FutureBuilder<List<Listing>>(
        future: _listingService.getLandlordListings(widget.landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final listings = snapshot.data ?? [];

          if (listings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 90,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No listings yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first listing to start receiving tenant inquiries.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return _buildListingCard(listing);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateListingDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final roomIcon = _getRoomTypeIcon(listing.roomType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Container(
            height: 150,
            color: Colors.grey[300],
            child: Center(
              child: Icon(roomIcon, size: 50, color: Colors.grey[400]),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
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
                          const SizedBox(height: 4),
                          Text(
                            listing.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(listing.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        listing.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bed, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      listing.roomType.displayName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.price}/month',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEditListingDialog(context, listing);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _deleteListingConfirm(listing);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateListingDialog(BuildContext context) {
    _showListingFormDialog(context, isEdit: false);
  }

  void _showEditListingDialog(BuildContext context, Listing listing) {
    _showListingFormDialog(context, isEdit: true, listing: listing);
  }

  void _showListingFormDialog(
    BuildContext context, {
    required bool isEdit,
    Listing? listing,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _ListingFormDialog(
            isEdit: isEdit,
            listing: listing,
            landlordId: widget.landlordId,
            onSave: () {
              setState(() {});
              Navigator.pop(context);
            },
          ),
    );
  }

  void _deleteListingConfirm(Listing listing) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Listing'),
            content: Text(
              'Are you sure you want to delete "${listing.address}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _listingService.deleteListing(listing.id);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listing deleted')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return Colors.green;
      case ListingStatus.rented:
        return Colors.blue;
      case ListingStatus.inactive:
        return Colors.grey;
    }
  }
}

class _LandlordMessagesTab extends StatefulWidget {
  final String landlordId;

  const _LandlordMessagesTab({required this.landlordId});

  @override
  State<_LandlordMessagesTab> createState() => _LandlordMessagesTabState();
}

class _LandlordMessagesTabState extends State<_LandlordMessagesTab> {
  final MessageService _messageService = MessageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Messages')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _messageService.getConversations(widget.landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 90,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Messages from interested tenants will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _buildConversationTile(conversation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    final tenantId = conversation['user_id'] as String;
    final lastMessage = conversation['last_message'] as String? ?? '';
    final lastMessageTime = conversation['last_message_time'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(tenantId.substring(0, 1).toUpperCase()),
        ),
        title: const Text('Tenant'),
        subtitle: Text(
          lastMessage.length > 40
              ? '${lastMessage.substring(0, 40)}...'
              : lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTime(DateTime.parse(lastMessageTime)),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat detail view coming in Step 5')),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

class _LandlordProfileTab extends StatefulWidget {
  final UserProfile profile;
  final Future<void> Function() onSignOut;

  const _LandlordProfileTab({required this.profile, required this.onSignOut});

  @override
  State<_LandlordProfileTab> createState() => _LandlordProfileTabState();
}

class _LandlordProfileTabState extends State<_LandlordProfileTab> {
  late TextEditingController _fullNameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.profile.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _fullNameController.text = widget.profile.fullName ?? '';
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      _fullNameController.text.isNotEmpty
                          ? _fullNameController.text[0].toUpperCase()
                          : 'L',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    Text(
                      widget.profile.fullName ?? 'Landlord',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.profile.email,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ] else ...[
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.profile.email,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Profile updated (demo only - not saved)',
                            ),
                          ),
                        );
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: const Text('Save Profile'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Role'),
              subtitle: Text(widget.profile.role.displayName),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await widget.onSignOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for creating or editing listings
class _ListingFormDialog extends StatefulWidget {
  final bool isEdit;
  final Listing? listing;
  final String landlordId;
  final VoidCallback onSave;

  const _ListingFormDialog({
    required this.isEdit,
    this.listing,
    required this.landlordId,
    required this.onSave,
  });

  @override
  State<_ListingFormDialog> createState() => _ListingFormDialogState();
}

class _ListingFormDialogState extends State<_ListingFormDialog> {
  final ListingService _listingService = ListingService();
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _selectedCity;
  late String _selectedRoomType;
  late String _imageLinkController;
  bool _isLoading = false;

  final List<String> _cities = [
    'Manila',
    'Quezon City',
    'Makati',
    'Taguig',
    'Pasig',
    'Caloocan',
    'Cebu City',
    'Davao City',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.listing != null) {
      _addressController = TextEditingController(text: widget.listing!.address);
      _priceController = TextEditingController(
        text: widget.listing!.price.toString(),
      );
      _descriptionController = TextEditingController(
        text: widget.listing!.description ?? '',
      );
      _selectedCity = widget.listing!.city;
      _selectedRoomType = widget.listing!.roomType.name;
      _imageLinkController = '';
    } else {
      _addressController = TextEditingController();
      _priceController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedCity = _cities.first;
      _selectedRoomType = 'room';
      _imageLinkController = '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Listing' : 'Create New Listing'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'e.g., 123 Main Street',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'City'),
              items:
                  _cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRoomType,
              decoration: const InputDecoration(labelText: 'Room Type'),
              items:
                  ['bedspace', 'room', 'apartment', 'studio'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(RoomType.fromString(type).displayName),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoomType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (₱/month)',
                hintText: 'e.g., 5000',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Tell tenants about your property...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(widget.isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (_addressController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final price = int.parse(_priceController.text);

      if (widget.isEdit && widget.listing != null) {
        await _listingService.updateListing(
          widget.listing!.id,
          address: _addressController.text,
          city: _selectedCity,
          price: price,
          roomType: _selectedRoomType,
          description: _descriptionController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Listing updated!')));
        }
      } else {
        await _listingService.createListing(
          landlordId: widget.landlordId,
          address: _addressController.text,
          city: _selectedCity,
          price: price,
          roomType: _selectedRoomType,
          description: _descriptionController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Listing created!')));
        }
      }

      if (mounted) {
        widget.onSave();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
