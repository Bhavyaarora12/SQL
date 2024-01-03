select * from dbo.housing

--standardize
select saledate ,CONVERT(date,saledate) as sale_date
from housing

select propertyaddress from housing where PropertyAddress is null;

--Retrieve the first 10 records from the dataset.
SELECT top 10  * FROM housing

--Identify the total number of records in the dataset.
SELECT COUNT(*) AS total_records
FROM housing;

--Find the number of unique LandUse categories.
SELECT COUNT(DISTINCT LandUse) AS unique_land_use_categories
FROM housing;

--Remove duplicates from the dataset based on ParcelID.
WITH deduplicated_data AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY ParcelID ORDER BY UniqueID) AS row_num
  FROM housing
)
SELECT *
FROM deduplicated_data
WHERE row_num = 1;

--Fill missing values in the FullBath and HalfBath columns with zeros.
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice,
       LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage,
       TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt,
       COALESCE(Bedrooms, 0) AS Bedrooms,
       COALESCE(FullBath, 0) AS FullBath,
       COALESCE(HalfBath, 0) AS HalfBath
FROM housing;

--Create a new column indicating whether the property has a bathroom (FullBath or HalfBath > 0).
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice,
       LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage,
       TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt,
       Bedrooms, FullBath, HalfBath,
       CASE WHEN FullBath > 0 OR HalfBath > 0 THEN 1 ELSE 0 END AS HasBathroom
FROM housing;

--Calculate the average SalePrice per LandUse category.
SELECT LandUse, AVG(SalePrice) AS avg_sale_price
FROM housing
GROUP BY LandUse;

--Calculate the moving average of SalePrice over a 3-day window for each UniqueID.
SELECT UniqueID, SaleDate, SalePrice,
       AVG(SalePrice) OVER (PARTITION BY UniqueID ORDER BY SaleDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_sale_price
FROM housing;

--Implement data validation checks for unrealistic values in Acreage, Bedrooms, or other relevant columns.
SELECT *
FROM housing
WHERE Acreage >= 0 AND Bedrooms >= 0;












