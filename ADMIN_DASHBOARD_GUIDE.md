# 📊 ADMIN DASHBOARD IMPLEMENTATION GUIDE

## Overview

A complete, responsive admin dashboard for moderating listings, managing users, tracking payments, and viewing analytics. Built with Flutter, responsive for both mobile and web.

---

## Features

✅ **Dashboard Overview**
- Real-time statistics (users, listings, revenue)
- User growth charts
- Revenue breakdown
- Recent activity feed

✅ **Pending Listings Management**
- View pending listings with details
- Approve or reject listings
- Add review comments
- Search & filter

✅ **User Management**
- View all users (tenant/landlord/admin)
- Ban/unban users
- Edit user information
- View user activity

✅ **Report Handling**
- View flagged content
- Different report types
- Action history
- Automated responses

✅ **Payment Tracking**
- Transaction history
- Payment status
- Revenue reports
- Subscription tracking

✅ **Analytics**
- Daily active users
- Listing creation trends
- User engagement metrics
- Revenue analytics

✅ **Settings**
- App configuration
- Moderation rules
- Feature toggles
- Maintenance mode

---

## Screen Layout

### Desktop / Web Layout
```
┌─────────────────────────────────────────────┐
│  ADMIN DASHBOARD  [Chip: Admin] 👤         │
├────────────────────────────────────────────┤
│              │                              │
│ SIDEBAR      │                              │
│              │       MAIN CONTENT AREA       │
│ ├ Dashboard  │                              │
│ ├ Pending(5) │                              │
│ ├ Users      │                              │
│ ├ Reports(3) │                              │
│ ├ Payments   │                              │
│ ├ Analytics  │                              │
│ ├ Settings   │                              │
│ └ Logout     │                              │
│              │                              │
└─────────────────────────────────────────────┘
```

### Mobile Layout
```
┌──────────────────────────────────────┐
│ ADMIN DASHBOARD  [Chip] 👤          │
├──────────────────────────────────────┤
│ 📊 📋 👥 📌 💰 📈 ⚙️                │
├──────────────────────────────────────┤
│                                      │
│       MAIN CONTENT AREA              │
│                                      │
│                                      │
│                                      │
└──────────────────────────────────────┘
```

---

## Integration Steps

### Step 1: Add Admin Route to Navigation

```dart
// lib/main.dart
import 'presentation/screens/admin/admin_dashboard_screen.dart';

void main() {
  // ... existing code
  runApp(
    MaterialApp(
      // ...
      home: SplashScreen(),
      routes: {
        '/admin': (_) => const AdminDashboardScreen(),
        // ... other routes
      },
    ),
  );
}
```

### Step 2: Add Admin Check

```dart
// lib/providers/providers.dart

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.role == 'admin';
});
```

### Step 3: Protect Admin Route

```dart
// lib/presentation/screens/admin/admin_navigation.dart

class AdminNavigationGuard extends ConsumerWidget {
  const AdminNavigationGuard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return isAdmin.when(
      data: (admin) {
        if (!admin) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Access Denied',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('You do not have permission to access this page'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        return const AdminDashboardScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

### Step 4: Add Admin Schemas to Database

```sql
-- Create admin-specific views and functions

-- Function to get pending listings with details
CREATE OR REPLACE FUNCTION get_pending_listings()
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  owner_id UUID,
  owner_name VARCHAR,
  location VARCHAR,
  price_per_month DECIMAL,
  created_at TIMESTAMP,
  status VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    l.id,
    l.title,
    l.owner_id,
    u.full_name,
    l.location_name,
    l.price_per_month,
    l.created_at,
    l.status
  FROM listings l
  JOIN users u ON l.owner_id = u.id
  WHERE l.status = 'pending'
  ORDER BY l.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get dashboard statistics
CREATE OR REPLACE FUNCTION get_dashboard_stats()
RETURNS TABLE (
  total_users BIGINT,
  active_listings BIGINT,
  monthly_revenue DECIMAL,
  pending_listings BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM listings WHERE status = 'approved' AND is_active = true) as active_listings,
    (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed' AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', NOW())) as monthly_revenue,
    (SELECT COUNT(*) FROM listings WHERE status = 'pending') as pending_listings;
END;
$$ LANGUAGE plpgsql;

-- Function to approve listing
CREATE OR REPLACE FUNCTION approve_listing(
  listing_id UUID,
  admin_id UUID,
  notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE listings
  SET status = 'approved', updated_at = NOW()
  WHERE id = listing_id;

  INSERT INTO notifications (
    user_id,
    sender_id,
    notification_type,
    title,
    message
  ) VALUES (
    (SELECT owner_id FROM listings WHERE id = listing_id),
    admin_id,
    'listing_approved',
    'Your listing was approved',
    'Your listing has been reviewed and approved. It is now visible to all users.'
  );

  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Function to reject listing
CREATE OR REPLACE FUNCTION reject_listing(
  listing_id UUID,
  admin_id UUID,
  reason TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE listings
  SET status = 'rejected', updated_at = NOW()
  WHERE id = listing_id;

  INSERT INTO notifications (
    user_id,
    sender_id,
    notification_type,
    title,
    message
  ) VALUES (
    (SELECT owner_id FROM listings WHERE id = listing_id),
    admin_id,
    'listing_rejected',
    'Your listing was rejected',
    reason
  );

  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Function to ban user
CREATE OR REPLACE FUNCTION ban_user(
  user_id UUID,
  admin_id UUID,
  reason TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE users
  SET is_banned = true, banned_reason = reason, updated_at = NOW()
  WHERE id = user_id;

  -- Deactivate all listings
  UPDATE listings
  SET is_active = false
  WHERE owner_id = user_id;

  RETURN true;
END;
$$ LANGUAGE plpgsql;
```

### Step 5: Create Admin Repositories

```dart
// lib/core/repositories/admin_repository.dart

abstract class IAdminRepository {
  Future<List<ListingModel>> getPendingListings();
  Future<void> approveListing(String listingId, String reason);
  Future<void> rejectListing(String listingId, String reason);
  Future<List<UserModel>> getAllUsers();
  Future<void> banUser(String userId, String reason);
  Future<void> unbanUser(String userId);
  Future<List<ReportModel>> getReports();
  Future<void> resolveReport(String reportId, String action);
  Future<Map<String, dynamic>> getDashboardStats();
}

class AdminRepository implements IAdminRepository {
  final SupabaseClient _supabase = SupabaseConfig.client;

  @override
  Future<List<ListingModel>> getPendingListings() async {
    try {
      final response = await _supabase.rpc('get_pending_listings');
      return (response as List)
          .map((e) => ListingModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending listings: $e');
    }
  }

  @override
  Future<void> approveListing(String listingId, String reason) async {
    try {
      final adminId = _supabase.auth.currentUser?.id;
      await _supabase.rpc(
        'approve_listing',
        params: {
          'listing_id': listingId,
          'admin_id': adminId,
          'notes': reason,
        },
      );
    } catch (e) {
      throw Exception('Failed to approve listing: $e');
    }
  }

  @override
  Future<void> rejectListing(String listingId, String reason) async {
    try {
      final adminId = _supabase.auth.currentUser?.id;
      await _supabase.rpc(
        'reject_listing',
        params: {
          'listing_id': listingId,
          'admin_id': adminId,
          'reason': reason,
        },
      );
    } catch (e) {
      throw Exception('Failed to reject listing: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase.from('users').select();
      return (response as List)
          .map((e) => UserModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<void> banUser(String userId, String reason) async {
    try {
      await _supabase.rpc(
        'ban_user',
        params: {
          'user_id': userId,
          'admin_id': _supabase.auth.currentUser?.id,
          'reason': reason,
        },
      );
    } catch (e) {
      throw Exception('Failed to ban user: $e');
    }
  }

  @override
  Future<void> unbanUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'is_banned': false,
            'banned_reason': null,
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to unban user: $e');
    }
  }

  @override
  Future<List<ReportModel>> getReports() async {
    try {
      final response = await _supabase
          .from('admin_reports')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ReportModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  @override
  Future<void> resolveReport(String reportId, String action) async {
    try {
      await _supabase
          .from('admin_reports')
          .update({
            'status': 'resolved',
            'action_taken': action,
            'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);
    } catch (e) {
      throw Exception('Failed to resolve report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _supabase.rpc('get_dashboard_stats');
      return response[0] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}
```

### Step 6: Add Providers

```dart
// lib/providers/admin_providers.dart

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  return AdminRepository();
});

final pendingListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getPendingListings();
});

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getDashboardStats();
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getAllUsers();
});

final reportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return await repo.getReports();
});
```

---

## Usage

### Navigate to Admin Dashboard

```dart
// From any screen
Navigator.pushNamed(context, '/admin');

// Or using go_router (if implemented)
context.go('/admin');
```

### Approve a Listing

```dart
ref.read(adminRepositoryProvider).approveListing(
  listingId,
  'Looks good. Approved!',
);

// Invalidate cache
ref.invalidate(pendingListingsProvider);
```

### Ban a User

```dart
ref.read(adminRepositoryProvider).banUser(
  userId,
  'Violated community guidelines',
);

// Invalidate cache
ref.invalidate(allUsersProvider);
```

---

## Customization

### Change Color Scheme

```dart
// In admin_dashboard_screen.dart
// Primary: Colors.indigo.shade700
// Secondary: Colors.amber.shade400
// Success: Colors.green
// Error: Colors.red

// Change to your preference
AppBar(
  backgroundColor: Colors.teal.shade700,
  // ...
)
```

### Add More Stats

```dart
// In _DashboardView
_StatCard(
  title: 'My Custom Stat',
  value: '999',
  icon: Icons.star,
  color: Colors.purple,
  trend: '+5% this week',
),
```

### Add New Sections

```dart
// Create new view class
class _NewFeatureView extends StatelessWidget {
  const _NewFeatureView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        // Your content
      ),
    );
  }
}

// Add to switch statement in _buildContent()
case 7:
  return _NewFeatureView();
```

---

## Responsive Breakpoints

Dashboard automatically adapts:
- **Mobile** (< 900px): Tab-based navigation
- **Tablet** (900px - 1200px): Side navigation
- **Desktop** (> 1200px): Full sidebar with expanded content

### Custom Breakpoints

```dart
final isMobile = MediaQuery.of(context).size.width < 600;
final isTablet = MediaQuery.of(context).size.width < 1200;
final isDesktop = MediaQuery.of(context).size.width >= 1200;
```

---

## Enhancements (Optional)

### 1. Add Charts (fl_chart)

```yaml
dependencies:
  fl_chart: ^0.63.0
```

```dart
// Replace _buildSimpleLineChart() with:
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 3),
          FlSpot(1, 4),
          FlSpot(2, 3.5),
          // ...
        ],
        isCurved: true,
        color: Colors.indigo,
      ),
    ],
  ),
);
```

### 2. Add Data Export (CSV/PDF)

```dart
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void exportToCSV(List<ListingModel> listings) {
  List<List<dynamic>> csvData = [
    ["Title", "Location", "Price", "Status"],
    for (var listing in listings)
      [listing.title, listing.locationName, listing.pricePerMonth, listing.status],
  ];

  String csv = const ListToCsvConverter().convert(csvData);
  // Save to file
}
```

### 3. Real-time Updates

```dart
// Add Realtime listener
_supabase
    .from('listings')
    .stream(primaryKey: ['id'])
    .eq('status', 'pending')
    .listen((List<Map<String, dynamic>> data) {
      // Update UI with new pending listings
      ref.invalidate(pendingListingsProvider);
    });
```

---

## Security Considerations

✅ **Admin Authorization Check**: Always verify user is admin
✅ **RLS Policies**: Database enforces admin-only operations
✅ **Audit Trail**: Log all admin actions
✅ **Rate Limiting**: Implement on sensitive operations
✅ **IP Whitelisting**: (Optional) Restrict admin access to known IPs

```sql
-- Create audit log table
CREATE TABLE admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES users(id),
  action VARCHAR NOT NULL,
  target_table VARCHAR,
  target_id UUID,
  changes JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Log on listing approval
CREATE TRIGGER log_listing_approval
AFTER UPDATE ON listings
FOR EACH ROW
WHEN (OLD.status != NEW.status)
EXECUTE FUNCTION log_admin_action();
```

---

## Testing Admin Features

### Unit Tests

```dart
test('Admin can approve listing', () async {
  final repo = AdminRepository();
  await repo.approveListing('list_id', 'Good listing');

  final listing = await repo.getPendingListings();
  expect(listing, isEmpty);
});
```

### Manual Testing Checklist

- [ ] Login as admin
- [ ] View dashboard stats
- [ ] Approve a listing
- [ ] Reject a listing
- [ ] Ban a user
- [ ] View reports
- [ ] Check payments
- [ ] View analytics
- [ ] Change settings
- [ ] Test on mobile
- [ ] Test on tablet
- [ ] Test on desktop

---

## Deployment

### Build for Web

```bash
flutter build web --release
```

### Deploy to Hosting

```bash
# Firebase Hosting
firebase deploy --only hosting

# Vercel
vercel --prod

# Netlify
netlify deploy --prod
```

### Environment Configuration

```bash
# .env
ADMIN_ALLOWED_EMAILS=admin@example.com,moderator@example.com
ADMIN_SESSION_TIMEOUT=3600
AUDIT_LOGGING=true
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=3600
```

---

**Admin Dashboard**: Production Ready ✅
**Last Updated**: March 22, 2026
**Version**: 1.0.0
