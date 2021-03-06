--ETL Script

Use DWService

--drop foreign keys
Alter Table dbo.DimLocation Drop CONSTRAINT [FK_DimLocation_DimCity]

Alter Table dbo.FactTrips Drop CONSTRAINT [FK_FactTrips_DimLocation]

Alter Table dbo.FactTrips Drop CONSTRAINT [FK_FactTrips_DimDates]

Alter Table dbo.FactTrips Drop CONSTRAINT [FK_FactTrips_DimDriver] 

--Clear all tables
Use DWService
Truncate table dbo.DimDriver
Truncate table dbo.DimDates
Truncate table dbo.DimLocation
Truncate table dbo.DimCity
Truncate table dbo.FactTrips


-- Dim Date
declare @startDate datetime = '01/01/2010'
declare @endDate datetime = '12/31/2012'
declare @dateInProcess datetime = @startDate
--loop
--insert a record into dimDate using @dateInProcess
-- increase the @dateInProcss by one day
-- until @dateInProcss == @endDate
While (@dateInProcess <= @endDate)
Begin

--SET IDENTITY_INSERT [dbo].[DimDates] ON


insert into dbo.DimDates
values(
@dateInProcess, 
convert (varchar, @dateInProcess, 110) + ',' + DATENAME(weekday, @dateInProcess),
month(@dateInProcess),
DateName(month, @dateinprocess),
year(@dateInProcess),
'Year' + CONVERT(nchar(4),year(@dateInProcess))
)
set @dateInProcess = DateAdd(d, 1, @dateInProcess)
End

--SET IDENTITY_INSERT [dbo].[DimDates] OFF

--Star schema dimension
Insert into DWService.dbo.DimDriver
SELECT 
DriverID = CAST(Driver_Id as nchar(5)),
LastName = CAST (LastName as nchar(50)),
FirstName = CAST ([FirstName] as nchar(50))
FROM [serviceDB].[dbo].[Driver]

--Snowflake
Insert into DWService.dbo.DimCity
Select 
CityId
= CAST(City_Code as nchar(5)),
CityName = CAST(CountryName as nchar(50))
FROM [serviceDB].[dbo].[City]

Insert into DWService.dbo.DimLocation
Select  
CityKey = CityKey ,
StreetId = CAST(Street_Code as nchar(10)),
Street = CAST(StreetName as nchar(50))

FROM [serviceDB].[dbo].[Street] 
--Join [DWService].[dbo].[DimLocation] 
--ON [serviceDB].[dbo].[Street].Street_Code = [DWService].[dbo].[DimLocation].StreetId 
JOIN [DWService].[dbo].[DimCity] 
On [serviceDB].[dbo].[Street].City_Code = [DWService].[dbo].[DimCity].CityId


Insert into DWService.dbo.FactTrips
SELECT 
TripNumber= cast (number as nvarchar(50)),
DateKey = [DWService].dbo.DimDates.DateKey,
LocationKey = [DWService].dbo.DimLocation.LocationKey,
DriverKey = [DWService].dbo.DimDriver.DriverKey,
TripMileage = cast (milage as decimal(18,4)),
TripCharge = cast (charge as decimal(18,4))
From [serviceDB].[dbo].Trip
Join [DWService].dbo.DimLocation 
on Street_Code = [DWService].dbo.DimLocation.StreetId
Join [DWService].dbo.DimDates
on [serviceDB].dbo.Trip.[Date] = [DWService].dbo.DimDates.[Date]
Join [DWService].dbo.DimDriver 
on Driver_Id = [DWService].dbo.DimDriver.DriverId
where milage is not null
Go
-- Create foreign keys
Alter Table dbo.FactTrips WITH CHECK ADD 
CONSTRAINT [FK_FactTrips_DimDriver]
FOREIGN KEY (DriverKey) REFERENCES dbo.DimDriver (DriverKey)

Alter Table dbo.FactTrips WITH CHECK ADD 
CONSTRAINT [FK_FactTrips_DimLocation]
FOREIGN KEY (LocationKey) REFERENCES dbo.DimLocation (LocationKey)

Alter Table dbo.FactTrips WITH CHECK ADD 
CONSTRAINT [FK_FactTrips_DimDates]
FOREIGN KEY (DateKey) REFERENCES dbo.DimDates (DateKey)

ALTER TABLE dbo.DimLocation WITH CHECK
ADD CONSTRAINT [FK_DimLocation_DimCity]
FOREIGN KEY (CityKey) REFERENCES dbo.DimCity(CityKey)