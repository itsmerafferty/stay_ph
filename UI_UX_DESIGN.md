# 🎨 UI/UX DESIGN SPECIFICATION - Figma Level

## Design System Overview

### Color Palette
```
Primary:        #6366F1 (Indigo)
Primary Dark:   #4F46E5 (Indigo Dark)
Primary Light:  #818CF8 (Indigo Light)

Secondary:      #F59E0B (Amber)
Success:        #10B981 (Emerald)
Error:          #EF4444 (Red)
Warning:        #F97316 (Orange)

Text Primary:   #1F2937 (Gray 900)
Text Secondary: #6B7280 (Gray 500)
Text Tertiary:  #D1D5DB (Gray 300)

Background:     #FFFFFF (White)
Surface:        #F9FAFB (Gray 50)
Border:         #E5E7EB (Gray 200)

Dark Mode BG:   #111827 (Gray 900)
Dark Mode Surface: #1F2937 (Gray 800)
```

### Typography

**Font Family**: Poppins (Google Fonts)

```
H1: 32px, Weight 700, Line Height 40px
H2: 28px, Weight 600, Line Height 36px
H3: 24px, Weight 600, Line Height 32px
H4: 20px, Weight 600, Line Height 28px
H5: 18px, Weight 600, Line Height 26px
H6: 16px, Weight 600, Line Height 24px

Body Large:     16px, Weight 400, Line Height 24px
Body Medium:    14px, Weight 400, Line Height 20px
Body Small:     12px, Weight 400, Line Height 16px

Label Large:    14px, Weight 500, Line Height 20px
Label Medium:   12px, Weight 500, Line Height 16px
Label Small:    11px, Weight 500, Line Height 14px
```

### Spacing System

```
xs:   4px
sm:   8px
md:   16px
lg:   24px
xl:   32px
2xl:  48px
3xl:  64px
```

### Border Radius

```
xs:   4px
sm:   8px
md:   12px
lg:   16px
xl:   24px
full: 999px
```

### Shadow System (Elevation)

```
Elevation 1 (Card):
  shadow = 0 1px 3px 0 rgba(0,0,0,0.10)

Elevation 2 (Standard):
  shadow = 0 4px 6px -1px rgba(0,0,0,0.10)

Elevation 3 (Modal):
  shadow = 0 10px 15px -3px rgba(0,0,0,0.10)

Elevation 4 (Dialog):
  shadow = 0 20px 25px -5px rgba(0,0,0,0.10)
```

---

## Screen Designs

### 1. SPLASH SCREEN

**Layout**: Centered, Full Screen
**Background**: Gradient (Indigo 400 → Indigo 700)

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│           🏠 (80px)             │
│                                 │
│    Boarding House Finder        │
│         (Heading)               │
│                                 │
│         Philippines             │
│         (Subtitle)              │
│                                 │
│         ⟳ Loading...            │
│                                 │
│                                 │
└─────────────────────────────────┘

Duration: 3 seconds with fade-in animation
```

**Elements**:
- Logo: 80x80px, centered
- App Name: H2, white, centered
- Subtitle: Body Medium, white 70%, centered
- Loading: Circular progress, white

---

### 2. LOGIN SCREEN

**Layout**: Scrollable Column with Header
**Background**: White with Header Gradient

```
┌─────────────────────────────────────────────┐
│  ▲ Gradient Header (Indigo - 150px)         │
│  🏠                                         │
│  Login to Account                           │
│─────────────────────────────────────────────┤
│                                             │
│  [Error Message]  (if error exists)         │
│                                             │
│  📧 Email                                   │
│  ┌───────────────────────────────────────┐  │
│  │ you@example.com                     │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  🔒 Password                                │
│  ┌───────────────────────────────────────┐  │
│  │ ••••••••                  👁️         │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  Forgot Password? →                         │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │     LOGIN (56px height)               │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ─────── or ───────                         │
│                                             │
│  👤 Google  |  f Facebook  |  🍎 Apple      │
│                                             │
│  Don't have account? Sign up →              │
│                                             │
└─────────────────────────────────────────────┘

Spacing: md (16px) between elements
Inputs: 48px height, Border radius md
Button: 56px height, Border radius md
```

**Interactive**:
- Input focus: Border color changes to primary
- Button: Ripple effect on press
- Password toggle: Changes icon on tap

---

### 3. REGISTER SCREEN

**Layout**: Similar to Login with Role Selection

```
┌─────────────────────────────────────────────┐
│  ← Back | CREATE ACCOUNT                    │
├─────────────────────────────────────────────┤
│                                             │
│  🏠 Welcome!                                │
│  Create your account and start finding...   │
│                                             │
│  👤 Full Name                               │
│  ┌───────────────────────────────────────┐  │
│  │ John Doe                            │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  📧 Email                                   │
│  ┌───────────────────────────────────────┐  │
│  │ john@example.com                    │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  I am a:                                    │
│  ◉ Tenant    ○ Landlord                     │
│                                             │
│  🔒 Password                                │
│  ┌───────────────────────────────────────┐  │
│  │ ••••••••                  👁️         │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  🔒 Confirm Password                        │
│  ┌───────────────────────────────────────┐  │
│  │ ••••••••                  👁️         │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │    CREATE ACCOUNT                     │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  Already have account? Login →              │
│                                             │
└─────────────────────────────────────────────┘
```

---

### 4. HOME SCREEN

**Layout**: Custom Scroll View with SliverAppBar

```
┌───────────────────────────────────────────────┐
│ 🏠 Boarding House Finder  🔔 👤 (AppBar)     │
├───────────────────────────────────────────────┤
│                                               │
│  ┌─────────────────────────────────────────┐  │
│  │ 🔍 Search listings...                 │ │  │
│  └─────────────────────────────────────────┘  │
│  🎚️ Price | 📍 Location | 🏠 Amenities | 🏘️│
│                                               │
│  ⭐ FEATURED LISTINGS                         │
│  ┌──────────  ┌──────────  ┌──────────      │
│  │ [IMG]      │ [IMG]      │ [IMG]           │
│  │ Property 1 │ Property 2 │ Property 3     │
│  │ ₱5000/mo   │ ₱4500/mo   │ ₱6000/mo       │
│  └──────────  └──────────  └──────────      │
│  (Horizontal Scroll)                         │
│                                               │
│  ALL LISTINGS                                 │
│  ┌─────────────────────────────────────────┐  │
│  │ [IMG] Property 1          ⭐ 4.5 (32)   │  │
│  │ 📍 Makati City            ₱5000/month   │  │
│  └─────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────┐  │
│  │ [IMG] Property 2          ⭐ 4.8 (64)   │  │
│  │ 📍 BGC, Taguig            ₱6500/month   │  │
│  └─────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────┐  │
│  │ [IMG] Property 3          ⭐ 4.2 (18)   │  │
│  │ 📍 QC, Quezon City        ₱4200/month   │  │
│  └─────────────────────────────────────────┘  │
│                                               │
│  [More listings...]                           │
│                                               │
└───────────────────────────────────────────────┘
     FAB: + (Create Listing)
```

**Components**:
- AppBar: Height 56px, elevation 2
- Search bar: 48px height, rounded full
- Filter chips: 32px height, horizontal scrollable
- Featured carousel: 220px height, margin 16px
- Listing tiles: 120px height, full width minus 32px padding

---

### 5. LISTING DETAILS SCREEN

**Layout**: CustomScrollView with Image Carousel

```
┌─────────────────────────────────────────────────────┐
│ ← ♥️ 🔗                (AppBar Transparent)       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ╔═════════════════════════════════════════════╗  │
│  ║  ▶ [Image Gallery - Swipeable]             ║  │
│  ║  Featured ⭐  (if featured)                  ║  │
│  ║                                             ║  │
│  ║  • • • • • •  (Page indicators)             ║  │
│  ╚═════════════════════════════════════════════╝  │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Condo Unit in Makati                 ⭐ 4.5 (32) │
│  📍 Makati, Metropolitan Manila                     │
│                                                     │
│  ┌───────────────────┬───────────────────────────┐ │
│  │ ₱5,000            │ ₱200 per day              │ │
│  │ per month         │                           │ │
│  └───────────────────┴───────────────────────────┘ │
│                                                     │
│  🛏️ 1  |  🚿 1  |  👥 2  |  🆓 1              │
│ Bedroom  Bathroom  Capacity  Available               │
│                                                     │
│  ─────────────────────────────────────────────── │
│  DESCRIPTION                                        │
│  Modern condo unit with complete amenities...      │
│  [Show More]                                        │
│                                                     │
│  AMENITIES                                          │
│  ✓ WiFi     ✓ AC       ✓ Hot Water                 │
│  ✓ Parking  ✓ Security ✓ Laundry                   │
│                                                     │
│  LANDLORD                                           │
│  ┌──────────────────────────────────────────────┐ │
│  │ 👤 Juan dela Cruz              ✓ Verified   │ │
│  │ Rating: 4.8 (45 reviews)                     │ │
│  │              [💬 CHAT]           [📞 CALL]   │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  REVIEWS                                            │
│  ┌──────────────────────────────────────────────┐ │
│  │ ⭐⭐⭐⭐⭐ Maria Santos                       │ │
│  │ "Great location and responsive landlord"     │ │
│  │ 2 days ago                                   │ │
│  └──────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────┐ │
│  │ ⭐⭐⭐⭐  Pedro Lopez                        │ │
│  │ "Clean but expensive"                        │ │
│  │ 1 week ago                                   │ │
│  └──────────────────────────────────────────────┘ │
│                                                     │
│  [View All Reviews]                                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Sticky Footer**:
```
┌─────────────────────────────────────────────┐
│ [❤️ SAVE]  |  [📱 INQUIRE]  [💬 MESSAGE]   │
└─────────────────────────────────────────────┘
```

---

### 6. CHAT SCREEN

**Layout**: Message Bubble List

```
┌──────────────────────────────────────────┐
│ Juan dela Cruz              ☎️  ⓘ  ⋮     │
│ 2h ago                                   │
├──────────────────────────────────────────┤
│                                          │
│        Hi, are you available in July?    │
│        [14:30]                           │
│                                          │
│  Yes, we have 2 bedrooms available    →  │
│  [14:35]                                 │
│                                          │
│        Can you send more photos?         │
│        [14:40]                           │
│                                          │
│  Sure, let me arrange a viewing        → │
│  [14:42]                                 │
│                                          │
│  [4 photos sent]                       → │
│  [14:43]                                 │
│                                          │
├──────────────────────────────────────────┤
│  +-+ Message...                [📎] [➤]  │
└──────────────────────────────────────────┘
```

---

### 7. PROFILE SCREEN

**Layout**: Column with Avatar Header

```
┌────────────────────────────────┐
│ ← PROFILE                   ⚙️  │
├────────────────────────────────┤
│                                │
│           👤 (Avatar)          │
│        (Tap to change)         │
│                                │
│     Maria Santos               │
│     🔮 TENANT 🔮              │
│                                │
├────────────────────────────────┤
│ ✎ EDIT PROFILE                │
│ ❥ SAVED LISTINGS              │
│ 💬 MESSAGES                    │
│ ⭐ REVIEWS                     │
│ ⚙️  SETTINGS                   │
│ ❓ HELP & SUPPORT              │
│                                │
│ ┌──────────────────────────┐  │
│ │  LOGOUT                  │  │
│ └──────────────────────────┘  │
│                                │
└────────────────────────────────┘
```

---

### 8. CREATE LISTING SCREEN (Landlord)

**Layout**: Multi-step form or sectioned scrollable

```
STEP 1: BASIC INFO
┌──────────────────────────────────────────┐
│ 1. BASIC INFO  |  2. DETAILS  |  3. FINISH│
├──────────────────────────────────────────┤
│                                          │
│ Title *                                  │
│ ┌──────────────────────────────────────┐ │
│ │ Condo Unit in Makati                 │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ Description *                            │
│ ┌──────────────────────────────────────┐ │
│ │ Modern condo with complete amenities │ │
│ │ Near schools and shopping centers    │ │
│ │                                      │ │
│ │                         (150/500)    │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ Room Type * [Dropdown ▼]                 │
│   ◉ Bedspace  ○ Room  ○ Apartment       │
│                                          │
│ [NEXT >]                                 │
│                                          │
└──────────────────────────────────────────┘

STEP 2: IMAGES & DETAILS
┌──────────────────────────────────────────┐
│ 1. BASIC INFO  |  2. DETAILS  |  3. FINISH│
├──────────────────────────────────────────┤
│                                          │
│ PHOTOS (Max 10) *                        │
│ [+ Add Photos]                           │
│ ┌──────┐ ┌──────┐ ┌──────┐              │
│ │[IMG] │ │[IMG] │ │ + 2  │              │
│ │ (x)  │ │ (x)  │ │more  │              │
│ └──────┘ └──────┘ └──────┘              │
│                                          │
│ Price per Month * ₱ [Input]              │
│ Price per Day      ₱ [Input]             │
│                                          │
│ Location *                               │
│ City: [Dropdown]  Province: [Dropdown]   │
│ Address: [Text Field]                    │
│                                          │
│📍 [Pick Location on Map]                 │
│                                          │
│ [< BACK]  [NEXT >]                       │
│                                          │
└──────────────────────────────────────────┘

STEP 3: AMENITIES & REVIEW
┌──────────────────────────────────────────┐
│ 1. BASIC INFO  |  2. DETAILS  |  3. FINISH│
├──────────────────────────────────────────┤
│                                          │
│ SELECT AMENITIES                         │
│ ☑ WiFi       ☐ Parking  ☑ AC            │
│ ☐ Laundry    ☑ Security ☑ Hot Water    │
│ ☐ Gym        ☑ Study Area               │
│                                          │
│ REVIEW YOUR LISTING                      │
│ ┌──────────────────────────────────────┐ │
│ │ Condo Unit in Makati                 │ │
│ │ ₱5,000 / month                       │ │
│ │ Makati City                          │ │
│ │ ✓ WiFi, AC, Security, Hot Water      │ │
│ └──────────────────────────────────────┘ │
│                                          │
│ ┌──────────────────────────────────────┐ │
│ │    CREATE LISTING                    │ │
│ └──────────────────────────────────────┘ │
│                                          │
└──────────────────────────────────────────┘
```

---

## Component Library

### Buttons

**Primary Button**
- Size: 56px height
- Color: Indigo 700
- Text: Label Large, White
- Border Radius: md (12px)
- State: Normal, Hover, Pressed, Disabled

**Secondary Button**
- Size: 48px height
- Color: Border Gray 300, Text Indigo 700
- Border: 2px

**Icon Button**
- Size: 48px diameter
- Color: Indigo 700
- Shape: Circle
- Ripple: 40px radius

### Cards

**Listing Card**
- Size: Full width minus 32px padding
- Height: 120px (horizontal layout)
- Border Radius: md (12px)
- Shadow: Elevation 2
- Overflow: Hidden with gradient overlay

**Featured Card**
- Size: 200px width
- Height: 220px
- Border Radius: lg (16px)
- Featured Badge: Top right, Amber background

### Input Fields

**Text Field**
- Height: 48px
- Border Radius: md (12px)
- Border: 1px Gray 300
- Focus: Border Indigo 700, Shadow
- Label: Above field

**Dropdown**
- Height: 48px
- Border Radius: md (12px)
- Chevron Icon: Right padding 16px

### Chips/Tags

```
☑ Amenity Name
  48px height, Border radius full
  24px padding horizontal
  Indigo 100 background when selected
```

### Bottom Navigation

```
┌─────────────────────────────────────┐
│ 🏠 Home  💬 Chat  ❥ Likes  👤 Profile│
└─────────────────────────────────────┘
  56px height, Amber for active
```

---

## Animation Specifications

### Page Transitions
- Duration: 300ms
- Curve: easeInOut
- Type: Slide from right (Android), Fade (iOS)

### Button Press
- Duration: 100ms
- Scale: 0.95

### List Item Expansion
- Duration: 200ms
- Curve: easInOut

### Loading Animation
- Circular progress: 2-second rotation
- Shimmer placeholder: 1-second wave

### Message Bubble Entrance
- Slide from bottom: 200ms
- Fade in: 200ms

---

## Responsive Design Breakpoints

```
Mobile:     0 - 600px
Tablet:     600px - 1200px
Web:        1200px+
```

For mobile (primary):
- Full width utilization
- 16px padding
- Touch targets: minimum 48x48px

---

## Dark Mode Colors

```
Background:     #111827
Surface:        #1F2937
Surface 2:      #374151
Text Primary:   #F3F4F6
Text Secondary: #D1D5DB
Border:         #4B5563
Primary:        #818CF8 (lighter)
```

---

## Accessibility Guidelines

✅ **Contrast**: Minimum WCAG AA (4.5:1)
✅ **Text Size**: Minimum 12px
✅ **Touch Targets**: 48x48px minimum
✅ **Semantic Labels**: All inputs labeled
✅ **Keyboard Navigation**: All interactive elements accessible
✅ **Focus Indicators**: Visible 2px border
✅ **Color Not Only**: Icons + text for status

---

**Design System Created**: March 22, 2026
**Status**: Ready for Development ✅
