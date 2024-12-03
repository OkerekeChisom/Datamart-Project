USE EmissionsMetrics;

GO

/*********************************************************/
/******************    Schema DDL       ******************/
/*********************************************************/

-- Create the schemas if they don't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim' ) 
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA dim AUTHORIZATION dbo;'
END;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg' ) 
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA stg AUTHORIZATION dbo;'
END;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'f' ) 
BEGIN
    EXEC sp_executesql N'CREATE SCHEMA f AUTHORIZATION dbo;'
END;

GO

/*********************************************************/
/****************** Entities DIM Table  ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Entities')
BEGIN
    CREATE TABLE dim.Entities (
        pkEntityID INT IDENTITY(1,1) NOT NULL,
        ParentEntity NVARCHAR(100) NOT NULL,
        ParentType NVARCHAR(50) NOT NULL,
        ReportingEntity NVARCHAR(100) NOT NULL
    );


    ALTER TABLE dim.Entities
    ADD CONSTRAINT PK_Entities PRIMARY KEY (pkEntityID);

    ALTER TABLE dim.Entities
    ADD CONSTRAINT UC_Entities UNIQUE (ParentEntity, ReportingEntity);
END;
GO

/*********************************************************/
/****************** Commodity DIM Table ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Commodity')
BEGIN
    CREATE TABLE dim.Commodity (
        pkCommodityID INT IDENTITY(1,1) NOT NULL,
        Commodity NVARCHAR(50) NOT NULL,
        ProductionUnit NVARCHAR(50) NOT NULL
    );

    ALTER TABLE dim.Commodity
    ADD CONSTRAINT PK_Commodity PRIMARY KEY (pkCommodityID);

    ALTER TABLE dim.Commodity
    ADD CONSTRAINT UC_Commodity UNIQUE (Commodity, ProductionUnit);
END;
GO


/*********************************************************/
/****************** Calendar DIM Table ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Calendar')
BEGIN
    CREATE TABLE dim.Calendar (
        pkCalendarID INT NOT NULL,
        Year INT NOT NULL
    );


    ALTER TABLE dim.Calendar
    ADD CONSTRAINT PK_Calendar PRIMARY KEY (pkCalendarID);

    ALTER TABLE dim.Calendar
    ADD CONSTRAINT UC_Calendar UNIQUE (Year);
END;
GO

/*********************************************************/
/****************** EmissionMetrics FACT Table ***********/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'f' AND TABLE_NAME = 'EmissionMetrics')
BEGIN
    CREATE TABLE f.EmissionMetrics (
    pkEmissionID INT IDENTITY(1,1) NOT NULL,
    fkEntityID INT NOT NULL,
    fkCommodityID INT NOT NULL,
    fkCalendarID INT NOT NULL,
    ProductionValue FLOAT NOT NULL,
    ProductEmissions_MtCO2 FLOAT NOT NULL,
    FlaringEmissions_MtCO2 FLOAT NULL,
    VentingEmissions_MtCO2 FLOAT NULL,
    OwnFuelUseEmissions_MtCO2 FLOAT NULL,
    FugitiveMethaneEmissions_MtCO2e FLOAT NULL,
    TotalOperationalEmissions_MtCO2e FLOAT NULL,
    TotalEmissions_MtCO2e FLOAT NOT NULL	
);

-- Add Primary Key
ALTER TABLE f.EmissionMetrics
ADD CONSTRAINT PK_EmissionMetrics PRIMARY KEY (pkEmissionID);

-- Add Foreign Keys
ALTER TABLE f.EmissionMetrics
ADD CONSTRAINT FK_Emission_to_Entity
    FOREIGN KEY (fkEntityID) REFERENCES dim.Entities(pkEntityID);

ALTER TABLE f.EmissionMetrics
ADD CONSTRAINT FK_Emission_to_Commodity
    FOREIGN KEY (fkCommodityID) REFERENCES dim.Commodity(pkCommodityID);

ALTER TABLE f.EmissionMetrics
ADD CONSTRAINT FK_Emission_to_Calendar
    FOREIGN KEY (fkCalendarID) REFERENCES dim.Calendar(pkCalendarID);
END;
GO
