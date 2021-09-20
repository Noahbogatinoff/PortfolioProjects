# Create Housing table
CREATE TABLE housing (
	id INT, 
    parcel_id VARCHAR(255), 
    acerage VARCHAR (255), 
    land_use VARCHAR(255), 
    property_address VARCHAR(255), 
    sale_date DATE, 
    sale_price VARCHAR(255), 
    legal_reference VARCHAR(255), 
    sold_vacant VARCHAR(255), 
    owner_name VARCHAR(255),
    owner_address VARCHAR(255),
    tax_dist VARCHAR(255),
    land_val VARCHAR(255),
    building_val VARCHAR(255),
    total_val VARCHAR(255),
    year_built VARCHAR(255),
    bedrooms VARCHAR(255),
	full_bath VARCHAR(255),
	half_bath VARCHAR(255))

# Converted sale_date in .csv file to "YYYY-MM-DD" date format
# Imported data from dataset

-- --------------------------------------------------------

# Populate Property Address Data

SELECT a.parcel_id,
	a.property_address,
	b.parcel_id,
    b.property_address,
    IFNULL(a.property_address, b.property_address)
FROM housing a
JOIN housing b
	ON a.parcel_id = b.parcel_id
	AND a.id != b.id
WHERE a.property_address IS NULL;

UPDATE housing a, housing b 
SET b.property_address = a.property_address
WHERE b.property_address IS NULL
	AND b.parcel_id = a.parcel_id
	AND a.property_address IS NOT NULL;
    
-- --------------------------------------------------------
    
# Seperate Property Address into different columns (Address, City)

SELECT SUBSTRING(property_address, 1, LOCATE(',',property_address)-1) AS 'Address',
SUBSTRING(property_address, LOCATE(',',property_address)+1, LENGTH(property_address)) AS 'Address 2'
FROM housing;

ALTER TABLE housing
ADD propertysplit_address VARCHAR (255),
ADD propertysplit_city VARCHAR(255);

UPDATE housing
SET propertysplit_address = SUBSTRING(property_address, 1, LOCATE(',',property_address)-1), 
	propertysplit_city = SUBSTRING(property_address, LOCATE(',',property_address)+1, LENGTH(property_address));


-- --------------------------------------------------------
    
# Seperate Owner Address into different columns (Address, City, State)

SELECT 
SUBSTRING_INDEX(owner_address, ',',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', 2), ',',-1),
SUBSTRING_INDEX(owner_address, ',',-1)
FROM housing;

ALTER TABLE housing
ADD ownersplit_address VARCHAR (255),
ADD	ownersplit_city VARCHAR (255),
ADD	ownersplit_state VARCHAR (255);

UPDATE housing
SET ownersplit_address = SUBSTRING_INDEX(owner_address, ',',1),
	ownersplit_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owner_address, ',', 2), ',',-1),
	ownersplit_state = SUBSTRING_INDEX(owner_address, ',',-1);
    
-- --------------------------------------------------------
    
# Change Y and N in "Sold as Vacant" column

SELECT DISTINCT (sold_vacant), COUNT(sold_vacant)
FROM housing
GROUP BY sold_vacant
ORDER BY 2;

SELECT sold_vacant,
	CASE
		WHEN sold_vacant = 'Y' THEN 'Yes'
        WHEN sold_vacant = 'N' THEN 'No'
        ELSE sold_vacant 
	END
FROM housing;

UPDATE housing
SET sold_vacant = (CASE
		WHEN sold_vacant = 'Y' THEN 'Yes'
        WHEN sold_vacant = 'N' THEN 'No'
        ELSE sold_vacant 
	END);
    
-- --------------------------------------------------------
    
# Removing Duplicates (IF NEEDED)

WITH row_num_cte AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY parcel_id,
		property_address,
        sale_price,
        sale_date,
        legal_reference
        ORDER BY
			id
            ) row_num
FROM housing
)
DELETE
FROM housing USING housing JOIN row_num_cte ON housing.id = row_num_cte.id
WHERE row_num > 1;

-- --------------------------------------------------------
    
# Remove Unused Columns (IF NEEDED)

ALTER TABLE housing
DROP property_address, 
DROP owner_address, 
DROP tax_dist

