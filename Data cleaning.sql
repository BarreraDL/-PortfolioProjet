									--Nettoyage de données avec SQL
select *
from PortfolioProjet..Nashville
	
	--Standardiser les dates de ventes 
select SaleDateModifier, CONVERT (Date,SaleDate)
from PortfolioProjet..Nashville

Update Nashville
set SaleDate=convert (date,SaleDate)

alter table  Nashville
add SaleDateModifier date;

Update Nashville
set SaleDateModifier=convert (date,SaleDate)


-- Maison sans adresse 

select PropertyAddress
from PortfolioProjet..Nashville
where PropertyAddress is null
	-- beaucoup de null
select *
from PortfolioProjet..Nashville
where PropertyAddress is null

select *
from PortfolioProjet..Nashville
order by ParcelID --On remarque que le ParcelID  identifie les adresse .
				  --Donc si adresse = NULL et nous avons le ParcelID , nous pouvons trouver l'adresse

select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)-- ISNULL va ajouter ladrrese requise 
from PortfolioProjet..Nashville a
join PortfolioProjet..Nashville b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] -- pas le meme Unique ID
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjet..Nashville a
join PortfolioProjet..Nashville b
on a.ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
					
	--- Nous permet de valider qu’ il y a aucune adresse null
	select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)-- ISNULL va ajouter ladrrese requise 
	from PortfolioProjet..Nashville a
	join PortfolioProjet..Nashville b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] -- pas le meme Unique ID
	where a.PropertyAddress is null



--- diviser le PropertyAddres (adrrese , ville , State)
select PropertyAddress
from PortfolioProjet..Nashville

select 
SUBSTRING(PropertyAddress, 1, charindex (',',PropertyAddress)-1) as Address-- nous pas le "," dans notre adresse , le -1 nous permet de l'enlver 
, SUBSTRING(PropertyAddress,charindex (',',PropertyAddress)+1  , len (PropertyAddress)) as Address
from PortfolioProjet..Nashville

alter table  Nashville
add PropertySplitAdress  Nvarchar(255);

Update Nashville
set PropertySplitAdress =SUBSTRING(PropertyAddress, 1, charindex (',',PropertyAddress)-1)


alter table  Nashville
add PropertySplitVille  Nvarchar(255);

Update Nashville
set PropertySplitVille =SUBSTRING(PropertyAddress,charindex (',',PropertyAddress)+1  , len (PropertyAddress))


	-- nous permet de voir que la colonne est ajouter 
select *
from PortfolioProjet..Nashville


-- changer le Y et N pour Yes et No dans la colonne SoldasVacant 

select Distinct	(SoldAsVacant)
from PortfolioProjet..Nashville
		--permet de voir combien il y a de Y, N , Yes , No
select Distinct	(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProjet..Nashville
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant='Y'  then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant 
		end 
from PortfolioProjet..Nashville

update PortfolioProjet..Nashville
set SoldAsVacant = case when SoldAsVacant='Y'  then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant 
		end 
	-- pour voir si cela  fonctionne 
	select Distinct	(SoldAsVacant),COUNT(SoldAsVacant)
	from PortfolioProjet..Nashville
	group by SoldAsVacant
	order by 2

-- enlever  les "duplicates"

with RowNumCTE as (
select *,
row_number() over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			LegalReference
			order by
			UniqueID
				) row_num
from PortfolioProjet..Nashville  )
--order by ParcelI

select *
from RowNumCTE
where row_num >1
order by PropertyAddress

 --- effacer 
 with RowNumCTE as (
select *,
row_number() over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			LegalReference
			order by
			UniqueID
				) row_num
from PortfolioProjet..Nashville  )
--order by ParcelI

delete from RowNumCTE
where row_num >1
--order by PropertyAddress
		
	-- regarder si ya encore des "duplicates"
	with RowNumCTE as (
select *,
row_number() over (
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			LegalReference
			order by
			UniqueID
				) row_num
from PortfolioProjet..Nashville  )
--order by ParcelI

select *
from RowNumCTE
where row_num >1
order by PropertyAddress


--effacer les colonnes inutilisées
select *
from PortfolioProjet..Nashville

alter table PortfolioProjet..Nashville  
drop column OwnerAddress