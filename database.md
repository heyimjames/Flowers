# 🗄️ Supabase Backend Integration for Flowers

This document outlines the strategy, implementation details, and considerations for adding Supabase as a backend to the Flowers app.

## 📊 Overview

Adding Supabase would transform Flowers from a local-only app to a connected experience with user accounts, cloud sync, social features, and monetization capabilities.

**Complexity Level:** Medium (4-6 weeks for full implementation)

## 🏗️ Current Architecture Analysis

### ✅ Existing Advantages
- **Clean Data Models** - `AIFlower` is already `Codable` and well-structured
- **Centralized State** - `FlowerStore` handles all data management
- **Service Layer** - Clear separation of concerns
- **iCloud Sync** - Existing sync logic can be adapted

### 🔄 Required Changes
- Add authentication layer
- Modify data persistence to use Supabase
- Update image storage strategy
- Add network error handling
- Implement offline support

## 🗃️ Database Schema

### Users Table
```sql
-- Core user information
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  -- Subscription info
  subscription_status TEXT DEFAULT 'free', -- free, premium, lifetime
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  
  -- Stats
  total_flowers_discovered INTEGER DEFAULT 0,
  total_flowers_gifted INTEGER DEFAULT 0,
  total_flowers_received INTEGER DEFAULT 0,
  
  -- Preferences
  preferences JSONB DEFAULT '{}',
  
  -- Metadata
  device_ids TEXT[], -- For migration from device-based system
  last_seen_at TIMESTAMP WITH TIME ZONE,
  onboarding_completed BOOLEAN DEFAULT false
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Flowers Table
```sql
-- Individual flower records
CREATE TABLE flowers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Core flower data
  name TEXT NOT NULL,
  descriptor TEXT NOT NULL,
  image_url TEXT NOT NULL, -- Stored in Supabase Storage
  thumbnail_url TEXT, -- Smaller version for lists
  
  -- Metadata
  meaning TEXT,
  characteristics TEXT,
  origins TEXT,
  description TEXT,
  season TEXT,
  colors TEXT[],
  
  -- Discovery context
  discovered_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  discovery_latitude DOUBLE PRECISION,
  discovery_longitude DOUBLE PRECISION,
  discovery_location_name TEXT,
  discovery_weather TEXT,
  discovery_temperature DOUBLE PRECISION,
  discovery_context JSONB, -- Additional context like holidays, events
  
  -- Ownership tracking
  original_owner_id UUID REFERENCES users(id),
  ownership_history JSONB DEFAULT '[]',
  current_owner_id UUID REFERENCES users(id),
  
  -- Flags
  is_favorite BOOLEAN DEFAULT false,
  is_milestone_flower BOOLEAN DEFAULT false,
  is_gifted BOOLEAN DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Indexes for performance
CREATE INDEX idx_flowers_user_id ON flowers(user_id);
CREATE INDEX idx_flowers_discovered_at ON flowers(discovered_at DESC);
CREATE INDEX idx_flowers_current_owner ON flowers(current_owner_id);
CREATE INDEX idx_flowers_is_favorite ON flowers(is_favorite);
```

### Flower Transfers Table
```sql
-- Track flower gifting history
CREATE TABLE flower_transfers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flower_id UUID NOT NULL REFERENCES flowers(id) ON DELETE CASCADE,
  from_user_id UUID NOT NULL REFERENCES users(id),
  to_user_id UUID NOT NULL REFERENCES users(id),
  
  -- Transfer details
  transfer_message TEXT,
  transfer_method TEXT DEFAULT 'direct', -- direct, airdrop, link
  
  -- Status
  status TEXT DEFAULT 'pending', -- pending, completed, rejected
  completed_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_transfers_flower_id ON flower_transfers(flower_id);
CREATE INDEX idx_transfers_to_user ON flower_transfers(to_user_id, status);
```

### Daily Schedules Table
```sql
-- Track scheduled daily flowers
CREATE TABLE daily_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  
  -- Status
  status TEXT DEFAULT 'scheduled', -- scheduled, delivered, skipped
  delivered_at TIMESTAMP WITH TIME ZONE,
  flower_id UUID REFERENCES flowers(id),
  
  -- Constraints
  UNIQUE(user_id, scheduled_date)
);
```

### User Relationships Table (for social features)
```sql
-- Following/followers system
CREATE TABLE user_relationships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  -- Prevent duplicate relationships
  UNIQUE(follower_id, following_id),
  
  -- Prevent self-following
  CHECK (follower_id != following_id)
);
```

### Activity Feed Table
```sql
-- For social feed features
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Activity details
  type TEXT NOT NULL, -- discovered, favorited, gifted, received, milestone
  flower_id UUID REFERENCES flowers(id),
  related_user_id UUID REFERENCES users(id),
  
  -- Additional data
  metadata JSONB DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_activities_user_id ON activities(user_id, created_at DESC);
CREATE INDEX idx_activities_type ON activities(type);
```

## 🔐 Row Level Security (RLS)

### Enable RLS on all tables
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE flowers ENABLE ROW LEVEL SECURITY;
ALTER TABLE flower_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
```

### Users Table Policies
```sql
-- Users can read their own profile
CREATE POLICY users_read_own ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can read public profiles
CREATE POLICY users_read_public ON users
  FOR SELECT USING (true); -- Adjust based on privacy needs

-- Users can update their own profile
CREATE POLICY users_update_own ON users
  FOR UPDATE USING (auth.uid() = id);
```

### Flowers Table Policies
```sql
-- Users can read their own flowers
CREATE POLICY flowers_read_own ON flowers
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = current_owner_id);

-- Users can create flowers
CREATE POLICY flowers_create ON flowers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own flowers
CREATE POLICY flowers_update_own ON flowers
  FOR UPDATE USING (auth.uid() = current_owner_id);

-- Public flowers (for feed/discovery)
CREATE POLICY flowers_read_public ON flowers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = flowers.user_id 
      AND users.preferences->>'public_profile' = 'true'
    )
  );
```

## 🌐 Supabase Edge Functions

### Generate Flower Function
```typescript
// supabase/functions/generate-flower/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const openAIKey = Deno.env.get('OPENAI_API_KEY')!
const falKey = Deno.env.get('FAL_API_KEY')!

serve(async (req) => {
  try {
    // Get user from auth header
    const authHeader = req.headers.get('Authorization')!
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )
    
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Unauthorized')
    
    // Check rate limits / subscription
    const { data: profile } = await supabase
      .from('users')
      .select('subscription_status, total_flowers_discovered')
      .eq('id', user.id)
      .single()
    
    // Generate flower with OpenAI
    const flowerData = await generateFlowerWithAI({
      descriptor: req.body.descriptor,
      context: req.body.context
    })
    
    // Generate image with FAL
    const imageUrl = await generateImageWithFAL(flowerData)
    
    // Save to database
    const { data: flower } = await supabase
      .from('flowers')
      .insert({
        user_id: user.id,
        name: flowerData.name,
        descriptor: flowerData.descriptor,
        image_url: imageUrl,
        // ... other fields
      })
      .select()
      .single()
    
    return new Response(JSON.stringify(flower), {
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

### Daily Flower Scheduler
```typescript
// supabase/functions/schedule-daily-flowers/index.ts
// Run this as a cron job daily at midnight

serve(async (req) => {
  const supabase = createClient(...)
  
  // Get all active users
  const { data: users } = await supabase
    .from('users')
    .select('id, preferences')
    .gt('last_seen_at', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)) // Active in last 30 days
  
  for (const user of users) {
    // Calculate random time between 8am and 10:30pm
    const hour = Math.floor(Math.random() * 14.5) + 8
    const minute = Math.floor(Math.random() * 60)
    
    // Schedule flower
    await supabase.from('daily_schedules').insert({
      user_id: user.id,
      scheduled_date: new Date().toISOString().split('T')[0],
      scheduled_time: `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}:00`
    })
  }
})
```

## 🔄 Migration Strategy

### Phase 1: Data Export from Local Storage
```swift
struct MigrationService {
    static func exportLocalData() -> ExportData {
        let flowers = loadFlowersFromUserDefaults()
        let favorites = loadFavoritesFromUserDefaults()
        let settings = loadSettingsFromUserDefaults()
        
        return ExportData(
            flowers: flowers,
            favorites: favorites,
            settings: settings,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )
    }
}
```

### Phase 2: Upload to Supabase
```swift
extension SupabaseManager {
    func migrateUserData(_ exportData: ExportData) async throws {
        // Upload images to Supabase Storage
        for flower in exportData.flowers {
            if let imageData = flower.imageData {
                let imagePath = "flowers/\(flower.id).jpg"
                let imageUrl = try await supabase.storage
                    .from("flower-images")
                    .upload(path: imagePath, data: imageData)
                
                // Create flower record
                try await supabase.from("flowers").insert([
                    "id": flower.id.uuidString,
                    "name": flower.name,
                    "image_url": imageUrl,
                    // ... map other fields
                ])
            }
        }
    }
}
```

### Phase 3: Sync Strategy
```swift
class FlowerStore: ObservableObject {
    private let supabase = SupabaseManager.shared
    
    func saveFlower(_ flower: AIFlower) async {
        // Save locally first (offline support)
        saveToUserDefaults(flower)
        
        // If online and authenticated, sync to Supabase
        if isAuthenticated && isOnline {
            do {
                try await supabase.saveFlower(flower)
            } catch {
                // Queue for later sync
                addToSyncQueue(flower)
            }
        }
    }
}
```

## 💰 Monetization Integration

### Subscription Management
```sql
-- Track subscription events
CREATE TABLE subscription_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  event_type TEXT NOT NULL, -- started, renewed, cancelled, expired
  plan_type TEXT NOT NULL, -- monthly, annual, lifetime
  
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  
  amount INTEGER, -- in cents
  currency TEXT DEFAULT 'usd',
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Usage Tracking
```sql
-- Track API usage for cost management
CREATE TABLE api_usage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  endpoint TEXT NOT NULL, -- openai, fal, etc
  tokens_used INTEGER,
  cost_cents INTEGER,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Daily aggregates for billing
CREATE MATERIALIZED VIEW daily_usage_summary AS
SELECT 
  user_id,
  DATE(created_at) as usage_date,
  SUM(tokens_used) as total_tokens,
  SUM(cost_cents) as total_cost_cents,
  COUNT(*) as api_calls
FROM api_usage
GROUP BY user_id, DATE(created_at);
```

## 🤝 Social Features Schema

### Likes and Comments
```sql
-- Flower reactions
CREATE TABLE flower_likes (
  user_id UUID NOT NULL REFERENCES users(id),
  flower_id UUID NOT NULL REFERENCES flowers(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  PRIMARY KEY (user_id, flower_id)
);

-- Comments on flowers
CREATE TABLE flower_comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flower_id UUID NOT NULL REFERENCES flowers(id),
  user_id UUID NOT NULL REFERENCES users(id),
  
  comment_text TEXT NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);
```

### Collections and Galleries
```sql
-- User-created collections
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  
  name TEXT NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Flowers in collections
CREATE TABLE collection_flowers (
  collection_id UUID NOT NULL REFERENCES collections(id),
  flower_id UUID NOT NULL REFERENCES flowers(id),
  
  added_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  
  PRIMARY KEY (collection_id, flower_id)
);
```

## 📱 iOS Implementation

### Authentication Manager
```swift
import Supabase

class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    func signIn(email: String, password: String) async throws {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        self.user = response.user
        self.isAuthenticated = true
    }
    
    func signInWithApple() async throws {
        // Implement Sign in with Apple
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            options: SignUpOptions(
                data: ["username": username]
            )
        )
        self.user = response.user
    }
}
```

### Offline Support
```swift
class OfflineManager {
    private let syncQueue = OperationQueue()
    
    func queueOperation(_ operation: SyncOperation) {
        // Store in Core Data or SQLite for persistence
        saveToLocalQueue(operation)
        
        // Attempt sync when online
        if NetworkMonitor.shared.isConnected {
            syncQueue.addOperation {
                await self.syncOperation(operation)
            }
        }
    }
    
    func syncPendingOperations() async {
        let pendingOps = loadPendingOperations()
        for op in pendingOps {
            await syncOperation(op)
        }
    }
}
```

## 🚀 Implementation Timeline

### Week 1-2: Foundation
- [ ] Set up Supabase project
- [ ] Create database schema
- [ ] Configure authentication
- [ ] Set up storage buckets
- [ ] Create Edge Functions

### Week 3: iOS Integration
- [ ] Add Supabase SDK
- [ ] Implement AuthManager
- [ ] Create login/signup UI
- [ ] Update FlowerStore for remote data
- [ ] Handle offline scenarios

### Week 4: Migration
- [ ] Build export functionality
- [ ] Create import process
- [ ] Test migration thoroughly
- [ ] Add progress indicators
- [ ] Handle edge cases

### Week 5-6: Social Features
- [ ] User profiles
- [ ] Following system
- [ ] Activity feed
- [ ] Flower gifting
- [ ] Search and discovery

## 📊 Performance Considerations

### Caching Strategy
```swift
class CacheManager {
    private let imageCache = NSCache<NSString, UIImage>()
    private let dataCache = NSCache<NSString, NSData>()
    
    func cacheFlower(_ flower: AIFlower) {
        // Cache image
        if let image = flower.image {
            imageCache.setObject(image, forKey: flower.id.uuidString as NSString)
        }
        
        // Cache data
        if let data = try? JSONEncoder().encode(flower) {
            dataCache.setObject(data as NSData, forKey: flower.id.uuidString as NSString)
        }
    }
}
```

### Optimistic Updates
```swift
func toggleFavorite(flower: AIFlower) async {
    // Update UI immediately
    flower.isFavorite.toggle()
    
    // Sync in background
    Task {
        do {
            try await supabase.from("flowers")
                .update(["is_favorite": flower.isFavorite])
                .eq("id", flower.id)
                .execute()
        } catch {
            // Revert on failure
            flower.isFavorite.toggle()
        }
    }
}
```

## 🔒 Security Best Practices

### API Key Management
- Never expose Supabase service key in client
- Use Edge Functions for sensitive operations
- Implement rate limiting
- Monitor usage patterns

### Data Privacy
- Implement proper RLS policies
- Encrypt sensitive data
- Allow users to export their data
- Provide account deletion option

### Authentication Security
- Enforce strong passwords
- Implement 2FA option
- Use secure session management
- Monitor for suspicious activity

## 💡 Recommendations

### Start Simple
1. **Phase 1**: Optional accounts with basic sync
2. **Phase 2**: Social features for logged-in users
3. **Phase 3**: Premium subscriptions
4. **Phase 4**: Advanced social features

### Maintain Local-First
- Keep app functional offline
- Sync when connection available
- Don't gate core features behind login
- Preserve current user experience

### Progressive Enhancement
- Add features gradually
- Test with small user group
- Monitor performance impact
- Gather user feedback

## 🎯 Success Metrics

### Technical Metrics
- Sync success rate > 99%
- API response time < 200ms
- Offline capability maintained
- Zero data loss during migration

### Business Metrics
- Account creation rate
- User retention
- Premium conversion rate
- Social engagement metrics

---

*Remember: The goal is to enhance the Flowers experience with connectivity while preserving its core simplicity and charm.* 