USE EmissionsMetrics;

GO



/*********************************************************/
/******************  Load Dimension Data *****************/
/*********************************************************/

/* Load the Entities Dimension */

INSERT INTO dim.Entities (ParentEntity, ParentType, ReportingEntity)
SELECT DISTINCT ehg.parent_entity
	           ,ehg.parent_type
	           ,ehg.reporting_entity
FROM stg.emissions_high_granularity ehg
WHERE NOT EXISTS (
    SELECT 1 FROM dim.Entities e
    WHERE e.parententity = ehg.parent_entity
    AND e.reportingentity = ehg.reporting_entity
);

GO


/* Load the Commodity Dimension */

INSERT INTO dim.Commodity (Commodity, ProductionUnit)
SELECT DISTINCT ehg.Commodity
               ,ehg.Production_Unit
FROM stg.emissions_high_granularity ehg
WHERE NOT EXISTS (
    SELECT 1 FROM dim.Commodity c
    WHERE c.Commodity = ehg.Commodity
    AND c.ProductionUnit = ehg.Production_Unit
);

GO


/* Load the Calendar Dimension */

IF (SELECT COUNT(*) FROM dim.Calendar) = 0
BEGIN
    -- Declare variables for date range
    DECLARE @StartDate DATE = '1854-01-01';
    DECLARE @EndDate DATE = DATEADD(YEAR, 10, GETDATE());
    DECLARE @CurrentDate DATE = @StartDate;

    -- Populate the Calendar table
    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO dim.Calendar (pkCalendarID, Year)
        VALUES (
            (YEAR(@CurrentDate) - 1854) * 10000 + DATEPART(DAYOFYEAR, @CurrentDate),
            YEAR(@CurrentDate)
        );

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;



/*********************************************************/
/******************  Load Fact Data **********************/
/*********************************************************/

/* Load the EmissionMetrics Fact Table */

INSERT INTO f.EmissionMetrics (
     fkEntityID
    ,fkCommodityID
	,fkCalendarID
	,ProductionValue
	,ProductEmissions_MtCO2
	,FlaringEmissions_MtCO2
	,VentingEmissions_MtCO2
	,OwnFuelUseEmissions_MtCO2
	,FugitiveMethaneEmissions_MtCO2e
	,TotalOperationalEmissions_MtCO2e
	,TotalEmissions_MtCO2e
)
SELECT e.pkEntityID
      ,c.pkCommodityID
	  ,cal.pkCalendarID
	  ,ehg.Production_Value
	  ,ehg.Product_Emissions_MtCO2
	  ,ehg.Flaring_Emissions_MtCO2
      ,ehg.Venting_Emissions_MtCO2
	  ,ehg.Own_Fuel_Use_Emissions_MtCO2
      ,ehg.Fugitive_Methane_Emissions_MtCO2e
	  ,ehg.Total_Operational_Emissions_MtCO2e
	  ,ehg.Total_Emissions_MtCO2e
FROM stg.emissions_high_granularity ehg
     INNER JOIN dim.Entities e
     ON ehg.Parent_Entity = e.ParentEntity
     AND ehg.Reporting_Entity = e.ReportingEntity
     INNER JOIN dim.Commodity c
     ON ehg.Commodity = c.Commodity
     AND ehg.Production_Unit = c.ProductionUnit
     INNER JOIN dim.Calendar cal
     ON ehg.Year = cal.Year
;

GO
