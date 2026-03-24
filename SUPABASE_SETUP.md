# Supabase Auth Integration Setup Guide

Your Flutter app is now configured with Supabase authentication! Follow these steps to get it fully working:

## Step 1: Create a Supabase Project

1. Go to https://supabase.com
2. Sign in or create an account
3. Create a new project
4. Wait for the project to initialize

## Step 2: Get Your Credentials

1. In your Supabase dashboard, click **Project Settings** (bottom left)
2. Click the **API** tab
3. Copy these values:
   - **Project URL** → `supabaseUrl`
   - **anon public key** → `supabaseAnonKey`

## Step 3: Configure Your App

Update `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

## Step 4: Enable Email Authentication (Optional)

To use email/password authentication:

1. In Supabase Dashboard → **Authentication**
2. Click **Providers**
3. Enable **Email**
4. (Optional) Configure email templates under **Email Templates**

## Project Structure

### Authentication Service (`lib/services/auth_service.dart`)
Core authentication methods:
- `signUp()` - Register new users with email, password, and name
- `signIn()` - Login with email and password
- `signOut()` - Logout current user
- `resetPassword()` - Send password reset email
- `authStateChanges` - Stream to listen to auth state changes
- `currentUser` - Get currently logged-in user
- `isSignedIn` - Check if user is authenticated

### Pages

#### Login Page (`lib/pages/login_page.dart`)
- Email/password login form
- Sign up link
- Password validation
- Error handling

#### Signup Page (`lib/pages/signup_page.dart`)
- Full registration form with name, email, password
- Password confirmation
- Proper error handling

#### Home Page (`lib/pages/home_page.dart`)
- Protected page (only accessible when logged in)
- Displays user info
- Sign out button

#### Auth Wrapper (`lib/pages/auth_wrapper.dart`)
- Handles automatic navigation based on auth state
- Shows login page if not authenticated
- Shows home page if authenticated

## How It Works

1. **App Start**: `main.dart` initializes Supabase and shows `AuthWrapper`
2. **AuthWrapper**: Listens to auth state changes
   - If user is logged in → shows `HomePage`
   - If user is logged out → shows `LoginPage`
3. **User Actions**:
   - Signs up → `AuthService.signUp()` → Email confirmation (if configured)
   - Logs in → `AuthService.signIn()` → Redirected to `HomePage`
   - Logs out → `AuthService.signOut()` → Redirected to `LoginPage`

## Testing

### Test Sign Up
1. Fill in all fields on Sign Up page
2. Click "Sign Up"
3. You should see a success message
4. Check Supabase Dashboard → Authentication → Users to see new user

### Test Login
1. Enter the email and password you just created
2. Click "Login"
3. You should be redirected to the Home page

### Test Sign Out
1. Click the logout icon in the Home page app bar
2. You should be redirected to the Login page

## Features Included

✅ Email/password authentication
✅ User registration with name
✅ Persistent authentication session
✅ Automatic navigation based on auth state
✅ Error handling and user feedback
✅ Sign out functionality
✅ Password reset support

## Next Steps

- Add social authentication (Google, GitHub, etc.)
- Implement password reset flow
- Add user profile management
- Create database for user data
- Add email verification flow

## Troubleshooting

**"YOUR_SUPABASE_URL is not configured"**
→ Update `supabase_config.dart` with your actual credentials

**Login/Signup not working**
→ Check that your Supabase project is active and API keys are correct

**Users can't sign up**
→ Check Supabase Dashboard → Authentication → Policies for any restrictions

**App crashes on startup**
→ Ensure Supabase package is properly installed: `flutter pub get`
