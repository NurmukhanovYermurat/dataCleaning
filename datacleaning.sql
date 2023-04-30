select * from houses.nashville
order by ParcelID;

select * from houses.nashville
where PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from houses.nashville as a
join houses.nashville as b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

UPDATE houses.nashville AS a
JOIN houses.nashville AS b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

select substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, locate(',', PropertyAddress)+1,length(PropertyAddress))
from houses.nashville

alter table houses.nashville
add SplitAdress nvarchar(255);

update houses.nashville
set SplitAdress = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1);

alter table houses.nashville
add SplitCity nvarchar(255);

update houses.nashville
set SplitCity = substring(PropertyAddress, locate(',', PropertyAddress)+1,length(PropertyAddress));

select * from houses.nashville;

select OwnerAddress from houses.nashville;

select substring_index(replace(OwnerAddress,',','.'),'.',1), TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)), substring_index(replace(OwnerAddress,',','.'),'.',-1)
from houses.nashville;

alter table houses.nashville                                                                         
add OwnerSplitAddress nvarchar(255);
                                                                                                     
update houses.nashville                                                                              
set OwnerSplitAddress = substring_index(replace(OwnerAddress,',','.'),'.',1);

alter table houses.nashville
add OwnerSplitState nvarchar(255);

update houses.nashville
set OwnerSplitState = substring_index(replace(OwnerAddress,',','.'),'.',-1);

alter table houses.nashville
add OwnerSplitCity nvarchar(255);

update houses.nashville
set OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

select distinct(SoldAsVacant), count(SoldAsVacant) from houses.nashville
group by SoldAsVacant
order by 2;

select SoldAsVacant, case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end
from houses.nashville;

update houses.nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant                
    end;

with RowNumCTE as (
  select *,
         row_number() over (
           partition by ParcelID,
               PropertyAddress,
               SalePrice,
               SaleDate
           order by UniqueID) row_num
  from houses.nashville
)
delete from houses.nashville
where UniqueID in (
  select UniqueID
  from RowNumCTE
  where row_num > 1);


alter table houses.nashville
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;

alter table houses.nashville
drop column SaleDate;

select * from houses.nashville
