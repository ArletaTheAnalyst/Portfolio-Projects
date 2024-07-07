DROP TABLE IF EXISTS Nashville_data

CREATE TABLE Nashville_data (
UniqueID numeric,
ParcelID	nvarchar(255) NULL,
LandUse	varchar(255),
PropertyAddress	varchar(255),
SaleDate	varchar(255),
SalePrice	nvarchar(255) NULL,
LegalReference	nvarchar(255) NULL,
SoldAsVacant varchar(50),
OwnerName	varchar(255),
OwnerAddress	varchar(255),
Acreage	varchar(50),
TaxDistrict	varchar(255),
LandValue	varchar(50),
BuildingValue	varchar(50),
TotalValue	varchar(50),
YearBuilt	varchar(50),
Bedrooms	varchar(50),
FullBath	varchar(50),
HalfBath NUMERIC
)

BULK INSERT Nashville_data
    FROM 'C:\Users\Dell\Desktop\Nashville Housing Data for Data Cleaning.csv'
    WITH
    (
    FORMAT='CSV',
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    ROWTERMINATOR = '0x0a'

)
GO



UPDATE dbo.Nashville_data
SET SaleDate = REPLACE(SaleDate, 'stycze+ä', 'January')
SET SaleDate REPLACE(SaleDate, 'luty', 'February')
SET SaleDate = REPLACE(SaleDate, 'marzec', 'March')
SET SaleDate = REPLACE(SaleDate, 'kwiecie+ä', 'April')
SET SaleDate = REPLACE(SaleDate, 'maj', 'May')
SET SaleDate = REPLACE(SaleDate, 'czerwiec', 'June')
SET SaleDate = REPLACE(SaleDate, 'lipiec', 'July')
SET SaleDate = REPLACE(SaleDate, 'sierpie+ä', 'August')
SET SaleDate = REPLACE(SaleDate, 'wrzesie+ä', 'September')
SET SaleDate = REPLACE(SaleDate, 'pa+¦dziernik', 'October')
SET SaleDate = REPLACE(SaleDate, 'listopad', 'November')
SET SaleDate = REPLACE(SaleDate, 'grudzie+ä', 'December')


SELECT *
FROM dbo.Nashville_data

SELECT SaleDate
FROM dbo.Nashville_data


SELECT SaleDate, CONVERT(date, SaleDate) AS Date
FROM dbo.Nashville_data

ALTER TABLE dbo.Nashville_data
Add SaleDateConverted Date;

UPDATE dbo.Nashville_data
SET SaleDate = CONVERT(date, SaleDate)


SELECT *
FROM dbo.Nashville_data
WHERE PropertyAddress is NULL

SELECT *
FROM dbo.Nashville_data
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville_data a
JOIN dbo.Nashville_data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.UniqueID
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Nashville_data a
JOIN dbo.Nashville_data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.UniqueID
WHERE a.PropertyAddress is NULL


SELECT PropertyAddress
FROM dbo.Nashville_data
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.Nashville_data


ALTER TABLE dbo.Nashville_data
Add PropertySplitAddress Nvarchar(255); 

UPDATE dbo.Nashville_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE dbo.Nashville_data
Add PropertySplitCity Nvarchar(255); 

UPDATE dbo.Nashville_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM dbo.Nashville_data


SELECT OwnerAddress
FROM dbo.Nashville_data


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.Nashville_data



ALTER TABLE dbo.Nashville_data
Add OwnerSplitAddress Nvarchar(255); 

UPDATE dbo.Nashville_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE dbo.Nashville_data
Add OwnerSplitCity Nvarchar(255); 

UPDATE dbo.Nashville_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE dbo.Nashville_data
Add OwnerSplitState Nvarchar(255); 

UPDATE dbo.Nashville_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM dbo.Nashville_data


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.Nashville_data
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM dbo.Nashville_data


UPDATE Nashville_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

WITH Row_numCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID) row_num
FROM dbo.Nashville_data
--ORDER BY ParcelID
)
--DELETE
SELECT *
FROM Row_numCTE 
WHERE Row_num > 1
--Order by PropertyAddress



SELECT *
FROM dbo.Nashville_data

ALTER TABLE dbo.Nashville_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.Nashville_data
DROP COLUMN SaleDate