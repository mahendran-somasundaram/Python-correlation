---Cleaning the Data in Sql Queries:-

Select * from 
[portfolio project].dbo.[Nashville Housing]

---------------------------------------------------------------
---Standardize the Date Format

Select SaleDate from 
[portfolio project].dbo.[Nashville Housing]


select SaleDateConverted , CONVERT(date,SaleDate)
from [portfolio project]..[Nashville Housing]

update [Nashville Housing]
set SaleDate= CONVERT(date,SaleDate)

Alter table [Nashville Housing]
add SaleDateConverted Date;

update [Nashville Housing]
set SaleDateConverted = CONVERT(date,SaleDate)



----Populate Property Address Data


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.propertyaddress,b.PropertyAddress)
from [portfolio project]..[Nashville Housing] a
join [portfolio project]..[Nashville Housing] b
on a.ParcelID = b.ParcelID
and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set a.propertyaddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from [portfolio project]..[Nashville Housing] a
join [portfolio project]..[Nashville Housing] b
on a.ParcelID = b.ParcelID
and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----Breaking out address into individual Columns ( Address, city, state)

select propertyaddress
from [portfolio project]..[Nashville Housing]

select 
SUBSTRING(propertyaddress,0,CHARINDEX(',',propertyaddress)) as address, propertyaddress,
SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) as address
from [portfolio project]..[Nashville Housing]
 

 alter table [Nashville Housing]
  add propertysplitaddress nvarchar(255);

alter table [Nashville Housing]
add propertysplitcity nvarchar(255);

update [Nashville Housing]
set propertysplitaddress = SUBSTRING(propertyaddress,0,CHARINDEX(',',propertyaddress))

update [Nashville Housing]
set propertysplitcity =  SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress))


select owneraddress 
from [portfolio project]..[Nashville Housing]

select 
PARSENAME(Replace(owneraddress,',','.'),3),
PARSENAME(Replace(owneraddress,',','.'),2),
PARSENAME(Replace(owneraddress,',','.'),1)
from [portfolio project]..[Nashville Housing]


alter table [Nashville Housing]
add ownersplitaddress nvarchar(255);


alter table [Nashville Housing]
add ownersplitcity nvarchar(255);


alter table [Nashville Housing]
add ownersplitstate nvarchar(255);

update [Nashville Housing]
set  ownersplitaddress= PARSENAME(Replace(owneraddress,',','.'),3)
update [Nashville Housing]
set ownersplitcity = PARSENAME(Replace(owneraddress,',','.'),2)
update [Nashville Housing]
set ownersplitstate= PARSENAME(Replace(owneraddress,',','.'),1)



 ---Change Y and N to Yes and No in the "Sold as Vacant" Filed

 select distinct(SoldAsVacant), COUNT(soldasvacant)
 from [portfolio project]..[Nashville Housing]
 group by SoldAsVacant
 order by 2

 select Soldasvacant,
 case when soldasvacant ='Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end
from [portfolio project]..[Nashville Housing]


update [portfolio project]..[Nashville Housing]
set soldasvacant = case when soldasvacant ='Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end


------Remove Duplicates

with RowNumCTE as (

select *,
ROW_NUMBER() over(
PARTITION by parcelid,
             propertyAddress,
			 SalePrice,
			 LegalReference
			 order by
			  uniqueid
			  ) row_num
from [portfolio project]..[Nashville Housing]
)
select * from RowNumCTE
where row_num >1

---Delete Unused Columns

alter table [portfolio project]..[Nashville Housing]
drop column owneraddress,taxdistrict,propertyaddress

alter table [portfolio project]..[Nashville Housing]
drop column Saledate