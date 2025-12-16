-- ================================================
-- Stored Procedures for App Mod Booster (HSIR3)
-- Aligned with actual database schema
-- ================================================

-- Department Stored Procedures (Divisions)
CREATE OR ALTER PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, Description, Archived, F2508Contact
    FROM Department
    WHERE Archived = 0
    ORDER BY Description;
END
GO

CREATE OR ALTER PROCEDURE sp_GetDepartmentById
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, Description, Archived, F2508Contact
    FROM Department
    WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateDepartment
    @Description VARCHAR(30),
    @F2508Contact INT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Department (Description, Archived, AuditUser, F2508Contact)
    VALUES (@Description, 0, @AuditUser, @F2508Contact);
    
    SELECT SCOPE_IDENTITY() AS DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateDepartment
    @DepartmentID INT,
    @Description VARCHAR(30),
    @F2508Contact INT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department
    SET Description = @Description,
        F2508Contact = @F2508Contact,
        AuditUser = @AuditUser
    WHERE DepartmentID = @DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDepartment
    @DepartmentID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Department
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE DepartmentID = @DepartmentID;
END
GO

-- Property Stored Procedures
CREATE OR ALTER PROCEDURE sp_GetAllProperties
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PropertyID, BuildingName, HouseNumber, HouseSuffix, StreetName, 
           PostalTown, Postcode, Archived
    FROM Property
    WHERE Archived = 0
    ORDER BY BuildingName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetPropertyById
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PropertyID, BuildingName, HouseNumber, HouseSuffix, StreetName, 
           TownVillage, PostalTown, County, Postcode, TelephoneNumber, 
           PropertyManager, EmailAddress, Information, UPRN, Archived
    FROM Property
    WHERE PropertyID = @PropertyID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateProperty
    @BuildingName VARCHAR(50),
    @HouseNumber INT = NULL,
    @HouseSuffix VARCHAR(50) = NULL,
    @StreetName VARCHAR(50),
    @TownVillage VARCHAR(50) = NULL,
    @PostalTown VARCHAR(50),
    @County VARCHAR(50) = NULL,
    @Postcode VARCHAR(10),
    @TelephoneNumber VARCHAR(20) = NULL,
    @PropertyManager VARCHAR(100) = NULL,
    @EmailAddress VARCHAR(100) = NULL,
    @Information VARCHAR(4000) = NULL,
    @UPRN INT = NULL,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Property (BuildingName, HouseNumber, HouseSuffix, StreetName, 
                          TownVillage, PostalTown, County, Postcode, 
                          TelephoneNumber, PropertyManager, EmailAddress, 
                          Information, UPRN, Archived, AuditUser)
    VALUES (@BuildingName, @HouseNumber, @HouseSuffix, @StreetName, 
            @TownVillage, @PostalTown, @County, @Postcode, 
            @TelephoneNumber, @PropertyManager, @EmailAddress, 
            @Information, @UPRN, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS PropertyID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateProperty
    @PropertyID INT,
    @BuildingName VARCHAR(50),
    @HouseNumber INT = NULL,
    @HouseSuffix VARCHAR(50) = NULL,
    @StreetName VARCHAR(50),
    @TownVillage VARCHAR(50) = NULL,
    @PostalTown VARCHAR(50),
    @County VARCHAR(50) = NULL,
    @Postcode VARCHAR(10),
    @TelephoneNumber VARCHAR(20) = NULL,
    @PropertyManager VARCHAR(100) = NULL,
    @EmailAddress VARCHAR(100) = NULL,
    @Information VARCHAR(4000) = NULL,
    @UPRN INT = NULL,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Property
    SET BuildingName = @BuildingName,
        HouseNumber = @HouseNumber,
        HouseSuffix = @HouseSuffix,
        StreetName = @StreetName,
        TownVillage = @TownVillage,
        PostalTown = @PostalTown,
        County = @County,
        Postcode = @Postcode,
        TelephoneNumber = @TelephoneNumber,
        PropertyManager = @PropertyManager,
        EmailAddress = @EmailAddress,
        Information = @Information,
        UPRN = @UPRN,
        AuditUser = @AuditUser
    WHERE PropertyID = @PropertyID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteProperty
    @PropertyID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Property
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE PropertyID = @PropertyID;
END
GO

-- Section Stored Procedures
CREATE OR ALTER PROCEDURE sp_GetAllSections
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SectionID, DepartmentID, Description, Archived
    FROM Section
    WHERE Archived = 0
    ORDER BY Description;
END
GO

CREATE OR ALTER PROCEDURE sp_GetSectionById
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SectionID, DepartmentID, Description, Archived
    FROM Section
    WHERE SectionID = @SectionID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateSection
    @DepartmentID INT,
    @Description VARCHAR(60),
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if section name already exists (case-insensitive per business logic)
    IF EXISTS (SELECT 1 FROM Section WHERE LOWER(Description) = LOWER(@Description) AND Archived = 0)
    BEGIN
        RAISERROR('A section with this name already exists (validation is case-insensitive).', 16, 1);
        RETURN;
    END
    
    INSERT INTO Section (DepartmentID, Description, Archived, AuditUser)
    VALUES (@DepartmentID, @Description, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS SectionID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateSection
    @SectionID INT,
    @DepartmentID INT,
    @Description VARCHAR(60),
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if section name already exists for a different section (case-insensitive per business logic)
    IF EXISTS (SELECT 1 FROM Section WHERE LOWER(Description) = LOWER(@Description) AND SectionID <> @SectionID AND Archived = 0)
    BEGIN
        RAISERROR('A section with this name already exists (validation is case-insensitive).', 16, 1);
        RETURN;
    END
    
    UPDATE Section
    SET DepartmentID = @DepartmentID,
        Description = @Description,
        AuditUser = @AuditUser
    WHERE SectionID = @SectionID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteSection
    @SectionID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Section
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE SectionID = @SectionID;
END
GO

-- Workbase Stored Procedures
-- Note: Workbase links Section to Property
CREATE OR ALTER PROCEDURE sp_GetAllWorkbases
AS
BEGIN
    SET NOCOUNT ON;
    SELECT w.WorkBaseID, w.SectionID, w.PropertyID, w.Archived,
           s.Description AS SectionDescription,
           p.BuildingName AS PropertyName
    FROM Workbase w
    LEFT JOIN Section s ON w.SectionID = s.SectionID
    LEFT JOIN Property p ON w.PropertyID = p.PropertyID
    WHERE w.Archived = 0
    ORDER BY s.Description, p.BuildingName;
END
GO

CREATE OR ALTER PROCEDURE sp_GetWorkbaseById
    @WorkbaseID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT w.WorkBaseID, w.SectionID, w.PropertyID, w.Archived,
           s.Description AS SectionDescription,
           p.BuildingName AS PropertyName
    FROM Workbase w
    LEFT JOIN Section s ON w.SectionID = s.SectionID
    LEFT JOIN Property p ON w.PropertyID = p.PropertyID
    WHERE w.WorkBaseID = @WorkbaseID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateWorkbase
    @SectionID INT,
    @PropertyID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workbase (SectionID, PropertyID, Archived, AuditUser)
    VALUES (@SectionID, @PropertyID, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS WorkbaseID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateWorkbase
    @WorkbaseID INT,
    @SectionID INT,
    @PropertyID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Workbase
    SET SectionID = @SectionID,
        PropertyID = @PropertyID,
        AuditUser = @AuditUser
    WHERE WorkBaseID = @WorkbaseID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteWorkbase
    @WorkbaseID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Workbase
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE WorkBaseID = @WorkbaseID;
END
GO

-- User Stored Procedures
-- Note: Schema uses Forename/Surname, NetworkLogon, not UserName/Name
CREATE OR ALTER PROCEDURE sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Forename, Surname, NetworkLogon, 
           DepartmentID, SectionID, WorkbaseID, OccupationID,
           EmailAddress, TelephoneNumber, Role, DefaultDepartmentID,
           DataAccessType, Archived
    FROM [User]
    WHERE Archived = 0
    ORDER BY Surname, Forename;
END
GO

CREATE OR ALTER PROCEDURE sp_GetUserById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Forename, Surname, NetworkLogon, 
           DepartmentID, SectionID, WorkbaseID, OccupationID,
           EmailAddress, TelephoneNumber, Role, DefaultDepartmentID,
           DataAccessType, Archived
    FROM [User]
    WHERE UserId = @UserId;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateUser
    @Forename VARCHAR(30),
    @Surname VARCHAR(30),
    @NetworkLogon VARCHAR(100),
    @DepartmentID INT,
    @SectionID INT,
    @WorkbaseID INT,
    @OccupationID INT = 0,
    @EmailAddress VARCHAR(100) = NULL,
    @TelephoneNumber VARCHAR(20) = NULL,
    @Role INT = 0,
    @DefaultDepartmentID INT = 0,
    @DataAccessType INT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [User] (Forename, Surname, NetworkLogon, DepartmentID, 
                        SectionID, WorkbaseID, OccupationID, EmailAddress, 
                        TelephoneNumber, Role, DefaultDepartmentID, 
                        DataAccessType, Archived, AuditUser)
    VALUES (@Forename, @Surname, @NetworkLogon, @DepartmentID, 
            @SectionID, @WorkbaseID, @OccupationID, @EmailAddress, 
            @TelephoneNumber, @Role, @DefaultDepartmentID, 
            @DataAccessType, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS UserId;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateUser
    @UserId INT,
    @Forename VARCHAR(30),
    @Surname VARCHAR(30),
    @NetworkLogon VARCHAR(100),
    @DepartmentID INT,
    @SectionID INT,
    @WorkbaseID INT,
    @OccupationID INT = 0,
    @EmailAddress VARCHAR(100) = NULL,
    @TelephoneNumber VARCHAR(20) = NULL,
    @Role INT = 0,
    @DefaultDepartmentID INT = 0,
    @DataAccessType INT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [User]
    SET Forename = @Forename,
        Surname = @Surname,
        NetworkLogon = @NetworkLogon,
        DepartmentID = @DepartmentID,
        SectionID = @SectionID,
        WorkbaseID = @WorkbaseID,
        OccupationID = @OccupationID,
        EmailAddress = @EmailAddress,
        TelephoneNumber = @TelephoneNumber,
        Role = @Role,
        DefaultDepartmentID = @DefaultDepartmentID,
        DataAccessType = @DataAccessType,
        AuditUser = @AuditUser
    WHERE UserId = @UserId;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteUser
    @UserId INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [User]
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE UserId = @UserId;
END
GO
