-- ============================================================================
-- STAY PH - Complete Database Schema
-- Execute this SQL in your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. LISTINGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  landlord_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  price INTEGER NOT NULL, -- in PHP
  room_type VARCHAR(50) NOT NULL, -- 'Bedspace', 'Room', 'Apartment', 'Studio'
  description TEXT,
  amenities TEXT, -- JSON array as string or comma-separated list
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'rented', 'inactive'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for frequent queries
CREATE INDEX idx_listings_landlord_id ON listings(landlord_id);
CREATE INDEX idx_listings_city ON listings(city);
CREATE INDEX idx_listings_room_type ON listings(room_type);

-- ============================================================================
-- 2. LISTING_IMAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS listing_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  image_url VARCHAR(500) NOT NULL,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for frequent queries
CREATE INDEX idx_listing_images_listing_id ON listing_images(listing_id);

-- ============================================================================
-- 3. FAVORITES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  -- Ensure each tenant can only favorite each listing once
  UNIQUE(tenant_id, listing_id)
);

-- Create indexes
CREATE INDEX idx_favorites_tenant_id ON favorites(tenant_id);
CREATE INDEX idx_favorites_listing_id ON favorites(listing_id);

-- ============================================================================
-- 4. MESSAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for conversation queries
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
-- Composite index for conversation fetch
CREATE INDEX idx_messages_conversation ON messages(
  GREATEST(sender_id, receiver_id),
  LEAST(sender_id, receiver_id)
);

-- ============================================================================
-- 5. TENANT_INQUIRIES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS tenant_inquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  message TEXT,
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'withdrawn'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_tenant_inquiries_tenant_id ON tenant_inquiries(tenant_id);
CREATE INDEX idx_tenant_inquiries_listing_id ON tenant_inquiries(listing_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_inquiries ENABLE ROW LEVEL SECURITY;

-- LISTINGS POLICIES
-- Anyone can view active listings
CREATE POLICY "listings_select_all" ON listings
  FOR SELECT USING (status = 'active');

-- Only landlord can insert/update/delete their own listings
CREATE POLICY "listings_insert" ON listings
  FOR INSERT WITH CHECK (auth.uid() = landlord_id);

CREATE POLICY "listings_update" ON listings
  FOR UPDATE USING (auth.uid() = landlord_id);

CREATE POLICY "listings_delete" ON listings
  FOR DELETE USING (auth.uid() = landlord_id);

-- Landlord can see all their listings (including inactive)
CREATE POLICY "listings_select_own" ON listings
  FOR SELECT USING (auth.uid() = landlord_id);

-- LISTING_IMAGES POLICIES
-- Anyone can view images of active listings
CREATE POLICY "listing_images_select_active" ON listing_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = listing_images.listing_id
      AND listings.status = 'active'
    )
  );

-- Landlord can manage images for their listings
CREATE POLICY "listing_images_insert" ON listing_images
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = listing_id
      AND listings.landlord_id = auth.uid()
    )
  );

CREATE POLICY "listing_images_delete" ON listing_images
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = listing_id
      AND listings.landlord_id = auth.uid()
    )
  );

-- FAVORITES POLICIES
-- Tenants can only manage their own favorites
CREATE POLICY "favorites_select" ON favorites
  FOR SELECT USING (auth.uid() = tenant_id);

CREATE POLICY "favorites_insert" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = tenant_id);

CREATE POLICY "favorites_delete" ON favorites
  FOR DELETE USING (auth.uid() = tenant_id);

-- MESSAGES POLICIES
-- Users can only see messages where they are sender or receiver
CREATE POLICY "messages_select" ON messages
  FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

-- Users can only insert messages they're sending
CREATE POLICY "messages_insert" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- TENANT_INQUIRIES POLICIES
-- Tenants can see and manage their own inquiries
CREATE POLICY "inquiries_select_tenant" ON tenant_inquiries
  FOR SELECT USING (auth.uid() = tenant_id);

-- Landlords can see inquiries for their listings
CREATE POLICY "inquiries_select_landlord" ON tenant_inquiries
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = listing_id
      AND listings.landlord_id = auth.uid()
    )
  );

-- Tenants can insert their own inquiries
CREATE POLICY "inquiries_insert_tenant" ON tenant_inquiries
  FOR INSERT WITH CHECK (auth.uid() = tenant_id);

-- Tenants can update their own inquiries
CREATE POLICY "inquiries_update_tenant" ON tenant_inquiries
  FOR UPDATE USING (auth.uid() = tenant_id);

-- Landlords can update inquiry status for their listings
CREATE POLICY "inquiries_update_landlord" ON tenant_inquiries
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = listing_id
      AND listings.landlord_id = auth.uid()
    )
  );

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================
-- Uncomment below to add test data after creating the tables

/*
-- Insert test listings
INSERT INTO listings (landlord_id, address, city, price, room_type, description, status)
VALUES
  ('00000000-0000-0000-0000-000000000000', '123 Main St', 'Manila', 5000, 'Bedspace', 'Cozy bedspace near university', 'active'),
  ('00000000-0000-0000-0000-000000000000', '456 Oak Ave', 'Quezon City', 6000, 'Room', 'Spacious room with AC', 'active'),
  ('00000000-0000-0000-0000-000000000000', '789 Elm St', 'Taguig', 12000, 'Apartment', 'Modern studio apartment', 'active');

-- Insert test images
INSERT INTO listing_images (listing_id, image_url, display_order)
VALUES
  ((SELECT id FROM listings LIMIT 1), 'https://via.placeholder.com/400x300?text=Bedspace', 0);
*/

-- ============================================================================
-- DONE!
-- Your database schema is now ready for the Stay PH application
-- ============================================================================
