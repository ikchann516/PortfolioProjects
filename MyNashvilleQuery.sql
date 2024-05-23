--Data Cleaning Process

Select *
From PortfolioProject..MyNashvilleData


--Standardize Date Format

Select SaleDate, SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..MyNashvilleData

Update MyNashvilleData
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE MyNashVilleData
Add SaleDateConverted Date;

Update MyNashvilleData
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Working on the PropertyAddress

Select *
From PortfolioProject..MyNashvilleData
Where PropertyAddress is null

Select d1.ParcelID, d1.PropertyAddress, d2.ParcelID, d2.PropertyAddress, ISNULL(d1.PropertyAddress, d2.PropertyAddress)
From PortfolioProject..MyNashvilleData d1
JOIN PortfolioProject..MyNashvilleData d2
 on d1.ParcelID = d2.ParcelID
 AND d1.[UniqueID ]<> d2.[UniqueID ]
--Where d1.PropertyAddress is null

Update d1
SET PropertyAddress = ISNULL(d1.PropertyAddress, d2.PropertyAddress)
From PortfolioProject..MyNashvilleData d1
JOIN PortfolioProject..MyNashvilleData d2
 on d1.ParcelID = d2.ParcelID
 AND d1.[UniqueID ]<> d2.[UniqueID ]
Where d1.PropertyAddress is null


--Breaking out the address

Select PropertyAddress
From PortfolioProject..MyNashvilleData

Select PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address2
From PortfolioProject..MyNashvilleData

ALTER TABLE MyNashVilleData
Add PropertySplitAddress nvarchar(255);

Update MyNashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE MyNashVilleData
Add PropertySplitCity nvarchar(255);

Update MyNashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject..MyNashvilleData


Select OwnerAddress
From PortfolioProject..MyNashvilleData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject..MyNashvilleData

ALTER TABLE MyNashVilleData
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE MyNashVilleData
Add OwnerSplitCity nvarchar(255);

ALTER TABLE MyNashVilleData
Add OwnerSplitState nvarchar(255);

Update MyNashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Update MyNashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Update MyNashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProject..MyNashvilleData


--SoldAsVacant Cleaning

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..MyNashvilleData
Group by SoldAsVacant

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'N' THEN 'No'
	   WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..MyNashvilleData

Update MyNashvilleData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
						END


--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From PortfolioProject..MyNashvilleData
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--Delete Unused Columns

Select *
From PortfolioProject..MyNashvilleData

ALTER TABLE PortfolioProject..MyNashvilleData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
