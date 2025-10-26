CREATE TABLE restaurants (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    BusinessName VARCHAR(255),
    Address VARCHAR(1024),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6)
);

INSERT INTO restaurants (BusinessName, Address, Longitude, Latitude)
SELECT 
    BusinessName, 
    CONCAT_WS(' ', AddressLine1, AddressLine2, AddressLine3, AddressLine4) AS Address,
    Longitude,
    Latitude
FROM fhrs_raw
WHERE Longitude IS NOT NULL AND Latitude IS NOT NULL;
