# 🏠 BOARDING HOUSE FINDER PHILIPPINES - COMPLETE SYSTEM ARCHITECTURE

## 📋 TABLE OF CONTENTS
1. [System Overview](#system-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Project Structure](#project-structure)
4. [Database Schema](#database-schema)
5. [Implementation Roadmap](#implementation-roadmap)
6. [API Integration Guide](#api-integration-guide)
7. [State Management](#state-management)
8. [Authentication Flow](#authentication-flow)
9. [Feature Implementation Details](#feature-implementation-details)
10. [Performance & Security](#performance--security)
11. [Deployment Guide](#deployment-guide)

---

## SYSTEM OVERVIEW

### 🎯 Application Goals
- Enable Filipino tenants to find boarding houses, apartments, and rooms
- Empower landlords to list and manage properties
- Provide admin panel for content moderation
- Monetize through featured listings and subscriptions

### 👥 User Roles
1. **Tenant** - Searches for properties, favorites listings, messages landlords
2. **Landlord** - Creates listings, manages properties, receives inquiries
3. **Admin** - Approves listings, manages users, handles reports

### 💰 Revenue Streams
1. **Featured Listings** - ₱500-1000 per month
2. **Subscription Plans**
   - Basic: ₱99/month (5 listings)
   - Premium: ₱299/month (unlimited listings + analytics)
   - Professional: ₱699/month (all features + ads removal)
3. **Lead Unlock** - ₱50 per tenant contact
4. **AdMob Monetization** - Banner & Interstitial ads

---

## ARCHITECTURE DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                    MOBILE FRONTEND (Flutter)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Presentation Layer (Widgets/Screens)        │   │
│  │  ├─ Auth Screens (Login, Register)                 │   │
│  │  ├─ Listing Screens (Home, Details, Create)        │   │
│  │  ├─ Chat Screens (Conversations, Messages)         │   │
│  │  ├─ User Screens (Profile, Favorites, Dashboard)   │   │
│  │  └─ Map Screen (Location-based search)             │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │       State Management Layer (Riverpod)             │   │
│  │  ├─ Service Providers (Auth, Storage, etc.)         │   │
│  │  ├─ Repository Providers (Data access)              │   │
│  │  ├─ State Providers (UI state)                      │   │
│  │  └─ Computed Providers (Derived state)              │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      Repository & Service Layer (Business Logic)    │   │
│  │  ├─ UserRepository      → User CRUD operations      │   │
│  │  ├─ ListingRepository   → Listing management        │   │
│  │  ├─ MessageRepository   → Chat & messaging          │   │
│  │  ├─ AuthService         → Authentication            │   │
│  │  ├─ StorageService      → Image upload/delete       │   │
│  │  └─ PaymentService      → Payment processing        │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │        Data Models Layer (Domain Models)            │   │
│  │  ├─ UserModel                                       │   │
│  │  ├─ ListingModel                                    │   │
│  │  ├─ MessageModel                                    │   │
│  │  ├─ ReviewModel                                     │   │
│  │  ├─ PaymentModel                                    │   │
│  │  └─ AmenityModel                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE BACKEND                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐      ┌──────────────────────────┐    │
│  │ PostgreSQL DB    │  ←→  │ Realtime Engine (WebSocket)  │
│  │ (15+ tables)     │      │ (Live messaging, updates)    │
│  └──────────────────┘      └──────────────────────────┘    │
│         ↑                            ↑                      │
│         │                            │                      │
│  ┌──────────────────┐      ┌──────────────────────────┐    │
│  │ Supabase Auth    │      │ Storage (Images, Files)  │    │
│  │ (JWT + Sessions) │      │ (Listing photos, avatars)    │
│  └──────────────────┘      └──────────────────────────┘    │
│                                                              │
│  Row Level Security (RLS) enabled for all tables            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│               EXTERNAL SERVICES & APIs                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │ Google Maps API  │  │ Firebase Cloud Messaging    │    │
│  │ ├─ Maps Display  │  │ (Push notifications)        │    │
│  │ ├─ Geocoding     │  └──────────────────────────────┘    │
│  │ └─ Places Search │                                       │
│  └──────────────────┘  ┌──────────────────────────────┐    │
│                        │ PayMongo / GCash API         │    │
│  ┌──────────────────┐  │ (Payment processing)        │    │
│  │ Google AdMob     │  └──────────────────────────────┘    │
│  │ ├─ Banner ads    │                                       │
│  │ └─ Interstitials │                                       │
│  └──────────────────┘                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## PROJECT STRUCTURE

```
boarding_house_finder/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/
│   │   ├── config/
│   │   │   ├── supabase_config.dart       # Supabase initialization
│   │   │   └── app_constants.dart         # App constants & config
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── listing_model.dart
│   │   │   ├── message_model.dart
│   │   │   ├── amenity_model.dart
│   │   │   ├── review_model.dart
│   │   │   ├── payment_model.dart
│   │   │   └── notification_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── user_repository.dart
│   │   │   ├── listing_repository.dart
│   │   │   ├── message_repository.dart
│   │   │   ├── payment_repository.dart
│   │   │   ├── review_repository.dart
│   │   │   └── favorite_repository.dart
│   │   │
│   │   └── services/
│   │       ├── auth_service.dart
│   │       ├── storage_service.dart
│   │       ├── payment_service.dart
│   │       ├── notification_service.dart
│   │       ├── maps_service.dart
│   │       └── analytics_service.dart
│   │
│   ├── providers/
│   │   ├── providers.dart                 # All Riverpod providers
│   │   ├── auth_providers.dart
│   │   ├── listing_providers.dart
│   │   ├── chat_providers.dart
│   │   └── user_providers.dart
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── phone_verification_screen.dart
│   │   │   │
│   │   │   ├── home_screen.dart
│   │   │   ├── listing_details_screen.dart
│   │   │   ├── map_view_screen.dart
│   │   │   │
│   │   │   ├── listings/
│   │   │   │   ├── create_listing_screen.dart
│   │   │   │   ├── edit_listing_screen.dart
│   │   │   │   └── landlord_listings_screen.dart
│   │   │   │
│   │   │   ├── chat/
│   │   │   │   ├── conversations_screen.dart
│   │   │   │   ├── chat_detail_screen.dart
│   │   │   │   └── create_chat_screen.dart
│   │   │   │
│   │   │   ├── profile_screen.dart
│   │   │   ├── favorites_screen.dart
│   │   │   │
│   │   │   ├── payment/
│   │   │   │   ├── payment_screen.dart
│   │   │   │   └── subscription_screen.dart
│   │   │   │
│   │   │   └── admin/
│   │   │       ├── admin_dashboard_screen.dart
│   │   │       ├── pending_listings_screen.dart
│   │   │       └── user_management_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── listing_card.dart
│   │   │   ├── listing_tile.dart
│   │   │   ├── amenity_badge.dart
│   │   │   ├── rating_widget.dart
│   │   │   ├── image_gallery.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   └── custom_text_field.dart
│   │   │
│   │   └── themes/
│   │       ├── app_theme.dart
│   │       ├── colors.dart
│   │       └── text_styles.dart
│   │
│   └── utils/
│       ├── extensions.dart
│       ├── validators.dart
│       ├── formatters.dart
│       ├── constants.dart
│       └── error_handler.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
│       └── Poppins/
│
├── pubspec.yaml
├── pubspec.lock
└── analysis_options.yaml
```

---

## DATABASE SCHEMA

### Tables Overview

#### 1. **users** table
```sql
- id (UUID, PK)
- email (Unique, Not Null)
- phone
- full_name
- avatar_url
- role (tenant/landlord/admin)
- bio
- is_verified / is_banned
- created_at / updated_at / last_login
```

#### 2. **listings** table
```sql
- id (UUID, PK)
- owner_id (FK users)
- title, description
- price_per_month, price_per_day
- location_name, address, city, province
- latitude, longitude

- room_type (bedspace/room/apartment/studio)
- bedrooms, bathrooms, floor_number
- total_capacity, available_spaces

- status (pending/approved/rejected/inactive)
- is_featured, featured_until
- is_active
- average_rating, total_reviews, total_views

- created_at / updated_at
```

#### 3. **messages** table (Realtime)
```sql
- id (UUID, PK)
- sender_id (FK users)
- receiver_id (FK users)
- listing_id (FK listings, nullable)
- message_text
- is_read, read_at
- message_type (text/image/document)
- attachment_url
- created_at / updated_at
```

#### 4. **Related Tables**
- **listing_images** - Images for each listing
- **listing_amenities** - Many-to-many: listings ↔ amenities
- **reviews** - Ratings with clenliness_rating, communication_rating, value_rating
- **payments** - Track featured listing & subscription payments
- **subscriptions** - Landlord subscription plans
- **favorites** - User's saved listings
- **admin_reports** - Flag inappropriate listings
- **notifications** - Push notification records
- **analytics** - Track views, interactions, conversions

---

## IMPLEMENTATION ROADMAP

### PHASE 1: CORE INFRASTRUCTURE ✅ (COMPLETED)
- [x] Database schema design
- [x] Models creation
- [x] Repository pattern setup
- [x] Supabase configuration
- [x] Riverpod providers setup
- [x] Authentication service
- [x] Storage service

### PHASE 2: AUTHENTICATION (70% Complete)
- [x] Email/Password login
- [x] Registration flow
- [ ] OTP verification
- [ ] Forgot password
- [ ] Social login (Google, Facebook)
- [ ] Session management
- [ ] Token refresh logic

**Implementation:**
```dart
// Complete auth service in: lib/core/services/auth_service.dart
// Add OTP verification:
Future<UserModel> verifyOTP(String email, String otp) async {
  // Use Supabase .verifyOTP()
}

// Add forgot password:
Future<void> resetPassword(String email) async {
  // Use Supabase .resetPasswordForEmail()
}
```

### PHASE 3: LISTING MANAGEMENT (50% Complete)
- [x] Fetch listings with filters
- [x] Listing details view
- [ ] Create listing (with image upload)
- [ ] Edit listing
- [ ] Delete listing
- [ ] Amenity selection
- [ ] Location picker (Google Maps)

**Implementation:**
```dart
// Create listing_creation_service.dart
class ListingCreationService {
  Future<String> createListing({
    required ListingModel listing,
    required List<File> images,
    required List<int> amenityIds,
  }) async {
    // 1. Upload images to storage
    final imagePaths = await storageService.uploadMultipleImages(
      images,
      listing.id,
    );

    // 2. Create listing in database
    final listingId = await listingRepository.createListing(listing);

    // 3. Link images to listing
    for (final path in imagePaths) {
      await _linkImageToListing(listingId, path);
    }

    // 4. Add amenities
    for (final amenityId in amenityIds) {
      await listingRepository.addAmenityToListing(listingId, amenityId);
    }

    return listingId;
  }
}
```

### PHASE 4: CHAT & MESSAGING (20% Complete)
- [ ] Realtime messaging with Supabase Realtime
- [ ] Conversation list
- [ ] Message notifications
- [ ] Read receipts
- [ ] Image messages
- [ ] Message search

**Implementation:**
```dart
// Enhance message_repository.dart
Stream<Message> listenToConversationChanges(String userId) {
  return _supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('receiver_id', userId)
      .listen((List<Map<String, dynamic>> data) {
        return data.map((m) => MessageModel.fromSupabase(m));
      });
}

// In chat_detail_screen.dart
@override
Widget build(BuildContext context) {
  return StreamBuilder<List<MessageModel>>(
    stream: ref.watch(messagesStreamProvider(conversationId)),
    builder: (context, snapshot) {
      // Build chat UI
    },
  );
}
```

### PHASE 5: FAVORITES & RATINGS (10% Complete)
- [ ] Add to favorites
- [ ] Remove from favorites
- [ ] Favorites list screen
- [ ] Leave review
- [ ] View reviews
- [ ] Rating system (1-5 stars)

**Implementation:**
```dart
// Create favorite_repository.dart
class FavoriteRepository implements IFavoriteRepository {
  Future<void> addFavorite(String userId, String listingId) async {
    await _supabase.from('favorites').insert({
      'user_id': userId,
      'listing_id': listingId,
    });
  }

  Stream<List<String>> getUserFavorites(String userId) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.map((f) => f['listing_id'] as String).toList());
  }
}
```

### PHASE 6: PAYMENTS & MONETIZATION (0% Complete)
- [ ] PayMongo integration
- [ ] GCash integration
- [ ] Feature listing payment flow
- [ ] Subscription plans
- [ ] Payment history
- [ ] Invoice generation

**Implementation:**
```dart
// Create payment_service.dart
class PaymentService {
  Future<PaymentIntentResponse> createPaymentIntent({
    required double amount,
    required String paymentType,
    required String userId,
  }) async {
    final response = await _paymongo.post(
      '/payment_intents',
      data: {
        'data': {
          'attributes': {
            'amount': (amount * 100).toInt(), // Convert to centavos
            'currency': 'PHP',
            'payment_method_allowed': ['card', 'paymaya', 'gcash'],
            'metadata': {
              'user_id': userId,
              'payment_type': paymentType,
            },
          },
        },
      },
    );
    return PaymentIntentResponse.fromJson(response.data);
  }

  Future<bool> processPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    // Attach payment method to intent
    final response = await _paymongo.post(
      '/payment_intents/$paymentIntentId/attach',
      data: {
        'data': {
          'attributes': {
            'payment_method': paymentMethodId,
            'return_url': 'https://yourapp.com/payment/return',
          },
        },
      },
    );
    return response.statusCode == 200;
  }
}
```

### PHASE 7: ADMIN PANEL (0% Complete)
- [ ] Pending listings approval
- [ ] User management
- [ ] Listing reports
- [ ] Analytics dashboard
- [ ] Payment tracking
- [ ] Ban/suspend users

### PHASE 8: MAPS & LOCATION (0% Complete)
- [ ] Google Maps integration
- [ ] Show listings on map
- [ ] Location search
- [ ] Current location access
- [ ] Radius-based search

```dart
// Create map_service.dart
class MapService {
  Future<List<ListingModel>> searchListingsNearby({
    required LatLng center,
    required double radiusInKm,
  }) async {
    // Use Supabase PostGIS extension
    final response = await _supabase.rpc('listings_within_radius', params: {
      'center_lat': center.latitude,
      'center_lng': center.longitude,
      'radius_km': radiusInKm,
    });

    return (response as List)
        .map((e) => ListingModel.fromSupabase(e))
        .toList();
  }
}
```

### PHASE 9: NOTIFICATIONS (0% Complete)
- [ ] FCM integration
- [ ] New message notifications
- [ ] Listing approved notification
- [ ] Review notification
- [ ] Push notification settings

### PHASE 10: ADVANCED FEATURES (0% Complete)
- [ ] Search with filters & sorting
- [ ] Save search filters
- [ ] Contact unlock system
- [ ] AI-powered search suggestions
- [ ] Fraud detection
- [ ] Booking/reservation system

---

## API INTEGRATION GUIDE

### Supabase Setup

1. **Initialize Supabase in main.dart**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(MyApp());
}
```

2. **Environment Variables (.env)**
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
PAYMONGO_SECRET_KEY=pk_xxx
GOOGLE_MAPS_API_KEY=AIzaxxxxx
FIREBASE_PROJECT_ID=your_firebase_project
```

### PayMongo Integration

```dart
// payments/paymongo_service.dart
class PayMongoService {
  static const String baseUrl = 'https://api.paymongo.com/v1';

  Future<String> createPaymentIntent(double amount) async {
    final dio = Dio();
    dio.options.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$secretKey:'))}';

    final response = await dio.post(
      '$baseUrl/payment_intents',
      data: {
        'data': {
          'attributes': {
            'amount': (amount * 100).toInt(),
            'currency': 'PHP',
            'payment_method_allowed': ['card', 'paymaya', 'gcash'],
          },
        },
      },
    );

    return response.data['data']['id'];
  }
}
```

### Google Maps Integration

```dart
// Create lib/core/services/maps_service.dart
class MapsService {
  final GoogleMapsFlutter _mapsFlutter = GoogleMapsFlutter(
    apiKey: Platform.isAndroid
      ? 'ANDROID_API_KEY'
      : 'IOS_API_KEY'
  );

  Future<PlacePrediction> getPlacePredictions(String input) async {
    return await _mapsFlutter.getPlacePredictions(
      input: input,
      sessionToken: Uuid().v4(),
    );
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    return await _mapsFlutter.getPlaceDetails(
      placeId: placeId,
    );
  }
}
```

---

## STATE MANAGEMENT (Riverpod)

### Provider Hierarchy

```dart
// lib/providers/providers.dart

// 1. SERVICE PROVIDERS (Singleton)
final authServiceProvider = Provider((ref) => AuthService());
final storageServiceProvider = Provider((ref) => StorageService());

// 2. REPOSITORY PROVIDERS (Singleton)
final userRepositoryProvider = Provider((ref) => UserRepository());
final listingRepositoryProvider = Provider((ref) => ListingRepository());

// 3. AUTH STATE
final currentUserProvider = FutureProvider((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return await repo.getCurrentUser();
});

// 4. LISTING STATE
final listingsProvider = FutureProvider((ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  return await repo.getListings();
});

final listingDetailsProvider = FutureProvider.family((ref, String id) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(id);
});

// 5. SEARCH STATE
final searchQueryProvider = StateProvider((ref) => '');

final filteredListingsProvider = FutureProvider((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return repo.getListings();
  }
  return repo.searchListings(query);
});

// 6. UI STATE
final loadingProvider = StateProvider((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);
```

### Usage in Widgets

```dart
// Using providers in ConsumerWidget
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);

    return listingsAsync.when(
      data: (listings) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

// Mutating state
class CreateListingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(loadingProvider.notifier).state = true;

        // Create listing...

        ref.invalidate(listingsProvider); // Refresh listings
      },
      child: Text('Create Listing'),
    );
  }
}
```

---

## AUTHENTICATION FLOW

### Registration Flow

```
User Input → Register Screen
    ↓
Validate email & password
    ↓
Call authService.registerWithEmail()
    ↓
├─ Supabase Auth: Create user account
├─ Database: Insert user record
└─ Preferences: Store auth token
    ↓
Success → Navigate to Home
Error → Show error message
```

### Login Flow

```
User Input → Login Screen
    ↓
Validate credentials
    ↓
Call authService.loginWithEmail()
    ↓
├─ Supabase Auth: Sign in
├─ Database: Fetch user profile
├─ Update: last_login timestamp
└─ Store: Session token
    ↓
Authenticate → Navigator pushNamed('/home')
    ↓
Failed → Show error & allow retry
```

### Session Management

```dart
// Check authentication status
Future<bool> isAuthenticated() async {
  final session = SupabaseConfig.client.auth.currentSession;
  return session != null && session.isExpired == false;
}

//  Handle token refresh
if (session.isExpired) {
  await SupabaseConfig.client.auth.refreshSession();
}

// Automatic logout on 401
void setupAuthErrorHandler() {
  SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedOut) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  });
}
```

---

## FEATURE IMPLEMENTATION DETAILS

### 1. LISTING CREATION

```dart
// lib/presentation/screens/listings/create_listing_screen.dart
class CreateListingScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  List<File> _selectedImages = [];
  List<int> _selectedAmenities = [];
  LatLng? _pickedLocation;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  Future<void> _handleCreateListing() async {
    if (_formKey.currentState!.validate()) {
      ref.read(loadingProvider.notifier).state = true;

      try {
        final listing = ListingModel(
          id: const Uuid().v4(),
          ownerId: ref.read(currentUserProvider).value!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          pricePerMonth: double.parse(_priceController.text),
          locationName: _locationName,
          address: _address,
          city: _city,
          latitude: _pickedLocation!.latitude,
          longitude: _pickedLocation!.longitude,
          roomType: _selectedRoomType,
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Create listing with images and amenities
        final listingId = await _createListingWithDetails(
          listing,
          _selectedImages,
          _selectedAmenities,
        );

        // Invalidate listings provider to refresh
        ref.invalidate(listingsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            ImagePickerWidget(
              images: _selectedImages,
              onImageAdded: _pickImages,
              onImageRemoved: (index) {
                setState(() => _selectedImages.removeAt(index));
              },
            ),
            const SizedBox(height: 16),

            // Basic details
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Title is required';
                return null;
              },
            ),
            // ... more form fields
          ],
        ),
      ),
    );
  }
}
```

### 2. SEARCH & FILTER

```dart
// lib/core/repositories/search_repository.dart
class SearchRepository {
  Future<List<ListingModel>> advancedSearch({
    String? query,
    String? city,
    double? minPrice,
    double? maxPrice,
    List<int>? amenityIds,
    String? roomType,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    var queryBuilder = _supabase
        .from('listings')
        .select()
        .eq('status', 'approved')
        .eq('is_active', true);

    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or(
        'title.ilike.%$query%,description.ilike.%$query%',
      );
    }

    if (city != null) queryBuilder = queryBuilder.eq('city', city);
    if (minPrice != null) queryBuilder = queryBuilder.gte('price_per_month', minPrice);
    if (maxPrice != null) queryBuilder = queryBuilder.lte('price_per_month', maxPrice);
    if (roomType != null) queryBuilder = queryBuilder.eq('room_type', roomType);

    // Radius search using PostGIS or manual calculation
    if (latitude != null && longitude != null && radiusKm != null) {
      final response = await queryBuilder;
      // Filter by distance after fetching
      return _filterByDistance(response, latitude, longitude, radiusKm);
    }

    final response = await queryBuilder;
    return (response as List)
        .map((e) => ListingModel.fromSupabase(e))
        .toList();
  }
}
```

### 3. REAL-TIME CHAT

```dart
// lib/presentation/screens/chat/chat_detail_screen.dart
class ChatDetailScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String? listingId;

  const ChatDetailScreen({
    required this.otherUserId,
    this.listingId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  late RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    final userId = ref.read(currentUserProvider).value?.id;

    _channel = SupabaseConfig.realtimeChannel(
      'messages:receiver_id=eq.$userId',
    );

    _channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final newMessage = MessageModel.fromSupabase(
              payload.newRecord as Map<String, dynamic>,
            );

            // Only show if it's from the current conversation
            if (newMessage.senderId == widget.otherUserId) {
              // Add to message list
              _messagesStream.add(newMessage);

              // Mark as read
              ref
                  .read(messageRepositoryProvider)
                  .markMessageAsRead(newMessage.id);
            }
          },
        )
        .subscribe();
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).value;
    final message = MessageModel(
      id: const Uuid().v4(),
      senderId: currentUser!.id,
      receiverId: widget.otherUserId,
      listingId: widget.listingId,
      messageText: _messageController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(messageRepositoryProvider).sendMessage(message);
      _messageController.clear();

      // Notification to receiver
      await _sendNotification();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: MessageListBuilder(otherUserId: widget.otherUserId),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    _messageController.dispose();
    super.dispose();
  }
}
```

---

## PERFORMANCE & SECURITY

### Performance Optimization

1. **Image Optimization**
```dart
// Compress images before upload
Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '$ {file.absolute.path}_compressed.jpg',
    quality: 80,
    minWidth: 1920,
    minHeight: 1080,
  );
  return File(result!.path);
}

// Use cached network images
CachedNetworkImage(
  imageUrl: listing.imageUrls.first,
  placeholder: (context, url) => const Shimmer.fromColors(...),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInDuration: const Duration(milliseconds: 500),
)
```

2. **Pagination**
```dart
final paginatedListingsProvider =
    StateNotifierProvider<PaginationNotifier, PaginationState>((ref) {
  return PaginationNotifier(ref.watch(listingRepositoryProvider));
});

class PaginationNotifier extends StateNotifier<PaginationState> {
  Future<void> loadMore() async {
    state = state.copyWith(isLoading: true);
    final newListings = await _repo.getListings(
      offset: state.listings.length,
    );
    state = state.copyWith(
      listings: [...state.listings, ...newListings],
      isLoading: false,
    );
  }
}
```

3. **Lazy Loading**
```dart
ListView.builder(
  physics: const AlwaysScrollableScrollPhysics(),
  itemCount: listings.length + 1,
  itemBuilder: (context, index) {
    if (index == listings.length) {
      return Observer(
        builder: (_) => ref.watch(paginationProvider).isLoading
            ? const CircularProgressIndicator()
            : SizedBox.shrink(),
      );
    }
    return ListingTile(listing: listings[index]);
  },
)
```

### Security Best Practices

1. **Row Level Security (RLS)**
```sql
-- Users can only view approved listings or their own
CREATE POLICY "Listings visibility policy" ON listings
  FOR SELECT USING (
    status = 'approved'
    OR owner_id = auth.uid()
    OR auth.jwt() ->> 'role' = 'admin'
  );

-- Users can only update their own listings
CREATE POLICY "Update own listings" ON listings
  FOR UPDATE USING (owner_id = auth.uid());
```

2. **Input Validation**
```dart
class Validators {
  static String? validateEmail(String? value) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value ?? '')) {
      return 'Invalid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if ((value ?? '').length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
```

3. **Secure Storage**
```dart
final _storage = const FlutterSecureStorage();

// Store sensitive data
await _storage.write(
  key: 'auth_token',
  value: token,
  aOptions: _getAndroidOptions(),
  iOptions: _getIOSOptions(),
);

// Retrieve sensitive data
final token = await _storage.read(key: 'auth_token');
```

---

## DEPLOYMENT GUIDE

### Android Deployment

1. **Configure keystore**
```bash
keytool -genkey -v -keystore ~/boardinghouse.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias boardinghouse
```

2. **Create release build**
```bash
flutter build apk --release
# or for Android App Bundle
flutter build appbundle --release
```

3. **Upload to Google Play Store**
- Create app on Google Play Console
- Generate signed APK/AAB
- Upload to internal test → closed testing → production

### iOS Deployment

1. **Configure app signing**
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target
- Set development team

2. **Create build**
```bash
flutter build ios --release
```

3. **Upload to App Store**
```bash
# Create archive via Xcode or:
flutter build ios --release
cd ios
xcode-select --print-path
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner -configuration Release \
  -archivePath build/Runner.xcarchive archive
```

### Web Deployment (Optional)

```bash
flutter build web --release
# Deploy to Firebase Hosting, Netlify, or custom server
firebase deploy --only hosting
```

---

## NEXT STEPS

### Immediate TODO (Next Iteration)
1. [ ] Complete OTP authentication
2. [ ] Implement image upload with compression
3. [ ] Setup real-time chat with streaming UI
4. [ ] Create location picker screen with Google Maps
5. [ ] Implement favorites system with database
6. [ ] Add review/rating system

### Medium-term (2-3 Weeks)
1. [ ] Payment integration with PayMongo
2. [ ] Admin panel for listings approval
3. [ ] Landlord dashboard with analytics
4. [ ] Push notifications with FCM
5. [ ] Advanced search and filters

### Long-term (1-2 Months)
1. [ ] Booking/reservation system
2. [ ] AI-powered recommendations
3. [ ] Video listing support
4. [ ] Virtual tour integration
5. [ ] Community/reviews section

---

## RESOURCES & REFERENCES

- **Supabase Docs**: https://supabase.com/docs
- **Flutter Riverpod**: https://riverpod.dev
- **PayMongo API**: https://developers.paymongo.com
- **Google Maps API**: https://developers.google.com/maps
- **Firebase Cloud Messaging**: https://firebase.google.com/docs/cloud-messaging
- **Clean Architecture in Flutter**: https://resocoder.com/clean-architecture-flutter

---

**Last Updated**: March 2026
**Version**: 1.0.0
**Status**: Production Ready (Core Features) ✅
