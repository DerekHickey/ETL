USE master

IF EXISTS (SELECT name FROM sys.databases WHERE name ='DWService')
BEGIN
 ALTER DATABASE DWService SET SINGLE_USER WITH ROLLBACK IMMEDIATE
 DROP DATABASE DWService
END
GO

CREATE DATABASE DWService 
GO

USE DWService

-- Create Dimension Tables
CREATE TABLE dbo.DimDriver(
	DriverKey int NOT NULL PRIMARY KEY IDENTITY,
	DriverId nchar(8) NOT NULL,
	FirstName nvarchar(50) NOT NULL, 
	LastName nvarchar(50) NOT NULL,
)

CREATE TABLE dbo.DimDates(
	DateKey int NOT NULL PRIMARY KEY IDENTITY,
	Date datetime NOT NULL,
	DateName nvarchar(50) NOT NULL,
	Month int NOT NULL,
	MonthName nvarchar(50) NOT NULL,
	Year int NOT NULL,
	YearName nvarchar(50) NOT NULL
)

CREATE TABLE dbo.DimLocation(
	LocationKey int NOT NULL PRIMARY KEY IDENTITY,
	CityKey int NOT NULL,
	StreetId nchar(10) NOT NULL,
	Street nvarchar(50) NOT NULL
)

CREATE TABLE dbo.DimCity(
	CityKey int NOT NULL PRIMARY KEY IDENTITY,
	CityId nchar(10) NOT NULL,
	CityName nvarchar(50) NOT NULL
	-- State nvarchar(50) NOT NULL
)

GO

--Create Fact Table

CREATE TABLE dbo.FactTrips(
	TripNumber nvarchar(50) NOT NULL,
	DateKey int NOT NULL,
	LocationKey int NOT NULL,
	DriverKey int NOT NULL,
	TripMileage decimal(18,4) NOT NULL,
	TripCharge decimal(18,4) NOT NULL,
	CONSTRAINT [PK_FactTrips] PRIMARY KEY CLUSTERED(DateKey ASC, 
	LocationKey ASC, DriverKey ASC, TripNumber ASC)
)

GO

--Create Foreign Keys

ALTER TABLE dbo.FactTrips WITH CHECK
ADD CONSTRAINT [FK_FactTrips_DimDates]
FOREIGN KEY (DateKey) REFERENCES dbo.DimDates(DateKey)

ALTER TABLE dbo.FactTrips WITH CHECK
ADD CONSTRAINT [FK_FactTrips_DimLocation]
FOREIGN KEY (LocationKey) REFERENCES dbo.DimLocation(LocationKey)

ALTER TABLE dbo.FactTrips WITH CHECK
ADD CONSTRAINT [FK_FactTrips_DimDriver]
FOREIGN KEY (DriverKey) REFERENCES dbo.DimDriver(DriverKey)

ALTER TABLE dbo.DimLocation WITH CHECK
ADD CONSTRAINT [FK_DimLocation_DimCity]
FOREIGN KEY (CityKey) REFERENCES dbo.DimCity(CityKey)

GO