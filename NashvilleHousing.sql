/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) as DateSale
FROM PortfolioProject.dbo.NashvilleHousing

--UPDATE Portfolioproject.dbo.NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From portfolioproject.dbo.NashvilleHousing

----------------------------------------------------------------------
-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.Parcelid
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing AS a
JOIN PortfolioProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.Parcelid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
-- order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyaddress)) AS address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);


UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update Portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
FROM portfolioproject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS CITY,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM portfolioproject..NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerPropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerPropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerPropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerPropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerPropertySplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerPropertySplitState = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


-- change y and n to yes and no in "sold as vacant" field

SELECT DISTINCT SoldAsVacant, count(soldasvacant)
FROM Portfolioproject.dbo.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant =  'Y' THEN 'YES'
	WHEN soldasvacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM Portfolioproject.dbo.nashvillehousing


Update NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant =  'Y' THEN 'YES'
	WHEN soldasvacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM Portfolioproject.dbo.nashvillehousing

-----------------------------------------------------------------------
-- remove duplicates

WITH RowNumCTE AS(
SELECT *, 
	row_number() over(partition by 
	parcelid, propertyaddress, saleprice, saledate, legalreference 
	ORDER BY 
		UniqueID
		) row_num
FROM Portfolioproject.dbo.nashvillehousing
--order by parcelid
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- delete unused columns


Select * 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
