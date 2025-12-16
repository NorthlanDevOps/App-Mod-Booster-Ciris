-- ================================================
-- Stored Procedures for App Mod Booster
-- ================================================

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
    
    -- Check if section name already exists (case-insensitive)
    IF EXISTS (SELECT 1 FROM Section WHERE LOWER(Description) = LOWER(@Description) AND Archived = 0)
    BEGIN
        RAISERROR('A section with this name already exists.', 16, 1);
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
    
    -- Check if section name already exists for a different section (case-insensitive)
    IF EXISTS (SELECT 1 FROM Section WHERE LOWER(Description) = LOWER(@Description) AND SectionID <> @SectionID AND Archived = 0)
    BEGIN
        RAISERROR('A section with this name already exists.', 16, 1);
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
CREATE OR ALTER PROCEDURE sp_GetAllWorkbases
AS
BEGIN
    SET NOCOUNT ON;
    SELECT WorkbaseID, Description, Address1, Address2, Address3, 
           Postcode, Telephone, Archived
    FROM Workbase
    WHERE Archived = 0
    ORDER BY Description;
END
GO

CREATE OR ALTER PROCEDURE sp_GetWorkbaseById
    @WorkbaseID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT WorkbaseID, Description, Address1, Address2, Address3, 
           Postcode, Telephone, Archived
    FROM Workbase
    WHERE WorkbaseID = @WorkbaseID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateWorkbase
    @Description VARCHAR(60),
    @Address1 VARCHAR(60) = NULL,
    @Address2 VARCHAR(60) = NULL,
    @Address3 VARCHAR(60) = NULL,
    @Postcode VARCHAR(10) = NULL,
    @Telephone VARCHAR(20) = NULL,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Workbase (Description, Address1, Address2, Address3, 
                          Postcode, Telephone, Archived, AuditUser)
    VALUES (@Description, @Address1, @Address2, @Address3, 
            @Postcode, @Telephone, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS WorkbaseID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateWorkbase
    @WorkbaseID INT,
    @Description VARCHAR(60),
    @Address1 VARCHAR(60) = NULL,
    @Address2 VARCHAR(60) = NULL,
    @Address3 VARCHAR(60) = NULL,
    @Postcode VARCHAR(10) = NULL,
    @Telephone VARCHAR(20) = NULL,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Workbase
    SET Description = @Description,
        Address1 = @Address1,
        Address2 = @Address2,
        Address3 = @Address3,
        Postcode = @Postcode,
        Telephone = @Telephone,
        AuditUser = @AuditUser
    WHERE WorkbaseID = @WorkbaseID;
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
    WHERE WorkbaseID = @WorkbaseID;
END
GO

-- User Stored Procedures
CREATE OR ALTER PROCEDURE sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, UserName, Name, Email, Mobile, SectionID, 
           Administrator, Archived
    FROM [User]
    WHERE Archived = 0
    ORDER BY Name;
END
GO

CREATE OR ALTER PROCEDURE sp_GetUserById
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserID, UserName, Name, Email, Mobile, SectionID, 
           Administrator, Archived
    FROM [User]
    WHERE UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE sp_CreateUser
    @UserName VARCHAR(50),
    @Name VARCHAR(100),
    @Email VARCHAR(100) = NULL,
    @Mobile VARCHAR(20) = NULL,
    @SectionID INT = NULL,
    @Administrator BIT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [User] (UserName, Name, Email, Mobile, SectionID, 
                        Administrator, Archived, AuditUser)
    VALUES (@UserName, @Name, @Email, @Mobile, @SectionID, 
            @Administrator, 0, @AuditUser);
    
    SELECT SCOPE_IDENTITY() AS UserID;
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateUser
    @UserID INT,
    @UserName VARCHAR(50),
    @Name VARCHAR(100),
    @Email VARCHAR(100) = NULL,
    @Mobile VARCHAR(20) = NULL,
    @SectionID INT = NULL,
    @Administrator BIT = 0,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [User]
    SET UserName = @UserName,
        Name = @Name,
        Email = @Email,
        Mobile = @Mobile,
        SectionID = @SectionID,
        Administrator = @Administrator,
        AuditUser = @AuditUser
    WHERE UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteUser
    @UserID INT,
    @AuditUser VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [User]
    SET Archived = 1,
        AuditUser = @AuditUser
    WHERE UserID = @UserID;
END
GO
