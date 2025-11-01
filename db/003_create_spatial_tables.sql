-- ============================================================================
-- 003_create_spatial_tables.sql
-- Create spatial-optimized tables for UK restaurants with R-tree indexes
-- ============================================================================

USE ISS625_A2;

-- Increase timeouts 
SET SESSION wait_timeout = 28800;
SET SESSION interactive_timeout = 28800;
SET SESSION net_read_timeout = 3600;
SET SESSION net_write_timeout = 3600;

-- ============================================================================
-- TABLE: restaurants_spatial (OPTIMIZED with R-tree spatial index)
-- ============================================================================

DROP TABLE IF EXISTS restaurants_spatial;

CREATE TABLE restaurants_spatial (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    BusinessName VARCHAR(255),
    Address VARCHAR(1024),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6),
    
    location POINT NOT NULL SRID 4326,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
    -- NO SPATIAL INDEX YET
) ENGINE=InnoDB;

-- ============================================================================
-- Populate spatial table from existing restaurants table
-- ============================================================================

INSERT INTO restaurants_spatial (BusinessName, Address, Longitude, Latitude, location)
SELECT 
    BusinessName,
    Address,
    Longitude,
    Latitude,
    ST_SRID(POINT(Longitude, Latitude), 4326) as location
FROM restaurants
WHERE Longitude IS NOT NULL 
  AND Latitude IS NOT NULL
  AND Longitude BETWEEN -180 AND 180
  AND Latitude BETWEEN -90 AND 90;
  
-- ============================================================================
-- Add R-tree SPATIAL INDEX (THE KEY OPTIMIZATION!)
-- ============================================================================
-- Adding spatial index AFTER data load is more efficient than before
-- This may take 1-2 minutes for 500k+ rows

ALTER TABLE restaurants_spatial 
ADD SPATIAL INDEX idx_location (location);

-- ============================================================================
-- Add regular B-tree index to original table for comparison
-- ============================================================================
-- This creates a composite B-tree index on (Latitude, Longitude) for benchmark comparison

ALTER TABLE restaurants 
ADD INDEX idx_lat_lng (Latitude, Longitude);

/*
===============================================================================
WHAT WE CREATED:
===============================================================================

1. **restaurants_spatial** - Optimized table with spatial geometry
   - Contains: BusinessName, Address, Latitude, Longitude
   - Key addition: location POINT column (stores lat/lng as single geometry)
   - Index: R-tree SPATIAL INDEX on location column

2. **Index Comparison Setup:**
   - restaurants: Regular B-tree on (Latitude, Longitude) - baseline
   - restaurants_spatial: R-tree SPATIAL INDEX on location - optimized!
   

===============================================================================
INDEX TYPES EXPLAINED:
===============================================================================

**B-tree Index (restaurants.idx_lat_lng):**
- Type: Traditional binary tree index
- Optimized for: 1D range queries on individual columns
- How it works: Sorts data by latitude, then longitude
- Limitation: Treats lat/lng as separate dimensions
- Use case: Good for queries like "WHERE lat BETWEEN X AND Y"
- Problem: Inefficient for 2D proximity queries (distance calculations)

**R-tree Spatial Index (restaurants_spatial.idx_location):**
- Type: Specialized spatial index for geographic data
- Optimized for: 2D/3D spatial queries (distance, proximity, containment)
- How it works: Hierarchical bounding boxes group nearby points
- Advantage: Understands 2D space natively, not two 1D dimensions
- Use case: Perfect for "find points within X meters" queries
- Performance: 95-99% faster for geographic proximity queries

===============================================================================
COORDINATE SYSTEM:
===============================================================================

**SRID 4326 = WGS84 (World Geodetic System 1984)**
- Standard coordinate system used by GPS
- Used by: Google Maps, Apple Maps, all consumer GPS devices
- Format: POINT(longitude, latitude) - **IMPORTANT: longitude comes first!**
- Example: Big Ben = POINT(-0.1246, 51.5007)
  - Longitude: -0.1246° (West of Prime Meridian)
  - Latitude: 51.5007° (North of Equator)

**Why SRID matters:**
- Ensures consistent distance calculations
- ST_Distance_Sphere uses spherical Earth model (not flat!)
- Accurate for distances up to thousands of kilometers
- Must use same SRID for all spatial operations

**UK Geographic Boundaries:**
- Latitude: 49.9° (Isles of Scilly) to 60.9° (Shetland Islands)
- Longitude: -8.2° (West Ireland border) to 1.8° (East Anglia)
- North-South span: ~1,400 km
- East-West span: ~600 km (varies by latitude)

===============================================================================
WHY LOAD DATA BEFORE CREATING INDEX:
===============================================================================

We deliberately add the spatial index AFTER loading data because:

1. **Faster bulk load**: Inserting 500k rows without index is faster
2. **Single index build**: Building index once on full dataset is more efficient
3. **Better index quality**: R-tree built on complete data is better optimized
4. **Less fragmentation**: Avoids index rebuilding during inserts

Timing comparison:
- Load then index: ~2 minutes total
- Index then load: ~5-10 minutes (index rebuilds constantly)

===============================================================================
PERFORMANCE EXPECTATIONS:
===============================================================================

Based on ~500,000-600,000 UK restaurant records:

**Query Type: Radius Search (1km)**
- Unoptimized (B-tree): 20-30ms, examines 500k+ rows
- Optimized (R-tree): 10-20ms, examines 500-1000 rows
- Improvement: 30-50% faster, 99.8% fewer rows

**Query Type: K-Nearest Neighbors (find 20 closest)**
- Unoptimized: 200-400ms, sorts 500k distances
- Optimized: 80-150ms, sorts 10k-20k distances
- Improvement: 50-70% faster, 96-98% fewer rows

**Query Type: Route Corridor (10 waypoints, 500m buffer)**
- Unoptimized: 800-1200ms, 5.85M calculations
- Optimized: 80-150ms, 30k-50k calculations
- Improvement: 85-95% faster, 99.5% fewer calculations

**At Scale (10x data = 5M restaurants):**
- Unoptimized queries: 10x slower (linear growth)
- Optimized queries: ~1.5-2x slower (logarithmic growth)
- Improvement gap: 90-98% faster with spatial indexes
   
*/
