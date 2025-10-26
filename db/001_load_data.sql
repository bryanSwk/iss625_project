CREATE DATABASE ISS625_A2;
USE ISS625_A2;

CREATE TABLE fhrs_raw (
    ExtractDate VARCHAR(50),
    ItemCount VARCHAR(50),
    ReturnCode VARCHAR(50),
    FHRSID INT,
    LocalAuthorityBusinessID VARCHAR(100),
    BusinessName VARCHAR(255),
    BusinessType VARCHAR(255),
    BusinessTypeID INT,
    RatingValue VARCHAR(50),
    RatingKey VARCHAR(50),
    RatingDate VARCHAR(50),
    LocalAuthorityCode VARCHAR(50),
    LocalAuthorityName VARCHAR(255),
    LocalAuthorityWebSite VARCHAR(255),
    LocalAuthorityEmailAddress VARCHAR(255),
    Hygiene VARCHAR(50),
    Structural VARCHAR(50),
    ConfidenceInManagement VARCHAR(50),
    SchemeType VARCHAR(50),
    NewRatingPending VARCHAR(10),
    Longitude DECIMAL(10,6),
    Latitude DECIMAL(10,6),
    AddressLine1 VARCHAR(255),
    AddressLine2 VARCHAR(255),
    AddressLine3 VARCHAR(255),
    AddressLine4 VARCHAR(255),
    PostCode VARCHAR(20),
    RightToReply TEXT
);

LOAD DATA LOCAL INFILE '/Users/bryan/Downloads/all-FHRS-GB-16-oct-2021-extract.csv'
INTO TABLE fhrs_raw
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    ExtractDate, ItemCount, ReturnCode, FHRSID, LocalAuthorityBusinessID, BusinessName,
    BusinessType, BusinessTypeID, RatingValue, RatingKey, RatingDate, LocalAuthorityCode,
    LocalAuthorityName, LocalAuthorityWebSite, LocalAuthorityEmailAddress, Hygiene,
    Structural, ConfidenceInManagement, SchemeType, NewRatingPending, Longitude, Latitude,
    AddressLine1, AddressLine2, AddressLine3, AddressLine4, PostCode, RightToReply
);
