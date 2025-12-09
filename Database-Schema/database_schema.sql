USE [HSIR3]
GO
/****** Object:  UserDefinedFunction [dbo].[AuditTable]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[AuditTable] (@TableName As VarChar(256))  
RETURNS bit AS  
BEGIN 
	DECLARE @result As bit
	SELECT @result = Audit FROM AuditControl WHERE TableName = @TableName
	Return @result
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_FormatAddress]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fn_FormatAddress]
(
	@PropertyID INT
)
RETURNS VARCHAR(1000)
AS
BEGIN
	
	declare @ReturnString AS VARCHAR(1000)
	declare @HouseNum AS VARCHAR(200)
	
				
	SELECT @ReturnString = (BuildingName + '<Br>'  + CASE IsNull(Convert(Varchar(10), HouseNumber), '0') WHEN '0' THEN '' ELSE IsNull(Convert(Varchar(10), HouseNumber), '0') END + ' ' + IsNull(Convert(Varchar(50),HouseSuffix), ' ') + ' ' + StreetName
	+ ', ' + PostalTown + '<Br>' + Postcode)
		FROM Property
		WHERE Property.PropertyID = @PropertyID
		
    -- Insert statements for procedure here
	RETURN @ReturnString
END
GO
/****** Object:  UserDefinedFunction [dbo].[RemoveNumericCharacters]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[RemoveNumericCharacters](@Temp VarChar(1000))
Returns VarChar(1000)
AS
Begin

    Declare @NumRange as varchar(50) = '%[0-9]%'
    While PatIndex(@NumRange, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@NumRange, @Temp), 1, '')

    Return @Temp
End

GO
/****** Object:  Table [dbo].[Property]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Property](
	[PropertyID] [int] IDENTITY(0,1) NOT NULL,
	[BuildingName] [varchar](50) NOT NULL,
	[HouseNumber] [int] NULL,
	[HouseSuffix] [varchar](50) NULL,
	[StreetName] [varchar](50) NOT NULL,
	[TownVillage] [varchar](50) NULL,
	[PostalTown] [varchar](50) NOT NULL,
	[County] [varchar](50) NULL,
	[Postcode] [varchar](10) NOT NULL,
	[TelephoneNumber] [varchar](20) NULL,
	[PropertyManager] [varchar](100) NULL,
	[EmailAddress] [varchar](100) NULL,
	[Information] [varchar](4000) NULL,
	[UPRN] [int] NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Property] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_Property_BuildingName] UNIQUE NONCLUSTERED 
(
	[BuildingName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Section]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Section](
	[SectionID] [int] IDENTITY(0,1) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldDepartmentID] [int] NULL,
	[oldDescription] [varchar](60) NULL,
 CONSTRAINT [PK_Section] PRIMARY KEY CLUSTERED 
(
	[SectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Section] UNIQUE NONCLUSTERED 
(
	[SectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Workbase]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Workbase](
	[WorkBaseID] [int] IDENTITY(0,1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldSectionID] [int] NULL,
	[MappedWorkbaseID] [int] NULL,
 CONSTRAINT [PK_Workbase] PRIMARY KEY CLUSTERED 
(
	[WorkBaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[Forename] [varchar](30) NOT NULL,
	[Surname] [varchar](30) NOT NULL,
	[NetworkLogon] [varchar](100) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[SectionID] [int] NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[OccupationID] [int] NOT NULL,
	[EmailAddress] [varchar](100) NULL,
	[TelephoneNumber] [varchar](20) NULL,
	[Role] [int] NOT NULL,
	[DefaultDepartmentID] [int] NOT NULL,
	[DataAccessType] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldDepartmentID] [int] NULL,
	[oldSectionID] [int] NULL,
	[oldDefaultDepartmentID] [int] NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_User_NetworkLogin] UNIQUE NONCLUSTERED 
(
	[NetworkLogon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CorrectiveActionOtherEmailUser]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrectiveActionOtherEmailUser](
	[CorrectiveActionID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_CorrectiveActionOtherEmailUser] PRIMARY KEY CLUSTERED 
(
	[CorrectiveActionID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CorrectiveAction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrectiveAction](
	[CorrectiveActonID] [int] IDENTITY(0,1) NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[NonCompliance] [varchar](4000) NOT NULL,
	[Recommendation] [varchar](4000) NOT NULL,
	[RiskScore] [int] NOT NULL,
	[RiskCategory] [varchar](10) NOT NULL,
	[DateIssued] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ContentCategoryID] [int] NOT NULL,
	[ResponsibleManagerID] [int] NOT NULL,
	[ResponsibleSnrManagerID] [int] NOT NULL,
	[AdvisoryOfficerID] [int] NOT NULL,
	[AdvisoryOfficerContact] [varchar](20) NOT NULL,
	[CorrectiveActionStatusID] [int] NOT NULL,
	[OverdueMgrSent] [datetime] NULL,
	[OverdueSnrMgrSent] [datetime] NULL,
	[ActionTaken] [varchar](4000) NULL,
	[ReminderDate] [datetime] NULL,
	[ReminderIssued] [datetime] NULL,
	[AuditUser] [varchar](100) NULL,
	[AssessmentName] [varchar](100) NULL,
	[OldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_CorrectiveAction] PRIMARY KEY CLUSTERED 
(
	[CorrectiveActonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CorrectiveActionStatus]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrectiveActionStatus](
	[CorrectiveActionStatusID] [int] NOT NULL,
	[LongDescription] [varchar](40) NOT NULL,
	[ShortDescription] [varchar](10) NOT NULL,
 CONSTRAINT [PK_CorrectiveActionStatus] PRIMARY KEY CLUSTERED 
(
	[CorrectiveActionStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContentCategory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContentCategory](
	[ContentCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Audit] [bit] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ContentCategory] PRIMARY KEY CLUSTERED 
(
	[ContentCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ContentCategory_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Department]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department](
	[DepartmentID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[F2508Contact] [int] NOT NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_Department_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CorrectiveActionView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CorrectiveActionView]
AS
SELECT        dbo.CorrectiveAction.CorrectiveActonID, dbo.Department.DepartmentID, dbo.Department.Description AS DeptDescription, dbo.Section.SectionID, 
                         dbo.Section.Description AS SectionDescription, dbo.Workbase.WorkBaseID, dbo.CorrectiveAction.RiskScore, dbo.CorrectiveAction.RiskCategory, 
                         dbo.CorrectiveAction.DateIssued, dbo.CorrectiveAction.DueDate, dbo.CorrectiveAction.ResponsibleManagerID, dbo.CorrectiveAction.ResponsibleSnrManagerID, 
                         dbo.CorrectiveAction.AdvisoryOfficerID, dbo.CorrectiveAction.CorrectiveActionStatusID, dbo.[User].Forename AS ManagerForename, 
                         dbo.[User].Surname AS ManagerSurname, User_1.Forename AS SnrManagerForename, User_1.Surname AS SnrManagerSurname, 
                         User_2.Forename AS OfficerForename, User_2.Surname AS OfficerSurname, dbo.Property.BuildingName, 
                         dbo.CorrectiveActionStatus.LongDescription AS StatusLongDesc, dbo.CorrectiveActionStatus.ShortDescription AS StatusShortDesc, 
                         dbo.CorrectiveAction.NonCompliance, dbo.CorrectiveAction.Recommendation, dbo.ContentCategory.Description AS SourceDescription, 
                         dbo.ContentCategory.ContentCategoryID AS SourceID, dbo.CorrectiveAction.ActionTaken, User_2.TelephoneNumber AS OfficerTelephoneNumber, 
                         dbo.CorrectiveAction.ReminderDate, dbo.CorrectiveAction.ReminderIssued, dbo.CorrectiveActionOtherEmailUser.UserID AS SecondaryManagerID, 
                         dbo.CorrectiveAction.AssessmentName, User_3.Forename AS SecondaryManagerForename, User_3.Surname AS SecondaryManagerSurname
FROM            dbo.[User] AS User_3 INNER JOIN
                         dbo.CorrectiveActionOtherEmailUser ON User_3.UserId = dbo.CorrectiveActionOtherEmailUser.UserID RIGHT OUTER JOIN
                         dbo.CorrectiveAction INNER JOIN
                         dbo.Workbase ON dbo.CorrectiveAction.WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                         dbo.Section ON dbo.Workbase.SectionID = dbo.Section.SectionID INNER JOIN
                         dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                         dbo.[User] ON dbo.CorrectiveAction.ResponsibleManagerID = dbo.[User].UserId INNER JOIN
                         dbo.[User] AS User_1 ON dbo.CorrectiveAction.ResponsibleSnrManagerID = User_1.UserId INNER JOIN
                         dbo.[User] AS User_2 ON dbo.CorrectiveAction.AdvisoryOfficerID = User_2.UserId INNER JOIN
                         dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID INNER JOIN
                         dbo.CorrectiveActionStatus ON dbo.CorrectiveAction.CorrectiveActionStatusID = dbo.CorrectiveActionStatus.CorrectiveActionStatusID INNER JOIN
                         dbo.ContentCategory ON dbo.CorrectiveAction.ContentCategoryID = dbo.ContentCategory.ContentCategoryID ON 
                         dbo.CorrectiveActionOtherEmailUser.CorrectiveActionID = dbo.CorrectiveAction.CorrectiveActonID
GO
/****** Object:  Table [dbo].[AccidentType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccidentType](
	[AccidentTypeID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[HeightRequired] [bit] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_AccidentType] PRIMARY KEY CLUSTERED 
(
	[AccidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_AccidentType_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DepartmentAccidentType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DepartmentAccidentType](
	[DepartmentID] [int] NOT NULL,
	[AccidentTypeID] [int] NOT NULL,
 CONSTRAINT [PK_DepartmentAccidentType] PRIMARY KEY NONCLUSTERED 
(
	[DepartmentID] ASC,
	[AccidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_DepartmentAccidentType] UNIQUE CLUSTERED 
(
	[DepartmentID] ASC,
	[AccidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DepartmentAccidentTypeView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DepartmentAccidentTypeView]
AS
SELECT     dbo.DepartmentAccidentType.DepartmentID, dbo.DepartmentAccidentType.AccidentTypeID, dbo.AccidentType.Description, 
                      dbo.AccidentType.HeightRequired, dbo.AccidentType.Archived
FROM         dbo.DepartmentAccidentType INNER JOIN
                      dbo.AccidentType ON dbo.DepartmentAccidentType.AccidentTypeID = dbo.AccidentType.AccidentTypeID
GO
/****** Object:  Table [dbo].[IncidentType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentType](
	[IncidentTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_IncidentType] PRIMARY KEY CLUSTERED 
(
	[IncidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_IncidentType_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DepartmentIncidentType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DepartmentIncidentType](
	[DepartmentID] [int] NOT NULL,
	[IncidentTypeID] [int] NOT NULL,
 CONSTRAINT [PK_DepartmentIncidentType] PRIMARY KEY NONCLUSTERED 
(
	[DepartmentID] ASC,
	[IncidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UNIQUE_DepartmentIncidentType] UNIQUE CLUSTERED 
(
	[DepartmentID] ASC,
	[IncidentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DepartmentIncidentTypeView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DepartmentIncidentTypeView]
AS
SELECT     dbo.DepartmentIncidentType.DepartmentID, dbo.DepartmentIncidentType.IncidentTypeID, dbo.IncidentType.Description, dbo.IncidentType.Archived, 
                      dbo.Department.Description AS DepartmentDesc
FROM         dbo.DepartmentIncidentType INNER JOIN
                      dbo.IncidentType ON dbo.DepartmentIncidentType.IncidentTypeID = dbo.IncidentType.IncidentTypeID INNER JOIN
                      dbo.Department ON dbo.DepartmentIncidentType.DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  View [dbo].[CommunityFacilitiesSchool]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CommunityFacilitiesSchool]
AS
SELECT     TOP (100) PERCENT dbo.Section.SectionID AS Expr1, dbo.Section.Description, dbo.Section.DepartmentID, dbo.Department.Description AS Expr2, 
                      dbo.Section.Archived, dbo.Workbase.WorkBaseID, dbo.Workbase.PropertyID, dbo.Workbase.Archived AS WorkbaseArchived, 
                      dbo.Property.BuildingName
FROM         dbo.Section INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.Section.SectionID = dbo.Workbase.SectionID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
WHERE     (dbo.Section.Archived = 0) AND (dbo.Section.SectionID = 292) AND (dbo.Workbase.Archived = 0) AND (dbo.Property.BuildingName LIKE '%school%')
ORDER BY dbo.Property.BuildingName
GO
/****** Object:  Table [dbo].[Occupation]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Occupation](
	[OccupationID] [int] IDENTITY(0,1) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldOccupationID] [int] NULL,
 CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED 
(
	[OccupationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OccupationDepartmentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OccupationDepartmentView]
AS
SELECT     dbo.Occupation.OccupationID, dbo.Occupation.Description AS OccupationDescription, dbo.Department.DepartmentID, 
                      dbo.Department.Description AS DepartmentDescription, dbo.Occupation.Archived, dbo.Occupation.RowVersion
FROM         dbo.Occupation INNER JOIN
                      dbo.Department ON dbo.Occupation.DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  Table [dbo].[ContentCategoryAudit]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContentCategoryAudit](
	[ContentCategoryAuditID] [int] IDENTITY(1,1) NOT NULL,
	[Audit] [bit] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_ContentCategoryAudit] PRIMARY KEY CLUSTERED 
(
	[ContentCategoryAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vContentcategory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vContentcategory]
AS
SELECT     dbo.ContentCategory.ContentCategoryID, dbo.ContentCategory.Description, dbo.ContentCategoryAudit.Description AS Type, 
                      dbo.ContentCategory.Archived, dbo.ContentCategory.Audit
FROM         dbo.ContentCategory INNER JOIN
                      dbo.ContentCategoryAudit ON dbo.ContentCategory.Audit = dbo.ContentCategoryAudit.Audit
GO
/****** Object:  Table [dbo].[DepartmentF2508Contact]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DepartmentF2508Contact](
	[DepartmentF2508ContactID] [int] IDENTITY(1,1) NOT NULL,
	[F2508Contact] [int] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_DepartmentF2508Contact_1] PRIMARY KEY CLUSTERED 
(
	[F2508Contact] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vDepartment]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vDepartment]
AS
SELECT     dbo.Department.DepartmentID, dbo.Department.Description, dbo.Department.Archived, 
                      dbo.DepartmentF2508Contact.Description AS F2508ContactDescription
FROM         dbo.Department INNER JOIN
                      dbo.DepartmentF2508Contact ON dbo.Department.F2508Contact = dbo.DepartmentF2508Contact.F2508Contact
GO
/****** Object:  View [dbo].[vOccupation]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vOccupation]
AS
SELECT     dbo.Occupation.OccupationID, dbo.Department.Description AS DepartmentDescription, dbo.Occupation.Description AS OccupationDescription, 
                      dbo.Occupation.Archived
FROM         dbo.Occupation INNER JOIN
                      dbo.Department ON dbo.Occupation.DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  View [dbo].[vCorrectiveAction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCorrectiveAction]
AS
SELECT     dbo.CorrectiveAction.CorrectiveActonID, dbo.Department.Description AS DepartmentDescription, dbo.Section.Description AS SectionDescription, 
                      dbo.CorrectiveAction.WorkbaseID, dbo.CorrectiveAction.NonCompliance, dbo.CorrectiveAction.Recommendation, dbo.CorrectiveAction.RiskScore, 
                      dbo.CorrectiveAction.RiskCategory, dbo.CorrectiveAction.DateIssued, dbo.CorrectiveAction.DueDate, 
                      dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.CorrectiveAction.ResponsibleManagerID, 
                      dbo.CorrectiveAction.ResponsibleSnrManagerID, dbo.CorrectiveAction.AdvisoryOfficerID, dbo.CorrectiveAction.AdvisoryOfficerContact, 
                      dbo.CorrectiveActionStatus.LongDescription AS CorrectiveActionStatusDescription, dbo.CorrectiveAction.OverdueMgrSent, 
                      dbo.CorrectiveAction.OverdueSnrMgrSent, dbo.CorrectiveAction.ActionTaken, dbo.CorrectiveAction.ReminderDate, 
                      dbo.CorrectiveAction.ReminderIssued, dbo.CorrectiveAction.AuditUser
FROM         dbo.CorrectiveAction INNER JOIN
                      dbo.Workbase ON dbo.CorrectiveAction.WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Section ON dbo.Workbase.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.ContentCategory ON dbo.CorrectiveAction.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.CorrectiveActionStatus ON dbo.CorrectiveAction.CorrectiveActionStatusID = dbo.CorrectiveActionStatus.CorrectiveActionStatusID
GO
/****** Object:  Table [dbo].[Mapping]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mapping](
	[FromDepartmentID] [int] NOT NULL,
	[FromSectionID] [int] NOT NULL,
	[ToDepartmentID] [int] NOT NULL,
	[ToSectionID] [int] NOT NULL,
	[ToSectionDescription] [varchar](60) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[mSection]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mSection]
AS
SELECT     dbo.[Section].SectionID, dbo.[Section].DepartmentID, dbo.Mapping.FromDepartmentID, dbo.Mapping.FromSectionID, dbo.Mapping.ToDepartmentID, 
                      dbo.Mapping.ToSectionID, dbo.Mapping.ToSectionDescription, dbo.[Section].Description, dbo.[Section].oldDepartmentID, 
                      dbo.[Section].oldDescription
FROM         dbo.Mapping INNER JOIN
                      dbo.[Section] ON dbo.Mapping.FromSectionID = dbo.[Section].SectionID
WHERE     (dbo.Mapping.FromSectionID = dbo.Mapping.ToSectionID)
GO
/****** Object:  Table [dbo].[CorrectiveActionEvent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrectiveActionEvent](
	[CorrectiveActionEventID] [int] NOT NULL,
	[Description] [varchar](30) NOT NULL,
 CONSTRAINT [PK_CorrectiveActiveEvent] PRIMARY KEY CLUSTERED 
(
	[CorrectiveActionEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CorrectiveActionHistory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CorrectiveActionHistory](
	[CorrectiveActionHistoryID] [int] IDENTITY(0,1) NOT NULL,
	[CorrectiveActionID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[UserWorkbaseID] [int] NOT NULL,
	[UserOccupationID] [int] NOT NULL,
	[CorrectiveActionEventID] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[Comments] [varchar](4000) NOT NULL,
 CONSTRAINT [PK_CorrectiveActionHistory] PRIMARY KEY CLUSTERED 
(
	[CorrectiveActionHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vCorrectiveActionHistory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCorrectiveActionHistory]
AS
SELECT     dbo.CorrectiveActionHistory.CorrectiveActionHistoryID, dbo.CorrectiveActionHistory.CorrectiveActionID, dbo.CorrectiveActionHistory.UserID, 
                      dbo.CorrectiveActionHistory.UserWorkbaseID, dbo.Occupation.Description AS OccupationDescription, 
                      dbo.CorrectiveActionEvent.Description AS CorrectiveActionEvent, dbo.CorrectiveActionHistory.EventDate, dbo.CorrectiveActionHistory.Comments
FROM         dbo.CorrectiveActionHistory INNER JOIN
                      dbo.Occupation ON dbo.CorrectiveActionHistory.UserOccupationID = dbo.Occupation.OccupationID INNER JOIN
                      dbo.CorrectiveActionEvent ON dbo.CorrectiveActionHistory.CorrectiveActionEventID = dbo.CorrectiveActionEvent.CorrectiveActionEventID
GO
/****** Object:  View [dbo].[SectionDepartmentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SectionDepartmentView]
AS
SELECT     dbo.Department.DepartmentID, dbo.Department.Description AS DepartmentDescription, dbo.Department.Archived AS DepartmentArchived, 
                      dbo.[Section].SectionID, dbo.[Section].Description AS SectionDescription, dbo.[Section].Archived AS SectionArchived, dbo.[Section].RowVersion
FROM         dbo.Department INNER JOIN
                      dbo.[Section] ON dbo.Department.DepartmentID = dbo.[Section].DepartmentID
GO
/****** Object:  Table [dbo].[UserAccess]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAccess](
	[UserAccessID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[DepartmentID] [int] NULL,
	[SectionID] [int] NULL,
	[WorkbaseID] [int] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[oldDepartmentID] [int] NULL,
	[oldSectionID] [int] NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_UserAccess] PRIMARY KEY CLUSTERED 
(
	[UserAccessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ResponsibleUserView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ResponsibleUserView]
AS
SELECT     dbo.[User].UserId, dbo.[User].Forename, dbo.[User].Surname, dbo.UserAccess.DepartmentID, dbo.[User].TelephoneNumber, dbo.[User].Role, 
                      dbo.[User].Archived
FROM         dbo.[User] INNER JOIN
                      dbo.UserAccess ON dbo.[User].UserId = dbo.UserAccess.UserID
GROUP BY dbo.[User].UserId, dbo.[User].Forename, dbo.[User].Surname, dbo.UserAccess.DepartmentID, dbo.[User].TelephoneNumber, dbo.[User].Role, 
                      dbo.[User].Archived
HAVING      (dbo.[User].Role = 2 OR
                      dbo.[User].Role = 3) AND (dbo.[User].Archived = 0)
GO
/****** Object:  View [dbo].[mWorkbase]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mWorkbase]
AS
SELECT     dbo.Mapping.FromDepartmentID, dbo.Mapping.FromSectionID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, 
                      dbo.Mapping.ToSectionDescription, dbo.Workbase.WorkBaseID, dbo.Workbase.SectionID, dbo.Workbase.oldSectionID
FROM         dbo.Mapping INNER JOIN
                      dbo.Workbase ON dbo.Mapping.FromSectionID = dbo.Workbase.SectionID
WHERE     (dbo.Mapping.FromSectionID <> dbo.Mapping.ToSectionID)
GO
/****** Object:  View [dbo].[MultipleServiceView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MultipleServiceView]
AS
SELECT     dbo.[User].UserId, dbo.[User].Forename, dbo.[User].Surname, dbo.[User].NetworkLogon, dbo.[User].DefaultDepartmentID, dbo.UserAccess.UserAccessID, 
                      dbo.UserAccess.DepartmentID, dbo.[User].DataAccessType, dbo.Department.Description, dbo.[User].Archived
FROM         dbo.[User] INNER JOIN
                      dbo.UserAccess ON dbo.[User].UserId = dbo.UserAccess.UserID INNER JOIN
                      dbo.Department ON dbo.UserAccess.DepartmentID = dbo.Department.DepartmentID
WHERE     (dbo.[User].DataAccessType = 4) AND (dbo.[User].Archived = 0)
GO
/****** Object:  Table [dbo].[Content]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Content](
	[ContentID] [int] IDENTITY(1,1) NOT NULL,
	[ContentCategoryID] [int] NOT NULL,
	[HardCopyReference] [varchar](100) NULL,
	[Description] [varchar](1000) NULL,
	[Filename] [varchar](200) NULL,
	[ContentTypeID] [int] NOT NULL,
	[ContentStoreID] [int] NOT NULL,
	[AttachedByUserID] [int] NOT NULL,
	[AttachedDate] [datetime] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_Content] PRIMARY KEY CLUSTERED 
(
	[ContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditVisitContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditVisitContent](
	[AuditVisitContentID] [int] IDENTITY(1,1) NOT NULL,
	[AuditVisitID] [int] NOT NULL,
	[ContentID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_AuditVisitContent] PRIMARY KEY CLUSTERED 
(
	[AuditVisitContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContentType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContentType](
	[ContentTypeID] [int] IDENTITY(0,1) NOT NULL,
	[Extension] [char](10) NOT NULL,
	[Description] [char](60) NOT NULL,
	[Reader] [char](120) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_ContentType] PRIMARY KEY CLUSTERED 
(
	[ContentTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ContentType_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vAuditVisitContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAuditVisitContent]
AS
SELECT     dbo.AuditVisitContent.AuditVisitContentID, dbo.AuditVisitContent.AuditVisitID, dbo.ContentCategory.Description AS ContentCategoryDescription, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Content.HardCopyReference, dbo.Content.Description, dbo.Content.Filename, 
                      dbo.ContentType.Extension AS ContentTypeExtension, dbo.ContentType.Description AS ContentTypeDescription, dbo.Content.AttachedByUserID, 
                      dbo.Content.AttachedDate
FROM         dbo.AuditVisitContent INNER JOIN
                      dbo.Content ON dbo.AuditVisitContent.ContentID = dbo.Content.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.Content.ContentTypeID = dbo.ContentType.ContentTypeID
GO
/****** Object:  View [dbo].[AdvisoryOfficerView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AdvisoryOfficerView]
AS
SELECT     TOP (100) PERCENT UserId, Forename, Surname, TelephoneNumber, Role, Archived, DepartmentID
FROM         dbo.[User]
GROUP BY UserId, Forename, Surname, TelephoneNumber, Role, Archived, DepartmentID
ORDER BY UserId
GO
/****** Object:  Table [dbo].[FunctionContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FunctionContent](
	[FunctionContentID] [int] IDENTITY(1,1) NOT NULL,
	[FunctionID] [int] NOT NULL,
	[ContentID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_FunctionContent] PRIMARY KEY CLUSTERED 
(
	[FunctionContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vFunctionContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vFunctionContent]
AS
SELECT     dbo.FunctionContent.FunctionContentID, dbo.FunctionContent.FunctionID, dbo.ContentCategory.Description AS ContentCategoryDescription, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Content.HardCopyReference, dbo.Content.Description, dbo.Content.Filename, 
                      dbo.ContentType.Extension AS ContentTypeExtension, dbo.ContentType.Description AS ContentTypeDescription, dbo.Content.AttachedByUserID, 
                      dbo.Content.AttachedDate
FROM         dbo.FunctionContent INNER JOIN
                      dbo.Content ON dbo.FunctionContent.ContentID = dbo.Content.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.Content.ContentTypeID = dbo.ContentType.ContentTypeID
GO
/****** Object:  View [dbo].[vWorkbase]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vWorkbase]
AS
SELECT     dbo.Workbase.WorkBaseID, dbo.Department.Description AS DepartmentDescription, dbo.Department.Archived AS DepartmentArchived, 
                      dbo.[Section].Description AS SectionDescription, dbo.[Section].Archived AS SectionArchived, dbo.Workbase.PropertyID, 
                      dbo.Workbase.Archived AS WorkbaseArchived, dbo.Workbase.oldSectionID
FROM         dbo.Workbase INNER JOIN
                      dbo.[Section] ON dbo.Workbase.SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  View [dbo].[WorkbaseDepartmentSectionPropertyView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbaseDepartmentSectionPropertyView]
AS
SELECT     dbo.Department.DepartmentID, dbo.Department.Description AS DepartmentDescription, dbo.Department.Archived AS DepartmentArchived, dbo.Section.SectionID, 
                      dbo.Section.Description AS SectionDescription, dbo.Section.Archived AS SectionArchived, dbo.Workbase.WorkBaseID, dbo.Workbase.Archived AS WorkBaseArchive, 
                      dbo.Property.PropertyID, dbo.Property.BuildingName AS WorkBaseDescription, dbo.Workbase.RowVersion, dbo.fn_FormatAddress(dbo.Property.PropertyID) 
                      AS PropertyAddress, dbo.Property.TelephoneNumber, dbo.Property.PropertyManager, dbo.Property.EmailAddress, dbo.Property.Information
FROM         dbo.Workbase INNER JOIN
                      dbo.Section ON dbo.Workbase.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  Table [dbo].[Audit]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[Area] [varchar](100) NOT NULL,
	[ContentCategoryID] [int] NOT NULL,
	[FrequencyFactor] [int] NOT NULL,
	[DateOfLastVisit] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[OldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuditVisit]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditVisit](
	[AuditVisitID] [int] IDENTITY(1,1) NOT NULL,
	[AuditID] [int] NOT NULL,
	[DateOfVisit] [datetime] NOT NULL,
	[AuditedByUserID] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_AuditVisit] PRIMARY KEY CLUSTERED 
(
	[AuditVisitID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AuditAttachmentsView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AuditAttachmentsView]
AS
SELECT     TOP 100 PERCENT dbo.Audit.WorkbaseID, dbo.Audit.Area, dbo.Audit.Archived AS AuditArchived, dbo.AuditVisit.AuditID, dbo.AuditVisit.DateOfVisit, 
                      dbo.AuditVisit.Archived AS AuditVisitArchived, dbo.AuditVisitContent.AuditVisitID, dbo.AuditVisitContent.Archived AS AuditVisitContentArchived, 
                      dbo.Content.ContentID, dbo.Content.ContentCategoryID, dbo.Content.HardCopyReference, dbo.Content.Description AS ContentDescription, 
                      dbo.Content.ContentTypeID, dbo.Content.ContentStoreID, dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.[User].Forename, 
                      dbo.[User].Surname, dbo.AuditVisit.AuditedByUserID
FROM         dbo.Audit INNER JOIN
                      dbo.AuditVisit ON dbo.Audit.AuditID = dbo.AuditVisit.AuditID INNER JOIN
                      dbo.AuditVisitContent ON dbo.AuditVisit.AuditVisitID = dbo.AuditVisitContent.AuditVisitID INNER JOIN
                      dbo.Content ON dbo.AuditVisitContent.ContentID = dbo.Content.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.[User] ON dbo.AuditVisit.AuditedByUserID = dbo.[User].UserId
GO
/****** Object:  View [dbo].[AuditContentCategoryView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AuditContentCategoryView]
AS
SELECT     dbo.Audit.PropertyID, dbo.Audit.WorkbaseID, dbo.Audit.Area, dbo.Audit.ContentCategoryID, dbo.Audit.FrequencyFactor, dbo.Audit.DateOfLastVisit, 
                      dbo.Audit.Archived AS AuditArchived, dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.Audit.AuditID, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Audit.RowVersion
FROM         dbo.Audit INNER JOIN
                      dbo.ContentCategory ON dbo.Audit.ContentCategoryID = dbo.ContentCategory.ContentCategoryID
GO
/****** Object:  Table [dbo].[ContentStore]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContentStore](
	[ContentStoreID] [int] IDENTITY(0,1) NOT NULL,
	[Attachment_old] [image] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[Attachment] [varbinary](max) NULL,
 CONSTRAINT [PK_ContentStore] PRIMARY KEY CLUSTERED 
(
	[ContentStoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[AuditVisitContentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AuditVisitContentView]
AS
SELECT     dbo.Content.Description AS ContentDescription, dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.Content.ContentStoreID, 
                      dbo.Content.ContentTypeID, dbo.Content.AttachedByUserID, dbo.Content.AttachedDate, dbo.Content.ContentID, 
                      dbo.AuditVisitContent.AuditVisitContentID, dbo.Content.Filename, dbo.Content.HardCopyReference, dbo.Content.ContentCategoryID, 
                      dbo.ContentType.Extension, dbo.ContentType.Description AS ContentTypeDescription, dbo.ContentType.Reader, dbo.AuditVisitContent.AuditVisitID, 
                      dbo.[User].Forename, dbo.[User].Surname, dbo.[User].DepartmentID AS UserDepartmentID, dbo.[User].SectionID AS UserSectionID, 
                      dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.[Section].Description AS SectionDescription, dbo.Department.Description AS DepartmentDescription, 
                      dbo.Property.BuildingName, dbo.AuditVisitContent.Archived AS AuditVisitContentArchived, dbo.ContentCategory.Archived AS ContentCategoryArchived, 
                      dbo.Content.RowVersion
FROM         dbo.[User] INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.[Section] ON dbo.[User].SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID INNER JOIN
                      dbo.Content INNER JOIN
                      dbo.AuditVisitContent ON dbo.Content.ContentID = dbo.AuditVisitContent.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.Content.ContentTypeID = dbo.ContentType.ContentTypeID INNER JOIN
                      dbo.ContentStore ON dbo.Content.ContentStoreID = dbo.ContentStore.ContentStoreID ON dbo.[User].UserId = dbo.Content.AttachedByUserID
GO
/****** Object:  View [dbo].[AuditVisitView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AuditVisitView]
AS
SELECT     dbo.AuditVisit.AuditVisitID, dbo.AuditVisit.DateOfVisit, dbo.[User].Surname, dbo.[User].Forename, dbo.AuditVisit.AuditedByUserID, dbo.AuditVisit.AuditID,
                       dbo.[Section].Description AS SectionDescription, dbo.Department.Description AS DepartmentDescription, dbo.Property.BuildingName, 
                      dbo.[User].DepartmentID, dbo.[User].WorkbaseID, dbo.[User].SectionID, dbo.AuditVisit.Archived AS AuditVisitArchived, 
                      dbo.AuditVisit.RowVersion AS AuditVisitRowVersion
FROM         dbo.AuditVisit INNER JOIN
                      dbo.[User] ON dbo.AuditVisit.AuditedByUserID = dbo.[User].UserId INNER JOIN
                      dbo.[Section] ON dbo.[User].SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  Table [dbo].[WFunction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WFunction](
	[FunctionID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_WFunction] PRIMARY KEY CLUSTERED 
(
	[FunctionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_WFunction_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[FunctionContentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FunctionContentView]
AS
SELECT     dbo.FunctionContent.FunctionID, dbo.[Content].Description AS ContentDescription, dbo.[Content].AttachedDate, 
                      dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.[User].Forename, dbo.[User].Surname, dbo.WFunction.Description AS WFunctionDescription, 
                      dbo.[Content].ContentID, dbo.[Content].AttachedByUserID, dbo.[Content].Filename, dbo.[Content].ContentTypeID, dbo.[Content].ContentStoreID, 
                      dbo.[Content].HardCopyReference, dbo.[Content].ContentCategoryID, dbo.ContentType.Extension, dbo.ContentType.Description AS ContentTypeDescription, 
                      dbo.ContentType.Reader, dbo.[User].DepartmentID AS UserDepartmentID, dbo.[User].SectionID AS UserSectionID, dbo.Section.Description AS SectionDescription, 
                      dbo.Department.Description AS DepartmentDescription, dbo.Property.BuildingName, dbo.ContentCategory.Archived AS ContentCategoryArchived, 
                      dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.[Content].RowVersion, dbo.FunctionContent.FunctionContentID
FROM         dbo.FunctionContent INNER JOIN
                      dbo.[Content] ON dbo.FunctionContent.ContentID = dbo.[Content].ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.[Content].ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.[User] ON dbo.[Content].AttachedByUserID = dbo.[User].UserId INNER JOIN
                      dbo.WFunction ON dbo.FunctionContent.FunctionID = dbo.WFunction.FunctionID INNER JOIN
                      dbo.ContentStore ON dbo.[Content].ContentStoreID = dbo.ContentStore.ContentStoreID INNER JOIN
                      dbo.ContentType ON dbo.[Content].ContentTypeID = dbo.ContentType.ContentTypeID INNER JOIN
                      dbo.Section ON dbo.[User].SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  View [dbo].[mUser]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mUser]
AS
SELECT     dbo.Mapping.FromDepartmentID, dbo.Mapping.FromSectionID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, 
                      dbo.Mapping.ToSectionDescription, dbo.[User].UserId, dbo.[User].DepartmentID, dbo.[User].SectionID, dbo.[User].DefaultDepartmentID, 
                      dbo.[User].oldDepartmentID, dbo.[User].oldSectionID, dbo.[User].oldDefaultDepartmentID
FROM         dbo.Mapping INNER JOIN
                      dbo.[User] ON dbo.Mapping.FromSectionID = dbo.[User].SectionID
GO
/****** Object:  View [dbo].[mUserOccupation]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mUserOccupation]
AS
SELECT     TOP 100 PERCENT dbo.[User].UserId, dbo.Occupation.oldOccupationID, dbo.Occupation.OccupationID, dbo.[User].DepartmentID
FROM         dbo.[User] INNER JOIN
                      dbo.Occupation ON dbo.[User].OccupationID = dbo.Occupation.oldOccupationID AND dbo.[User].DepartmentID = dbo.Occupation.DepartmentID
GO
/****** Object:  View [dbo].[SpreadsheetForUsers]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SpreadsheetForUsers]
AS
SELECT     TOP 100 PERCENT dbo.[User].Surname, dbo.[User].Forename, dbo.[User].NetworkLogon, dbo.[User].DepartmentID, dbo.Department.Description, 
                      dbo.[User].Archived, dbo.[User].Role
FROM         dbo.[User] INNER JOIN
                      dbo.Department ON dbo.[User].DepartmentID = dbo.Department.DepartmentID
WHERE     (dbo.[User].Archived = 0) AND (dbo.[User].Surname = 'taylor')
ORDER BY dbo.[User].NetworkLogon
GO
/****** Object:  View [dbo].[UserSectionView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserSectionView]
AS
SELECT     dbo.[User].UserId, dbo.[User].Surname, dbo.[User].Forename, dbo.[User].Role, dbo.[User].Archived AS UserArchived, dbo.[Section].SectionID, 
                      dbo.[Section].Description, dbo.[User].DepartmentID, dbo.[User].DefaultDepartmentID, dbo.[User].DataAccessType, dbo.[User].RowVersion
FROM         dbo.[User] INNER JOIN
                      dbo.[Section] ON dbo.[User].SectionID = dbo.[Section].SectionID
GO
/****** Object:  View [dbo].[vAudit]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAudit]
AS
SELECT     dbo.Audit.AuditID, dbo.Audit.PropertyID, dbo.Audit.WorkbaseID, dbo.Audit.Area, dbo.ContentCategory.Description AS ContentCategoryDescription, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Audit.FrequencyFactor, dbo.Audit.DateOfLastVisit, dbo.Audit.Archived
FROM         dbo.Audit INNER JOIN
                      dbo.ContentCategory ON dbo.Audit.ContentCategoryID = dbo.ContentCategory.ContentCategoryID
GO
/****** Object:  View [dbo].[vAuditVisit]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vAuditVisit]
AS
SELECT     dbo.AuditVisit.AuditVisitID, dbo.Audit.PropertyID AS AuditPropertyID, dbo.Audit.WorkbaseID AS AuditWorkbaseID, dbo.Audit.Area AS AuditArea, 
                      dbo.ContentCategory.Description AS AuditContentCategoryDescription, dbo.Audit.FrequencyFactor AS AuditFrequencyFactor, 
                      dbo.Audit.DateOfLastVisit AS AuditDateOfLastVisit, dbo.Audit.Archived AS AuditArchived, dbo.AuditVisit.DateOfVisit, dbo.AuditVisit.AuditedByUserID, 
                      dbo.AuditVisit.Archived AS Archived
FROM         dbo.Audit INNER JOIN
                      dbo.AuditVisit ON dbo.Audit.AuditID = dbo.AuditVisit.AuditID INNER JOIN
                      dbo.ContentCategory ON dbo.Audit.ContentCategoryID = dbo.ContentCategory.ContentCategoryID
GO
/****** Object:  Table [dbo].[UserDataAccessType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserDataAccessType](
	[UserDataAccessTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DataAccessType] [int] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_UserDataAccessType] PRIMARY KEY CLUSTERED 
(
	[UserDataAccessTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UserRoleID] [int] IDENTITY(1,1) NOT NULL,
	[Role] [int] NOT NULL,
	[Description] [varchar](40) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UserRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vUser]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vUser]
AS
SELECT     dbo.[User].UserId, dbo.[User].Forename, dbo.[User].Surname, dbo.[User].NetworkLogon, dbo.[User].DepartmentID, dbo.[User].SectionID, 
                      dbo.[User].WorkbaseID, dbo.[User].OccupationID, dbo.[User].EmailAddress, dbo.[User].TelephoneNumber, 
                      dbo.UserRole.Description AS RoleDescription, dbo.[User].DefaultDepartmentID, dbo.UserDataAccessType.Description AS DataAccessDescription, 
                      dbo.[User].Archived, dbo.[User].oldDepartmentID, dbo.[User].oldSectionID, dbo.[User].oldDefaultDepartmentID
FROM         dbo.[User] INNER JOIN
                      dbo.UserDataAccessType ON dbo.[User].DataAccessType = dbo.UserDataAccessType.DataAccessType INNER JOIN
                      dbo.UserRole ON dbo.[User].Role = dbo.UserRole.Role
GO
/****** Object:  Table [dbo].[WorkbaseContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkbaseContent](
	[WorkbaseContentID] [int] IDENTITY(1,1) NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[ContentID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_WorkbaseContent] PRIMARY KEY CLUSTERED 
(
	[WorkbaseContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vWorkbaseContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vWorkbaseContent]
AS
SELECT     dbo.WorkbaseContent.WorkbaseContentID, dbo.WorkbaseContent.WorkbaseID, dbo.ContentCategory.Description AS ContentCategoryDescription, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Content.HardCopyReference, dbo.Content.Description, dbo.Content.Filename, 
                      dbo.ContentType.Extension AS ContentTypeExtension, dbo.ContentType.Description AS ContentTypeDescription, dbo.Content.AttachedByUserID, 
                      dbo.Content.AttachedDate
FROM         dbo.WorkbaseContent INNER JOIN
                      dbo.Content ON dbo.WorkbaseContent.ContentID = dbo.Content.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.Content.ContentTypeID = dbo.ContentType.ContentTypeID
GO
/****** Object:  Table [dbo].[Diary]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diary](
	[DiaryID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Notes] [varchar](4000) NOT NULL,
	[ShortDescription] [varchar](60) NOT NULL,
	[Updated] [datetime] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_Diary] PRIMARY KEY CLUSTERED 
(
	[DiaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkbaseDiary]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkbaseDiary](
	[WorkbaseDiaryID] [int] IDENTITY(1,1) NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[DiaryID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_WorkbaseDiary] PRIMARY KEY CLUSTERED 
(
	[WorkbaseDiaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vWorkbaseDiary]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vWorkbaseDiary]
AS
SELECT     dbo.WorkbaseDiary.WorkbaseDiaryID, dbo.WorkbaseDiary.WorkbaseID, dbo.Diary.UserID AS DiaryUserID, dbo.Diary.Notes AS DiaryNotes, 
                      dbo.Diary.ShortDescription AS DiaryShortDescription, dbo.Diary.Updated AS DiaryUpdated
FROM         dbo.WorkbaseDiary INNER JOIN
                      dbo.Diary ON dbo.WorkbaseDiary.DiaryID = dbo.Diary.DiaryID
GO
/****** Object:  Table [dbo].[WorkbaseFunction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkbaseFunction](
	[WorkBaseFunctionID] [int] IDENTITY(1,1) NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[FunctionID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_WorkbaseFunction] PRIMARY KEY CLUSTERED 
(
	[WorkBaseFunctionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_WorkbaseFunction] UNIQUE NONCLUSTERED 
(
	[WorkbaseID] ASC,
	[FunctionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vWorkbaseFunction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vWorkbaseFunction]
AS
SELECT     dbo.WorkbaseFunction.WorkBaseFunctionID, dbo.WorkbaseFunction.WorkbaseID, dbo.WFunction.Description AS FunctionDescription, 
                      dbo.WorkbaseFunction.Archived
FROM         dbo.WorkbaseFunction INNER JOIN
                      dbo.WFunction ON dbo.WorkbaseFunction.FunctionID = dbo.WFunction.FunctionID
GO
/****** Object:  View [dbo].[WorkbaseContentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbaseContentView]
AS
SELECT     dbo.[Content].AttachedByUserID, dbo.WorkbaseContent.WorkbaseID AS WorkbaseContentWorkbaseID, dbo.[Content].Description AS ContentDescription, 
                      dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.[User].Forename, dbo.[User].Surname, dbo.[Content].AttachedDate, dbo.[Content].ContentID, 
                      dbo.[Content].ContentCategoryID, dbo.[Content].HardCopyReference, dbo.[Content].Filename, dbo.[Content].ContentTypeID, dbo.[Content].ContentStoreID, 
                      dbo.ContentType.Extension, dbo.ContentType.Description AS ContentTypeDescription, dbo.ContentType.Reader, dbo.[User].SectionID AS UserSectionID, 
                      dbo.[User].DepartmentID AS UserDepartmentID, dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.Section.Description AS SectionDescription, 
                      dbo.Department.Description AS DepartmentDescription, dbo.Property.BuildingName, dbo.ContentCategory.Archived AS ContentCategoryArchived, 
                      dbo.[Content].RowVersion, dbo.WorkbaseContent.WorkbaseContentID
FROM         dbo.WorkbaseContent INNER JOIN
                      dbo.[Content] ON dbo.WorkbaseContent.ContentID = dbo.[Content].ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.[Content].ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.[User] ON dbo.[Content].AttachedByUserID = dbo.[User].UserId INNER JOIN
                      dbo.ContentType ON dbo.[Content].ContentTypeID = dbo.ContentType.ContentTypeID INNER JOIN
                      dbo.ContentStore ON dbo.[Content].ContentStoreID = dbo.ContentStore.ContentStoreID INNER JOIN
                      dbo.Section ON dbo.[User].SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  View [dbo].[WorkbasediaryDiaryUserView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbasediaryDiaryUserView]
AS
SELECT     dbo.WorkbaseDiary.WorkbaseID, dbo.Diary.DiaryID, dbo.Diary.Notes, dbo.Diary.ShortDescription, dbo.Diary.UserID, dbo.Diary.Updated, 
                      dbo.[User].Forename, dbo.[User].Surname, dbo.[User].DepartmentID AS UserDepartmentID, dbo.[User].SectionID AS UserSectionID, 
                      dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.[Section].Description AS SectionDescription, dbo.Department.Description AS DepartmentDescription, 
                      dbo.Property.BuildingName, dbo.Diary.RowVersion
FROM         dbo.WorkbaseDiary INNER JOIN
                      dbo.Diary ON dbo.WorkbaseDiary.DiaryID = dbo.Diary.DiaryID INNER JOIN
                      dbo.[User] ON dbo.Diary.UserID = dbo.[User].UserId INNER JOIN
                      dbo.[Section] ON dbo.[User].SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  View [dbo].[WorkbaseFunctionWFunctionView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbaseFunctionWFunctionView]
AS
SELECT     dbo.WorkbaseFunction.WorkBaseFunctionID, dbo.WorkbaseFunction.WorkbaseID, dbo.WorkbaseFunction.FunctionID, 
                      dbo.WFunction.Description AS WFunctionDescription, dbo.WorkbaseFunction.Archived, dbo.WorkbaseFunction.RowVersion, 
                      dbo.WorkbaseFunction.AuditUser
FROM         dbo.WFunction INNER JOIN
                      dbo.WorkbaseFunction ON dbo.WFunction.FunctionID = dbo.WorkbaseFunction.FunctionID
GO
/****** Object:  Table [dbo].[Incident]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Incident](
	[IncidentID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[SectionID] [int] NOT NULL,
	[IncidentTypeID] [int] NOT NULL,
	[IncidentDateTime] [datetime] NOT NULL,
	[ReportedTo] [varchar](100) NOT NULL,
	[ReportedToOccupationID] [int] NOT NULL,
	[ReportedDate] [datetime] NOT NULL,
	[InjuredInvolvedIndicator] [bit] NOT NULL,
	[InjuredSurname] [varchar](30) NULL,
	[InjuredForename] [varchar](30) NULL,
	[InjuredBuildingName] [varchar](50) NULL,
	[InjuredHouseNumber] [int] NULL,
	[InjuredHouseSuffix] [varchar](50) NULL,
	[InjuredStreetName] [varchar](50) NULL,
	[InjuredTownVillage] [varchar](50) NULL,
	[InjuredPostalTown] [varchar](50) NULL,
	[InjuredCounty] [varchar](50) NULL,
	[InjuredPostcode] [varchar](10) NULL,
	[InjuredDOB] [datetime] NULL,
	[InjuredAge] [int] NULL,
	[InjuredTelephoneNo] [varchar](20) NULL,
	[InjuredSex] [int] NULL,
	[InjuredWorkbaseID] [int] NOT NULL,
	[InjuredOccupationID] [int] NOT NULL,
	[InjuredStatusID] [int] NOT NULL,
	[InjuredStatusOther] [varchar](60) NULL,
	[InjuredEmployeeNo] [int] NULL,
	[InjuredTradeUnionID] [int] NOT NULL,
	[InjuredCompanyName] [varchar](100) NULL,
	[InjuryID] [int] NOT NULL,
	[InjuryOther] [varchar](60) NULL,
	[BodyPartID] [int] NOT NULL,
	[BodyPartOther] [varchar](60) NULL,
	[AccidentTypeID] [int] NOT NULL,
	[AccidentTypeOther] [varchar](60) NULL,
	[Height] [int] NULL,
	[IncidentDescription] [varchar](4000) NOT NULL,
	[Riddor] [bit] NOT NULL,
	[AccidentReasonID] [int] NOT NULL,
	[TimeLost] [bit] NULL,
	[DaysInHospital] [int] NULL,
	[F2508BatOrgAddress] [bit] NULL,
	[F2508BWhereID] [int] NOT NULL,
	[F2508BPremises] [varchar](50) NULL,
	[F2508CPhoneNumber] [varchar](20) NULL,
	[F2508DInjuryID] [int] NOT NULL,
	[F2508DPersonID] [int] NOT NULL,
	[HSEReferenceNo] [varchar](30) NULL,
	[ResponsibleUserID] [int] NOT NULL,
	[ResponsibleWorkBaseID] [int] NOT NULL,
	[ResponsibleOccupationID] [int] NOT NULL,
	[CurrentStatus] [int] NOT NULL,
	[LastUpdated] [datetime] NOT NULL,
	[LastReminder] [datetime] NULL,
	[RowVersion] [timestamp] NOT NULL,
	[IncidentLocationID] [int] NOT NULL,
	[ResponsibleContactNo] [varchar](20) NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldDepartmentID] [int] NULL,
	[oldSectionID] [int] NULL,
	[ManualHandlingIndicator] [bit] NULL,
	[BodyPartTrunkOther] [varchar](60) NULL,
	[HSEReportDate] [datetime] NULL,
	[AssailantName] [varchar](250) NULL,
	[oldWorkbaseID] [int] NULL,
 CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED 
(
	[IncidentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DuplicateIncidentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DuplicateIncidentView]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.InjuredForename, dbo.Incident.InjuredSurname, dbo.[User].Forename AS InputByForename, 
                      dbo.[User].Surname AS InputBySurname, dbo.Department.Description AS DepartmentDescription, dbo.[Section].Description AS SectionDescription, 
                      dbo.Incident.ReportedDate, dbo.Incident.IncidentDateTime
FROM         dbo.Incident INNER JOIN
                      dbo.[User] ON dbo.Incident.ResponsibleUserID = dbo.[User].UserId INNER JOIN
                      dbo.Department ON dbo.Incident.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.[Section] ON dbo.Incident.SectionID = dbo.[Section].SectionID AND dbo.Department.DepartmentID = dbo.[Section].DepartmentID
GO
/****** Object:  Table [dbo].[F2508Injury]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[F2508Injury](
	[F2508InjuryID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](130) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_F2508Injury] PRIMARY KEY CLUSTERED 
(
	[F2508InjuryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_F2508Injury_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[F2508Person]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[F2508Person](
	[F2508PersonID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_F2508Person] PRIMARY KEY CLUSTERED 
(
	[F2508PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_F2508Person_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[F2508Where]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[F2508Where](
	[F2508WhereID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](70) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_F2508Where] PRIMARY KEY CLUSTERED 
(
	[F2508WhereID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_F2508Where_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncidentLocation]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentLocation](
	[IncidentLocationID] [int] IDENTITY(1,1) NOT NULL,
	[Location] [varchar](60) NULL,
	[BuildingName] [varchar](50) NULL,
	[HouseNumber] [int] NULL,
	[HouseSuffix] [varchar](50) NULL,
	[StreetName] [varchar](50) NULL,
	[TownVillage] [varchar](50) NULL,
	[PostalTown] [varchar](50) NULL,
	[County] [varchar](50) NULL,
	[Postcode] [varchar](10) NULL,
	[TelephoneNumber] [varchar](20) NULL,
	[PropertyID] [int] NULL,
	[CouncilProperty] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_IncidentLocation] PRIMARY KEY CLUSTERED 
(
	[IncidentLocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InjuredStatus]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InjuredStatus](
	[InjuredStatusID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Type] [int] NOT NULL,
	[EmailAddress] [varchar](100) NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_InjuredStatus] PRIMARY KEY CLUSTERED 
(
	[InjuredStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_InjuredStatus_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Injury]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Injury](
	[InjuryID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Injury] PRIMARY KEY CLUSTERED 
(
	[InjuryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_Injury_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BodyPart]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BodyPart](
	[BodyPartID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_BodyPart] PRIMARY KEY CLUSTERED 
(
	[BodyPartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_BodyPart_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[F2508View]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[F2508View]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.Riddor, dbo.[User].Forename AS AResponsibleForename, dbo.[User].Surname AS AResponsibleSurname, 
                      dbo.Occupation.Description AS AResponsibleOccupation, dbo.Incident.IncidentDateTime AS BIncidentDate, 
                      dbo.Incident.IncidentDateTime AS BIncidentTime, dbo.Incident.F2508BatOrgAddress AS BF2508BatOrgAddress, 
                      dbo.F2508Where.Description AS BF2508BWhereDescription, dbo.Incident.ResponsibleContactNo AS AResponsibleTelephoneNumber, 
                      dbo.Incident.F2508BWhereID AS BF2508BWhereID, dbo.Incident.F2508BPremises AS BF2508BPremises, 
                      dbo.Incident.InjuredForename AS CInjuredForename, dbo.Incident.InjuredSurname AS CInjuredSurname, 
                      dbo.Incident.InjuredBuildingName AS CInjuredBuildingName, dbo.Incident.InjuredHouseNumber AS CInjuredHouseNumber, 
                      dbo.Incident.InjuredHouseSuffix AS CInjuredHouseSuffix, dbo.Incident.InjuredStreetName AS CInjuredStreetName, 
                      dbo.Incident.InjuredTownVillage AS CInjuredTownVillage, dbo.Incident.InjuredPostalTown AS CInjuredPostalTown, 
                      dbo.Incident.InjuredCounty AS CInjuredCounty, dbo.Incident.InjuredPostcode AS CInjuredPostcode, 
                      dbo.Incident.InjuredTelephoneNo AS CInjuredTelephoneNo, dbo.Incident.InjuredAge AS CInjuredAge, dbo.Incident.InjuredSex AS CInjuredSex, 
                      dbo.Incident.InjuredStatusID AS CInjuredStatusID, dbo.InjuredStatus.Description AS CInjuredStatusDescription, 
                      dbo.Incident.InjuredCompanyName AS CInjuredCompanyName, dbo.Incident.InjuredOccupationID AS CInjuredOccupationID, 
                      dbo.Incident.InjuryID AS DInjuryID, dbo.Injury.Description AS DInjuryDescription, dbo.Incident.BodyPartID AS DBodyPartID, 
                      dbo.BodyPart.Description AS DBodyPartDescription, dbo.Incident.F2508DInjuryID AS DF2508DInjuryID, 
                      dbo.F2508Injury.Description AS DF2508DInjuryDescription, dbo.Incident.F2508DPersonID AS DF2508DPersonID, 
                      dbo.F2508Person.Description AS DF2508DPersonDescription, dbo.Incident.AccidentTypeID AS EAccidentTypeID, 
                      dbo.AccidentType.Description AS EAccidentTypeDescription, dbo.Incident.Height AS EHeight, dbo.Incident.IncidentDescription AS GIncidentDescription, 
                      dbo.Incident.ResponsibleUserID, dbo.Incident.F2508CPhoneNumber, dbo.Incident.IncidentLocationID, dbo.Incident.DepartmentID, 
                      dbo.Department.F2508Contact, dbo.IncidentLocation.Location AS IncidentLocation, dbo.IncidentLocation.BuildingName AS IncidentBuildingName, 
                      dbo.IncidentLocation.HouseNumber AS IncidentHouseNumber, dbo.IncidentLocation.HouseSuffix AS IncidentHouseSuffix, 
                      dbo.IncidentLocation.StreetName AS IncidentStreetName, dbo.IncidentLocation.TownVillage AS IncidentTownVillage, 
                      dbo.IncidentLocation.PostalTown AS IncidentPostalTown, dbo.IncidentLocation.County AS IncidentCounty, 
                      dbo.IncidentLocation.Postcode AS IncidentPostcode
FROM         dbo.Incident INNER JOIN
                      dbo.[User] ON dbo.Incident.ResponsibleUserID = dbo.[User].UserId INNER JOIN
                      dbo.Occupation ON dbo.[User].OccupationID = dbo.Occupation.OccupationID INNER JOIN
                      dbo.F2508Where ON dbo.Incident.F2508BWhereID = dbo.F2508Where.F2508WhereID INNER JOIN
                      dbo.IncidentLocation ON dbo.Incident.IncidentLocationID = dbo.IncidentLocation.IncidentLocationID INNER JOIN
                      dbo.InjuredStatus ON dbo.Incident.InjuredStatusID = dbo.InjuredStatus.InjuredStatusID INNER JOIN
                      dbo.Injury ON dbo.Incident.InjuryID = dbo.Injury.InjuryID INNER JOIN
                      dbo.BodyPart ON dbo.Incident.BodyPartID = dbo.BodyPart.BodyPartID INNER JOIN
                      dbo.F2508Injury ON dbo.Incident.F2508DInjuryID = dbo.F2508Injury.F2508InjuryID INNER JOIN
                      dbo.F2508Person ON dbo.Incident.F2508DPersonID = dbo.F2508Person.F2508PersonID INNER JOIN
                      dbo.AccidentType ON dbo.Incident.AccidentTypeID = dbo.AccidentType.AccidentTypeID INNER JOIN
                      dbo.Department ON dbo.Incident.DepartmentID = dbo.Department.DepartmentID
WHERE     (dbo.Incident.Riddor = 1)
GO
/****** Object:  Table [dbo].[Division]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Division](
	[DivisionID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[AssessmentFolder] [varchar](4000) NULL,
 CONSTRAINT [PK_Division2] PRIMARY KEY CLUSTERED 
(
	[DivisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DivisionSection]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DivisionSection](
	[DivisionSectionID] [int] IDENTITY(1,1) NOT NULL,
	[DivisionID] [int] NOT NULL,
	[SectionID] [int] NOT NULL,
	[oldSectionID] [int] NULL,
 CONSTRAINT [PK_DivisionSection] PRIMARY KEY CLUSTERED 
(
	[DivisionSectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DepartmentDivisionView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DepartmentDivisionView]
AS
SELECT DISTINCT dbo.Department.DepartmentID, dbo.Division.DivisionID, dbo.Division.Description AS DivisionName, dbo.Division.Archived
FROM         dbo.Division INNER JOIN
                      dbo.DivisionSection ON dbo.Division.DivisionID = dbo.DivisionSection.DivisionID INNER JOIN
                      dbo.Section ON dbo.DivisionSection.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID


GO
/****** Object:  Table [dbo].[IncidentStatus]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentStatus](
	[IncidentStatusID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](45) NULL,
	[ShortDescription] [varchar](15) NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_IncidentStatus] PRIMARY KEY CLUSTERED 
(
	[IncidentStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IncidentsForWorkbaseView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncidentsForWorkbaseView]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.ResponsibleWorkBaseID, dbo.[User].UserId, dbo.[User].Forename, dbo.[User].Surname, 
                      dbo.IncidentType.IncidentTypeID, dbo.IncidentType.Description AS IncidentTypeDescription, dbo.Incident.IncidentDateTime, 
                      dbo.IncidentStatus.IncidentStatusID, dbo.IncidentStatus.Description AS IncidentStatusDescription, dbo.Incident.InjuredSurname, 
                      dbo.Incident.InjuredForename
FROM         dbo.Incident INNER JOIN
                      dbo.[User] ON dbo.Incident.ResponsibleUserID = dbo.[User].UserId INNER JOIN
                      dbo.IncidentType ON dbo.Incident.IncidentTypeID = dbo.IncidentType.IncidentTypeID INNER JOIN
                      dbo.IncidentStatus ON dbo.Incident.CurrentStatus = dbo.IncidentStatus.IncidentStatusID
GO
/****** Object:  View [dbo].[DivisionSectionView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DivisionSectionView]
AS
SELECT     dbo.Division.DivisionID, dbo.Division.Description AS DivisionName, dbo.Division.AssessmentFolder, dbo.Division.Archived, dbo.Division.AuditUser, 
                      dbo.DivisionSection.DivisionSectionID, dbo.Section.SectionID, dbo.Section.Description AS SectionName, dbo.Department.DepartmentID, 
                      dbo.Department.Description AS ServiceName
FROM         dbo.Division INNER JOIN
                      dbo.DivisionSection ON dbo.Division.DivisionID = dbo.DivisionSection.DivisionID INNER JOIN
                      dbo.Section ON dbo.DivisionSection.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID


GO
/****** Object:  View [dbo].[IncidentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncidentView]
AS
SELECT     dbo.Incident.IncidentID, dbo.[User].UserId, dbo.[User].Forename AS ResponsibleUserForename, dbo.[User].Surname AS ResponsibleUserSurname, 
                      dbo.IncidentType.IncidentTypeID, dbo.IncidentType.Description AS IncidentTypeDescription, dbo.Department.DepartmentID, 
                      dbo.Department.Description AS DepartmentDescription, dbo.Section.SectionID, dbo.Section.Description AS SectionDescription, dbo.Incident.IncidentDateTime, 
                      dbo.IncidentStatus.IncidentStatusID, dbo.IncidentStatus.Description AS IncidentStatusDescription, 
                      dbo.IncidentStatus.ShortDescription AS IncidentStatusShortDescription, dbo.Incident.ResponsibleWorkBaseID, dbo.Incident.InjuredSurname, 
                      dbo.Incident.InjuredForename, dbo.Incident.BodyPartID, dbo.Incident.InjuryID, dbo.Incident.AccidentTypeID, dbo.Incident.Riddor, dbo.[User].Role, 
                      dbo.[User].DataAccessType, dbo.Incident.CurrentStatus, dbo.[User].EmailAddress AS ResponsibleUserEmailAddress, dbo.Incident.LastReminder, 
                      dbo.Incident.InjuredWorkbaseID, dbo.Incident.ReportedDate, dbo.Incident.HSEReportDate
FROM         dbo.Incident INNER JOIN
                      dbo.IncidentType ON dbo.Incident.IncidentTypeID = dbo.IncidentType.IncidentTypeID INNER JOIN
                      dbo.Section ON dbo.Incident.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.IncidentStatus ON dbo.Incident.CurrentStatus = dbo.IncidentStatus.IncidentStatusID INNER JOIN
                      dbo.[User] ON dbo.Incident.ResponsibleUserID = dbo.[User].UserId INNER JOIN
                      dbo.Department ON dbo.Incident.DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  Table [dbo].[RiskAssessment]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskAssessment](
	[RiskAssessmentID] [int] IDENTITY(1,1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[Description] [varchar](1000) NOT NULL,
	[URL] [varchar](4000) NOT NULL,
	[AddedByUserID] [int] NOT NULL,
	[DateAdded] [datetime] NOT NULL,
	[Archived] [bit] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Filename] [varchar](200) NULL,
	[oldSectionID] [int] NULL,
 CONSTRAINT [PK_RiskAssessment] PRIMARY KEY CLUSTERED 
(
	[RiskAssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[RiskAssessmentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RiskAssessmentView]
AS
SELECT     dbo.RiskAssessment.RiskAssessmentID, dbo.RiskAssessment.Description, dbo.RiskAssessment.URL, dbo.RiskAssessment.AddedByUserID, 
                      dbo.RiskAssessment.DateAdded, dbo.RiskAssessment.Archived, dbo.RiskAssessment.AuditUser, dbo.DivisionSection.DivisionSectionID, dbo.Division.DivisionID, 
                      dbo.Division.Description AS DivisionName, dbo.Section.SectionID, dbo.Section.Description AS SectionName, dbo.Department.DepartmentID, 
                      dbo.Department.Description AS ServiceName, dbo.[User].Forename, dbo.[User].Surname, dbo.RiskAssessment.Filename
FROM         dbo.Division INNER JOIN
                      dbo.DivisionSection ON dbo.Division.DivisionID = dbo.DivisionSection.DivisionID INNER JOIN
                      dbo.RiskAssessment ON dbo.DivisionSection.SectionID = dbo.RiskAssessment.SectionID INNER JOIN
                      dbo.Section ON dbo.DivisionSection.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.[User] ON dbo.RiskAssessment.AddedByUserID = dbo.[User].UserId


GO
/****** Object:  View [dbo].[mIncident]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mIncident]
AS
SELECT     dbo.Mapping.FromDepartmentID, dbo.Mapping.FromSectionID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, dbo.Incident.IncidentID, 
                      dbo.Incident.DepartmentID, dbo.Incident.SectionID, dbo.Incident.oldDepartmentID, dbo.Incident.oldSectionID, dbo.Incident.HSEReportDate
FROM         dbo.Mapping INNER JOIN
                      dbo.Incident ON dbo.Mapping.FromSectionID = dbo.Incident.SectionID
GO
/****** Object:  View [dbo].[vRiskAssessment]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRiskAssessment]
AS
SELECT     dbo.RiskAssessment.RiskAssessmentID, dbo.Department.DepartmentID, dbo.Department.Description AS DepartmentDesc, dbo.RiskAssessment.SectionID, 
                      dbo.Section.Description AS SectionDesc, dbo.RiskAssessment.Description AS AssessmentDesc, dbo.RiskAssessment.URL, dbo.RiskAssessment.AddedByUserID, 
                      dbo.RiskAssessment.DateAdded, dbo.RiskAssessment.Archived, dbo.RiskAssessment.AuditUser, dbo.RiskAssessment.Filename
FROM         dbo.RiskAssessment INNER JOIN
                      dbo.Section ON dbo.RiskAssessment.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  View [dbo].[mIncidentInjuredOcc]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mIncidentInjuredOcc]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.InjuredOccupationID, dbo.Occupation.OccupationID, dbo.Incident.DepartmentID
FROM         dbo.Incident INNER JOIN
                      dbo.Occupation ON dbo.Incident.InjuredOccupationID = dbo.Occupation.oldOccupationID AND dbo.Incident.DepartmentID = dbo.Occupation.DepartmentID
GO
/****** Object:  View [dbo].[mIncidentReportedToOcc]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mIncidentReportedToOcc]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.ReportedToOccupationID, dbo.Occupation.OccupationID, dbo.Incident.DepartmentID
FROM         dbo.Incident INNER JOIN
                      dbo.Occupation ON dbo.Incident.DepartmentID = dbo.Occupation.DepartmentID AND 
                      dbo.Incident.ReportedToOccupationID = dbo.Occupation.oldOccupationID
GO
/****** Object:  View [dbo].[mIncidentResponsibleOcc]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mIncidentResponsibleOcc]
AS
SELECT     dbo.Incident.IncidentID, dbo.Incident.ResponsibleOccupationID, dbo.Occupation.OccupationID, dbo.Incident.DepartmentID
FROM         dbo.Incident INNER JOIN
                      dbo.Occupation ON dbo.Incident.ResponsibleOccupationID = dbo.Occupation.oldOccupationID AND 
                      dbo.Incident.DepartmentID = dbo.Occupation.DepartmentID
GO
/****** Object:  View [dbo].[mUserAccess]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mUserAccess]
AS
SELECT     TOP 100 PERCENT dbo.Mapping.FromDepartmentID, dbo.Mapping.FromSectionID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, 
                      dbo.Mapping.ToSectionDescription, dbo.UserAccess.UserAccessID, dbo.UserAccess.DepartmentID, dbo.UserAccess.SectionID, 
                      dbo.UserAccess.oldDepartmentID, dbo.UserAccess.oldSectionID
FROM         dbo.Mapping INNER JOIN
                      dbo.UserAccess ON dbo.Mapping.FromSectionID = dbo.UserAccess.SectionID
GO
/****** Object:  View [dbo].[mUserAccessDept]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mUserAccessDept]
AS
SELECT     dbo.[User].UserId, dbo.[User].DefaultDepartmentID, dbo.[User].DataAccessType, dbo.[User].oldDefaultDepartmentID, dbo.UserAccess.UserAccessID, 
                      dbo.UserAccess.DepartmentID, dbo.UserAccess.oldDepartmentID
FROM         dbo.UserAccess INNER JOIN
                      dbo.[User] ON dbo.UserAccess.DepartmentID = dbo.[User].oldDefaultDepartmentID
WHERE     (dbo.[User].DataAccessType = 1)
GO
/****** Object:  View [dbo].[SectionDataAccessView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SectionDataAccessView]
AS
SELECT     dbo.UserAccess.UserID, dbo.Department.DepartmentID, dbo.Department.Description AS DepartmentDescription, 
                      dbo.Department.Archived AS DepartmentArchived, dbo.[Section].SectionID, dbo.[Section].Description AS SectionDescription, 
                      dbo.[Section].Archived AS SectionArchived, dbo.Workbase.WorkBaseID, dbo.Workbase.Archived AS WorkbaseArchived, dbo.Property.PropertyID, 
                      dbo.Property.BuildingName
FROM         dbo.Property INNER JOIN
                      dbo.Workbase ON dbo.Property.PropertyID = dbo.Workbase.PropertyID INNER JOIN
                      dbo.[Section] ON dbo.Workbase.SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.UserAccess ON dbo.[Section].SectionID = dbo.UserAccess.SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  View [dbo].[UserDataAccessView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserDataAccessView]
AS
SELECT     TOP 100 PERCENT dbo.[User].Forename, dbo.UserAccess.UserID, dbo.UserAccess.DepartmentID, 
                      dbo.Department.Description AS DepartmentDescription, dbo.Department.Archived AS DepartmentArchived, dbo.UserAccess.SectionID, 
                      dbo.[Section].Description AS SectionDescription, dbo.[Section].Archived AS SectionArchived, dbo.UserAccess.WorkbaseID, 
                      dbo.Workbase.Archived AS WorkbaseArchived, dbo.Property.PropertyID, dbo.Property.BuildingName
FROM         dbo.UserAccess INNER JOIN
                      dbo.[Section] ON dbo.UserAccess.SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.[User] ON dbo.UserAccess.UserID = dbo.[User].UserId LEFT OUTER JOIN
                      dbo.Property INNER JOIN
                      dbo.Workbase ON dbo.Property.PropertyID = dbo.Workbase.PropertyID ON dbo.UserAccess.WorkbaseID = dbo.Workbase.WorkBaseID AND 
                      dbo.[Section].SectionID = dbo.Workbase.SectionID
ORDER BY dbo.UserAccess.UserID
GO
/****** Object:  Table [dbo].[TradeUnion]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TradeUnion](
	[TradeUnionID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](120) NOT NULL,
	[EmailAddress] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_TradeUnion] PRIMARY KEY CLUSTERED 
(
	[TradeUnionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_TradeUnion_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccidentReason]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccidentReason](
	[AccidentReasonID] [int] IDENTITY(0,1) NOT NULL,
	[Description] [varchar](60) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_AccidentReason] PRIMARY KEY CLUSTERED 
(
	[AccidentReasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_AccidentReason_Description] UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vIncident]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIncident]
AS
SELECT     dbo.Incident.IncidentID, dbo.Department.Description AS DepartmentDescription, dbo.Section.Description AS SectionDescription, 
                      dbo.IncidentType.Description AS IncidentTypeDescription, dbo.IncidentType.Archived AS IncidentTypeArchived, dbo.Incident.IncidentDateTime, 
                      dbo.Incident.ReportedTo, dbo.Incident.ReportedToOccupationID, dbo.Incident.ReportedDate, dbo.Incident.InjuredInvolvedIndicator, dbo.Incident.InjuredSurname, 
                      dbo.Incident.InjuredForename, dbo.Incident.InjuredBuildingName, dbo.Incident.InjuredHouseNumber, dbo.Incident.InjuredHouseSuffix, dbo.Incident.InjuredStreetName,
                       dbo.Incident.InjuredTownVillage, dbo.Incident.InjuredPostalTown, dbo.Incident.InjuredCounty, dbo.Incident.InjuredPostcode, dbo.Incident.InjuredDOB, 
                      dbo.Incident.InjuredAge, dbo.Incident.InjuredTelephoneNo, dbo.Incident.InjuredSex, dbo.Incident.InjuredWorkbaseID, dbo.Incident.InjuredOccupationID, 
                      dbo.InjuredStatus.Description AS InjuredStatusDescription, dbo.InjuredStatus.Type AS InjuredStatusType, 
                      dbo.InjuredStatus.EmailAddress AS InjuredStatusEmailAddress, dbo.InjuredStatus.Archived AS InjuredStatusArchived, dbo.Incident.InjuredStatusOther, 
                      dbo.Incident.InjuredEmployeeNo, dbo.TradeUnion.Description AS InjuredTradeUnionDescription, dbo.TradeUnion.EmailAddress AS InjuredTradeUnionEmailAddress, 
                      dbo.TradeUnion.Archived AS InjuredTradeUnionArchived, dbo.Incident.InjuredCompanyName, dbo.Injury.Description AS InjuryDescription, 
                      dbo.Injury.Archived AS InjuryArchived, dbo.Incident.InjuryOther, dbo.BodyPart.Description AS BodyPartDescription, dbo.BodyPart.Archived AS BodyPartArchived, 
                      dbo.Incident.BodyPartOther, dbo.AccidentType.Description AS AccidentTypeDescription, dbo.AccidentType.Archived AS AccidentTypeArchived, 
                      dbo.Incident.AccidentTypeOther, dbo.Incident.Height, dbo.Incident.IncidentDescription, dbo.Incident.Riddor, 
                      dbo.AccidentReason.Description AS AccidentReasonDescription, dbo.AccidentReason.Archived AS AccidentReasonArchived, dbo.Incident.TimeLost, 
                      dbo.Incident.DaysInHospital, dbo.Incident.F2508BatOrgAddress, dbo.F2508Where.Description AS F2508WhereDescription, 
                      dbo.F2508Where.Archived AS F2508WhereArchived, dbo.Incident.F2508BPremises, dbo.Incident.F2508CPhoneNumber, 
                      dbo.F2508Injury.Description AS F2508InjuryDescription, dbo.F2508Injury.Archived AS F2508InjuryArchived, dbo.F2508Person.Description AS F2508PersonDescription, 
                      dbo.F2508Person.Archived AS F2508PersonArchived, dbo.Incident.HSEReferenceNo, dbo.Incident.ResponsibleUserID, dbo.Incident.ResponsibleWorkBaseID, 
                      dbo.Incident.ResponsibleOccupationID, IncidentStatus_1.Description AS CurrentStatusDescription, 
                      IncidentStatus_1.ShortDescription AS CurrentStatusShortDescription, IncidentStatus_1.Archived AS CurrentStatusArchived, dbo.Incident.LastUpdated, 
                      dbo.Incident.LastReminder, dbo.IncidentLocation.Location AS IncidentLocation, dbo.IncidentLocation.BuildingName AS IncidentLocationBuildingName, 
                      dbo.IncidentLocation.HouseNumber AS IncidentLocationHouseNumber, dbo.IncidentLocation.HouseSuffix AS IncidentLocationHouseSuffix, 
                      dbo.IncidentLocation.StreetName AS IncidentLocationStreetName, dbo.IncidentLocation.TownVillage AS IncidentLocationTownVillage, 
                      dbo.IncidentLocation.PostalTown AS IncidentLocationPostalTown, dbo.IncidentLocation.County AS IncidentLocationCounty, 
                      dbo.IncidentLocation.Postcode AS IncidentLocationPostCode, dbo.IncidentLocation.TelephoneNumber AS IncidentLocationTelephoneNumber, 
                      dbo.IncidentLocation.PropertyID AS IncidentLocationPropertyID, dbo.IncidentLocation.CouncilProperty AS IncidentLocationCouncilProperty, 
                      dbo.Incident.ResponsibleContactNo, dbo.Incident.oldDepartmentID, dbo.Incident.oldSectionID, dbo.Incident.ManualHandlingIndicator, 
                      dbo.Incident.BodyPartTrunkOther, dbo.Incident.HSEReportDate
FROM         dbo.Incident INNER JOIN
                      dbo.Department ON dbo.Incident.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Section ON dbo.Incident.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.IncidentType ON dbo.Incident.IncidentTypeID = dbo.IncidentType.IncidentTypeID INNER JOIN
                      dbo.InjuredStatus ON dbo.Incident.InjuredStatusID = dbo.InjuredStatus.InjuredStatusID INNER JOIN
                      dbo.TradeUnion ON dbo.Incident.InjuredTradeUnionID = dbo.TradeUnion.TradeUnionID INNER JOIN
                      dbo.BodyPart ON dbo.Incident.BodyPartID = dbo.BodyPart.BodyPartID INNER JOIN
                      dbo.AccidentReason ON dbo.Incident.AccidentReasonID = dbo.AccidentReason.AccidentReasonID INNER JOIN
                      dbo.IncidentStatus ON dbo.Incident.CurrentStatus = dbo.IncidentStatus.IncidentStatusID INNER JOIN
                      dbo.IncidentLocation ON dbo.Incident.IncidentLocationID = dbo.IncidentLocation.IncidentLocationID INNER JOIN
                      dbo.Injury ON dbo.Incident.InjuryID = dbo.Injury.InjuryID INNER JOIN
                      dbo.F2508Injury ON dbo.Incident.F2508DInjuryID = dbo.F2508Injury.F2508InjuryID INNER JOIN
                      dbo.F2508Person ON dbo.Incident.F2508DPersonID = dbo.F2508Person.F2508PersonID INNER JOIN
                      dbo.F2508Where ON dbo.Incident.F2508BWhereID = dbo.F2508Where.F2508WhereID INNER JOIN
                      dbo.AccidentType ON dbo.Incident.AccidentTypeID = dbo.AccidentType.AccidentTypeID INNER JOIN
                      dbo.IncidentStatus AS IncidentStatus_1 ON dbo.Incident.CurrentStatus = IncidentStatus_1.IncidentStatusID
GO
/****** Object:  View [dbo].[WorkBaseDataAccessView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkBaseDataAccessView]
AS
SELECT     dbo.UserAccess.UserID, dbo.Department.DepartmentID, dbo.Department.Description AS DepartmentDescription, 
                      dbo.Department.Archived AS DepartmentArchived, dbo.[Section].SectionID, dbo.[Section].Description AS SectionDescription, 
                      dbo.[Section].Archived AS SectionArchived, dbo.Workbase.WorkBaseID, dbo.Workbase.Archived AS WorkbaseArchived, dbo.Property.PropertyID, 
                      dbo.Property.BuildingName
FROM         dbo.Property INNER JOIN
                      dbo.Workbase ON dbo.Property.PropertyID = dbo.Workbase.PropertyID INNER JOIN
                      dbo.UserAccess ON dbo.Workbase.WorkBaseID = dbo.UserAccess.WorkbaseID INNER JOIN
                      dbo.[Section] ON dbo.Workbase.SectionID = dbo.[Section].SectionID INNER JOIN
                      dbo.Department ON dbo.[Section].DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  Table [dbo].[IncidentApprovalHistory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentApprovalHistory](
	[IncidentHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[IncidentID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[UserWorkbaseID] [int] NOT NULL,
	[UserOccupationID] [int] NOT NULL,
	[Comments] [varchar](4000) NULL,
	[ActionTaken] [int] NOT NULL,
	[ActionedDate] [datetime] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_IncidentApprovalHistory] PRIMARY KEY CLUSTERED 
(
	[IncidentHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ApprovalHistoryUserOccupationView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ApprovalHistoryUserOccupationView]
AS
SELECT     dbo.IncidentApprovalHistory.IncidentHistoryID, dbo.IncidentApprovalHistory.IncidentID, dbo.IncidentApprovalHistory.UserID, dbo.[User].Forename, 
                      dbo.[User].Surname, dbo.IncidentApprovalHistory.UserOccupationID, dbo.Occupation.Description AS OccupationDescription, 
                      dbo.IncidentApprovalHistory.ActionTaken, dbo.IncidentApprovalHistory.ActionedDate, dbo.IncidentApprovalHistory.Comments, 
                      dbo.[User].TelephoneNumber
FROM         dbo.[User] INNER JOIN
                      dbo.IncidentApprovalHistory ON dbo.[User].UserId = dbo.IncidentApprovalHistory.UserID INNER JOIN
                      dbo.Occupation ON dbo.IncidentApprovalHistory.UserOccupationID = dbo.Occupation.OccupationID
GO
/****** Object:  Table [dbo].[IncidentContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentContent](
	[IncidentContentID] [int] IDENTITY(1,1) NOT NULL,
	[IncidentID] [int] NOT NULL,
	[ContentID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_IncidentContent] PRIMARY KEY CLUSTERED 
(
	[IncidentContentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IncidentContentView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncidentContentView]
AS
SELECT     dbo.IncidentContent.IncidentContentID, dbo.[Content].AttachedByUserID, dbo.[User].Forename, dbo.[User].Surname, 
                      dbo.ContentCategory.Description AS ContentCategoryDescription, dbo.[Content].Description AS ContentDescription, dbo.IncidentContent.IncidentID, 
                      dbo.[Content].AttachedDate, dbo.[Content].ContentID, dbo.[Content].Filename, dbo.[Content].ContentTypeID, dbo.[Content].ContentStoreID, 
                      dbo.[Content].HardCopyReference, dbo.[Content].ContentCategoryID, dbo.ContentType.Extension, dbo.ContentType.Description AS ContentTypeDescription, 
                      dbo.ContentType.Reader, dbo.[User].SectionID AS UserSectionID, dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.Department.Description, 
                      dbo.Property.BuildingName, dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.[User].DepartmentID AS UserDepartmentID, dbo.[Content].RowVersion, 
                      dbo.IncidentContent.ContentID AS Expr1
FROM         dbo.IncidentContent INNER JOIN
                      dbo.[Content] ON dbo.IncidentContent.ContentID = dbo.[Content].ContentID INNER JOIN
                      dbo.[User] ON dbo.[Content].AttachedByUserID = dbo.[User].UserId INNER JOIN
                      dbo.ContentCategory ON dbo.[Content].ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.[Content].ContentTypeID = dbo.ContentType.ContentTypeID INNER JOIN
                      dbo.ContentStore ON dbo.[Content].ContentStoreID = dbo.ContentStore.ContentStoreID INNER JOIN
                      dbo.Section ON dbo.[User].SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID INNER JOIN
                      dbo.Department ON dbo.[User].DepartmentID = dbo.Department.DepartmentID
GO
/****** Object:  Table [dbo].[IncidentDiary]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentDiary](
	[IncidentDiaryID] [int] IDENTITY(1,1) NOT NULL,
	[IncidentID] [int] NOT NULL,
	[DiaryID] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_IncidentDiary] PRIMARY KEY CLUSTERED 
(
	[IncidentDiaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IncidentdiaryDiaryUserView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncidentdiaryDiaryUserView]
AS
SELECT     dbo.IncidentDiary.IncidentID, dbo.Diary.DiaryID, dbo.Diary.UserID, dbo.Diary.Notes, dbo.Diary.ShortDescription, dbo.Diary.Updated, dbo.[User].Forename, 
                      dbo.[User].Surname, dbo.Section.Description AS SectionDescription, dbo.Department.Description AS DepartmentDescription, 
                      dbo.[User].DepartmentID AS UserDepartmentID, dbo.[User].SectionID AS UserSectionID, dbo.[User].WorkbaseID AS UserWorkbaseID, dbo.Property.BuildingName, 
                      dbo.Diary.RowVersion, dbo.IncidentDiary.IncidentDiaryID
FROM         dbo.IncidentDiary INNER JOIN
                      dbo.Diary ON dbo.IncidentDiary.DiaryID = dbo.Diary.DiaryID INNER JOIN
                      dbo.[User] ON dbo.Diary.UserID = dbo.[User].UserId INNER JOIN
                      dbo.Section ON dbo.[User].SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[User].WorkbaseID = dbo.Workbase.WorkBaseID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
GO
/****** Object:  Table [dbo].[IncidentOtherBodyPart]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentOtherBodyPart](
	[IncidentID] [int] NOT NULL,
	[BodyPartID] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_IncidentOtherBodyPart] PRIMARY KEY CLUSTERED 
(
	[IncidentID] ASC,
	[BodyPartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IncidentOtherBodyPartBodyPartView]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncidentOtherBodyPartBodyPartView]
AS
SELECT     dbo.IncidentOtherBodyPart.IncidentID, dbo.BodyPart.BodyPartID, dbo.BodyPart.Description, 
                      dbo.IncidentOtherBodyPart.Archived AS IncidentOtherBodyPartArchived
FROM         dbo.BodyPart INNER JOIN
                      dbo.IncidentOtherBodyPart ON dbo.BodyPart.BodyPartID = dbo.IncidentOtherBodyPart.BodyPartID
GO
/****** Object:  Table [dbo].[IncidentApprovalHistoryActionTaken]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentApprovalHistoryActionTaken](
	[ActionTaken] [int] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_IncidentApprovalHistoryActionTaken] PRIMARY KEY CLUSTERED 
(
	[ActionTaken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vIncidentApprovalHistory]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIncidentApprovalHistory]
AS
SELECT     dbo.IncidentApprovalHistory.IncidentHistoryID, dbo.IncidentApprovalHistory.IncidentID, dbo.IncidentApprovalHistory.UserID, 
                      dbo.IncidentApprovalHistory.UserWorkbaseID, dbo.Occupation.Description AS UserOccupationDescription, dbo.IncidentApprovalHistory.Comments, 
                      dbo.IncidentApprovalHistoryActionTaken.Description AS ActionTakenDescription, dbo.IncidentApprovalHistory.ActionedDate, 
                      dbo.IncidentApprovalHistory.ActionTaken
FROM         dbo.IncidentApprovalHistory INNER JOIN
                      dbo.Occupation ON dbo.IncidentApprovalHistory.UserOccupationID = dbo.Occupation.OccupationID INNER JOIN
                      dbo.IncidentApprovalHistoryActionTaken ON dbo.IncidentApprovalHistory.ActionTaken = dbo.IncidentApprovalHistoryActionTaken.ActionTaken
GO
/****** Object:  View [dbo].[vIncidentContent]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIncidentContent]
AS
SELECT     dbo.IncidentContent.IncidentContentID, dbo.IncidentContent.IncidentID, dbo.ContentCategory.Description AS ContentCategoryDescription, 
                      dbo.ContentCategory.Archived AS ContentCategoryArchived, dbo.Content.HardCopyReference, dbo.Content.Description, dbo.Content.Filename, 
                      dbo.ContentType.Extension AS ContentTypeExtension, dbo.ContentType.Description AS ContentTypeDescription, dbo.Content.AttachedByUserID, 
                      dbo.Content.AttachedDate
FROM         dbo.IncidentContent INNER JOIN
                      dbo.Content ON dbo.IncidentContent.ContentID = dbo.Content.ContentID INNER JOIN
                      dbo.ContentCategory ON dbo.Content.ContentCategoryID = dbo.ContentCategory.ContentCategoryID INNER JOIN
                      dbo.ContentType ON dbo.Content.ContentTypeID = dbo.ContentType.ContentTypeID
GO
/****** Object:  View [dbo].[vIncidentDiary]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIncidentDiary]
AS
SELECT     dbo.IncidentDiary.IncidentDiaryID, dbo.IncidentDiary.IncidentID, dbo.Diary.UserID AS DiaryUserID, dbo.Diary.Notes AS DiaryNotes, 
                      dbo.Diary.ShortDescription AS DiaryShortDescription, dbo.Diary.Updated AS DiaryUpdated
FROM         dbo.Diary INNER JOIN
                      dbo.IncidentDiary ON dbo.Diary.DiaryID = dbo.IncidentDiary.DiaryID
GO
/****** Object:  View [dbo].[vIncidentOtherBodyPart]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vIncidentOtherBodyPart]
AS
SELECT     dbo.IncidentOtherBodyPart.IncidentID, dbo.BodyPart.Description AS BodyPartDescription, dbo.BodyPart.Archived AS BodyPartArchived
FROM         dbo.IncidentOtherBodyPart INNER JOIN
                      dbo.BodyPart ON dbo.IncidentOtherBodyPart.BodyPartID = dbo.BodyPart.BodyPartID
GO
/****** Object:  View [dbo].[Colin - LIVE workbase view]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Colin - LIVE workbase view]
AS
SELECT     dbo.Workbase.WorkBaseID, dbo.Department.Description AS Services, dbo.[Section].Description AS Section, dbo.Property.BuildingName, 
                      dbo.Property.HouseNumber, dbo.Property.HouseSuffix, dbo.Property.StreetName, dbo.Property.TownVillage, dbo.Property.PostalTown, 
                      dbo.Property.County, dbo.Property.Postcode, dbo.Property.TelephoneNumber, dbo.Property.PropertyManager, dbo.Property.EmailAddress, 
                      dbo.Property.Information, dbo.Property.UPRN
FROM         dbo.Department INNER JOIN
                      dbo.[Section] ON dbo.Department.DepartmentID = dbo.[Section].DepartmentID INNER JOIN
                      dbo.Workbase ON dbo.[Section].SectionID = dbo.Workbase.SectionID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
WHERE     (dbo.Workbase.Archived = 0)
GO
/****** Object:  View [dbo].[WorkbaseCR]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbaseCR]
AS
SELECT     TOP 100 PERCENT dbo.Workbase.WorkBaseID, dbo.Section.Description AS [Section], dbo.Department.Description AS Department, 
                      dbo.Property.BuildingName, dbo.Workbase.SectionID, dbo.Workbase.PropertyID, dbo.Workbase.Archived, dbo.Workbase.AuditUser
FROM         dbo.Workbase INNER JOIN
                      dbo.Section ON dbo.Workbase.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
WHERE     (dbo.Workbase.Archived = 0) AND (dbo.Workbase.SectionID = 292)
ORDER BY dbo.Workbase.PropertyID, dbo.Workbase.SectionID
GO
/****** Object:  View [dbo].[WorkbaseCFac]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkbaseCFac]
AS
SELECT     TOP 100 PERCENT dbo.Workbase.WorkBaseID, dbo.Section.Description AS Section, dbo.Department.Description AS Department, 
                      dbo.Property.BuildingName, dbo.Workbase.SectionID, dbo.Workbase.PropertyID, dbo.Workbase.Archived, dbo.Workbase.RowVersion, 
                      dbo.Workbase.AuditUser, dbo.Workbase.oldSectionID
FROM         dbo.Workbase INNER JOIN
                      dbo.Section ON dbo.Workbase.SectionID = dbo.Section.SectionID INNER JOIN
                      dbo.Department ON dbo.Section.DepartmentID = dbo.Department.DepartmentID INNER JOIN
                      dbo.Property ON dbo.Workbase.PropertyID = dbo.Property.PropertyID
WHERE     (dbo.Section.Description = 'Community facilities') AND (dbo.Workbase.Archived = 0)
ORDER BY dbo.Workbase.WorkBaseID
GO
/****** Object:  View [dbo].[VIEW1]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW1]
AS
SELECT     TOP (100) PERCENT UserId, Forename, Surname, NetworkLogon, DepartmentID, SectionID, WorkbaseID, OccupationID, EmailAddress, TelephoneNumber, Role, 
                      DefaultDepartmentID, DataAccessType, Archived, RowVersion, AuditUser, oldDepartmentID, oldSectionID, oldDefaultDepartmentID
FROM         dbo.[User]
WHERE     (Surname = 'mccormack')
ORDER BY Forename
GO
/****** Object:  View [dbo].[mDivisionSection]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mDivisionSection]
AS
SELECT        dbo.Mapping.FromDepartmentID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, dbo.Mapping.ToSectionDescription, 
                         dbo.DivisionSection.DivisionSectionID, dbo.DivisionSection.SectionID, dbo.DivisionSection.oldSectionID, dbo.Mapping.FromSectionID
FROM            dbo.Mapping INNER JOIN
                         dbo.DivisionSection ON dbo.Mapping.FromSectionID = dbo.DivisionSection.DivisionID
WHERE        (dbo.Mapping.FromSectionID <> dbo.Mapping.ToSectionID)
GO
/****** Object:  View [dbo].[mRiskAssessment]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mRiskAssessment]
AS
SELECT        dbo.Mapping.FromDepartmentID, dbo.Mapping.ToDepartmentID, dbo.Mapping.ToSectionID, dbo.Mapping.ToSectionDescription, 
                         dbo.RiskAssessment.RiskAssessmentID, dbo.RiskAssessment.SectionID, dbo.RiskAssessment.oldSectionID
FROM            dbo.Mapping INNER JOIN
                         dbo.RiskAssessment ON dbo.Mapping.FromSectionID = dbo.RiskAssessment.SectionID
WHERE        (dbo.Mapping.FromSectionID <> dbo.Mapping.ToSectionID)
GO
/****** Object:  UserDefinedFunction [dbo].[DisableTriggers]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[DisableTriggers] (@tcTableName SYSNAME)
   RETURNS TABLE AS
   RETURN
   (
      SELECT
         name,
         status = CASE WHEN OBJECTPROPERTY (id, 'ExecIsTriggerDisabled') = 1
            THEN 'Disabled' END,
         owner = OBJECT_NAME (parent_obj)
      FROM
         sysobjects
      WHERE
         type = 'TR' AND
         parent_obj = CASE WHEN @tcTableName IS NULL THEN parent_obj ELSE OBJECT_ID (@tcTableName) END
   )
GO
/****** Object:  UserDefinedFunction [dbo].[EnableTriggers]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[EnableTriggers] (@tcTableName SYSNAME)
   RETURNS TABLE AS
   RETURN
   (
      SELECT
         name,
         status = CASE WHEN OBJECTPROPERTY (id, 'ExecIsTriggerDisabled') = 0
            THEN 'Enabled' END,
         owner = OBJECT_NAME (parent_obj)
      FROM
         sysobjects
      WHERE
         type = 'TR' AND
         parent_obj = CASE WHEN @tcTableName IS NULL THEN parent_obj ELSE OBJECT_ID (@tcTableName) END
   )
GO
/****** Object:  UserDefinedFunction [dbo].[GetTriggerStatus]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetTriggerStatus] (@tcTableName SYSNAME)
   RETURNS TABLE AS
   RETURN
   (
      SELECT
         name,
         status = CASE WHEN OBJECTPROPERTY (id, 'ExecIsTriggerDisabled') = 1
            THEN 'Disabled' END,
         owner = OBJECT_NAME (parent_obj)
      FROM
         sysobjects
      WHERE
         type = 'TR' AND
         parent_obj = CASE WHEN @tcTableName IS NULL THEN parent_obj ELSE OBJECT_ID (@tcTableName) END
   )
GO
/****** Object:  Table [dbo].[AuditControl]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditControl](
	[TableName] [varchar](256) NOT NULL,
	[Audit] [bit] NOT NULL,
	[AuditUser] [varchar](100) NULL,
 CONSTRAINT [PK_AuditTable] PRIMARY KEY CLUSTERED 
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DTSControl]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DTSControl](
	[dbname] [varchar](40) NULL,
	[owner] [varchar](30) NULL,
	[table_name] [varchar](40) NULL,
	[Row_count] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HomePage]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HomePage](
	[HomePageID] [int] IDENTITY(1,1) NOT NULL,
	[Value] [varchar](4000) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncidentOtherEmailUser]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentOtherEmailUser](
	[IncidentID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_IncidentOtherEmailUser_1] PRIMARY KEY NONCLUSTERED 
(
	[IncidentID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [PK_IncidentOtherEmailUser] UNIQUE CLUSTERED 
(
	[IncidentID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncidentStatusOldNewXREF]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentStatusOldNewXREF](
	[OldID] [int] NOT NULL,
	[NewID] [int] NULL,
 CONSTRAINT [PK_IncidentStatusOldNewXREF] PRIMARY KEY CLUSTERED 
(
	[OldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IncidentWitness]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncidentWitness](
	[IncidentWitnessID] [int] IDENTITY(1,1) NOT NULL,
	[IncidentID] [int] NOT NULL,
	[Forename] [varchar](30) NOT NULL,
	[Surname] [varchar](30) NOT NULL,
	[BuildingName] [varchar](50) NULL,
	[HouseNumber] [int] NULL,
	[HouseSuffix] [varchar](50) NULL,
	[StreetName] [varchar](50) NULL,
	[TownVillage] [varchar](50) NULL,
	[PostalTown] [varchar](50) NOT NULL,
	[County] [varchar](50) NULL,
	[PostCode] [varchar](10) NULL,
	[CouncilEmployee] [bit] NULL,
	[EmployeeNumber] [int] NULL,
	[TelephoneNumber] [varchar](20) NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[Archived] [bit] NOT NULL,
 CONSTRAINT [PK_IncidentWitness] PRIMARY KEY CLUSTERED 
(
	[IncidentWitnessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InjuredStatusType]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InjuredStatusType](
	[InjuredStatusTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [int] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
 CONSTRAINT [PK_InjuredStatusType_1] PRIMARY KEY CLUSTERED 
(
	[Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LinkedAction]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkedAction](
	[CorrectiveActionID] [int] NOT NULL,
	[LinkedActionID] [int] NOT NULL,
 CONSTRAINT [UNIQUE_CorrectiveAction_LinkedAction] UNIQUE CLUSTERED 
(
	[CorrectiveActionID] ASC,
	[LinkedActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MappingWorkbase]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MappingWorkbase](
	[PropertyID] [int] NOT NULL,
	[SectionID] [int] NOT NULL,
	[WorkbaseID] [int] NOT NULL,
	[NewWorkbaseID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NLC_163Temp]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NLC_163Temp](
	[WorkBaseID] [int] IDENTITY(0,1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldSectionID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NLC_292Temp]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NLC_292Temp](
	[WorkBaseID] [int] IDENTITY(0,1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldSectionID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NLC_Workbase14Jun11]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NLC_Workbase14Jun11](
	[WorkBaseID] [int] IDENTITY(0,1) NOT NULL,
	[SectionID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Archived] [bit] NOT NULL,
	[RowVersion] [timestamp] NOT NULL,
	[AuditUser] [varchar](100) NOT NULL,
	[oldSectionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_InjuredWorkbaseID]  DEFAULT (0) FOR [InjuredWorkbaseID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_InjuredOccupationID]  DEFAULT (0) FOR [InjuredOccupationID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_InjuredStatusID]  DEFAULT (0) FOR [InjuredStatusID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_InjuredTradeUnionID]  DEFAULT (0) FOR [InjuredTradeUnionID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_InjuryID]  DEFAULT (0) FOR [InjuryID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_BodyPartID]  DEFAULT (0) FOR [BodyPartID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_AccidentTypeID]  DEFAULT (0) FOR [AccidentTypeID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_AccidentReasonID]  DEFAULT (0) FOR [AccidentReasonID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_F2058BWhereID]  DEFAULT (0) FOR [F2508BWhereID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_F2058DInjuryID]  DEFAULT (0) FOR [F2508DInjuryID]
GO
ALTER TABLE [dbo].[Incident] ADD  CONSTRAINT [DF_Incident_F2058DPersonID]  DEFAULT (0) FOR [F2508DPersonID]
GO
ALTER TABLE [dbo].[Audit]  WITH CHECK ADD  CONSTRAINT [FK_Audit_ContentCategory] FOREIGN KEY([ContentCategoryID])
REFERENCES [dbo].[ContentCategory] ([ContentCategoryID])
GO
ALTER TABLE [dbo].[Audit] CHECK CONSTRAINT [FK_Audit_ContentCategory]
GO
ALTER TABLE [dbo].[Audit]  WITH CHECK ADD  CONSTRAINT [FK_Audit_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[Audit] CHECK CONSTRAINT [FK_Audit_Property]
GO
ALTER TABLE [dbo].[Audit]  WITH CHECK ADD  CONSTRAINT [FK_Audit_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[Audit] CHECK CONSTRAINT [FK_Audit_Workbase]
GO
ALTER TABLE [dbo].[AuditVisit]  WITH CHECK ADD  CONSTRAINT [FK_AuditVisit_User] FOREIGN KEY([AuditedByUserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[AuditVisit] CHECK CONSTRAINT [FK_AuditVisit_User]
GO
ALTER TABLE [dbo].[AuditVisitContent]  WITH CHECK ADD  CONSTRAINT [FK_AuditVisitContent_AuditVisit] FOREIGN KEY([AuditVisitID])
REFERENCES [dbo].[AuditVisit] ([AuditVisitID])
GO
ALTER TABLE [dbo].[AuditVisitContent] CHECK CONSTRAINT [FK_AuditVisitContent_AuditVisit]
GO
ALTER TABLE [dbo].[AuditVisitContent]  WITH CHECK ADD  CONSTRAINT [FK_AuditVisitContent_Content] FOREIGN KEY([ContentID])
REFERENCES [dbo].[Content] ([ContentID])
GO
ALTER TABLE [dbo].[AuditVisitContent] CHECK CONSTRAINT [FK_AuditVisitContent_Content]
GO
ALTER TABLE [dbo].[Content]  WITH CHECK ADD  CONSTRAINT [FK_Content_ContentCategory] FOREIGN KEY([ContentCategoryID])
REFERENCES [dbo].[ContentCategory] ([ContentCategoryID])
GO
ALTER TABLE [dbo].[Content] CHECK CONSTRAINT [FK_Content_ContentCategory]
GO
ALTER TABLE [dbo].[Content]  WITH CHECK ADD  CONSTRAINT [FK_Content_ContentStore] FOREIGN KEY([ContentStoreID])
REFERENCES [dbo].[ContentStore] ([ContentStoreID])
GO
ALTER TABLE [dbo].[Content] CHECK CONSTRAINT [FK_Content_ContentStore]
GO
ALTER TABLE [dbo].[Content]  WITH CHECK ADD  CONSTRAINT [FK_Content_ContentType] FOREIGN KEY([ContentTypeID])
REFERENCES [dbo].[ContentType] ([ContentTypeID])
GO
ALTER TABLE [dbo].[Content] CHECK CONSTRAINT [FK_Content_ContentType]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_AdvisoryOfficer] FOREIGN KEY([AdvisoryOfficerID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_AdvisoryOfficer]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_ContentCategory] FOREIGN KEY([ContentCategoryID])
REFERENCES [dbo].[ContentCategory] ([ContentCategoryID])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_ContentCategory]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_ResponsibleManager] FOREIGN KEY([ResponsibleManagerID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_ResponsibleManager]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_ResponsibleSnrManager] FOREIGN KEY([ResponsibleSnrManagerID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_ResponsibleSnrManager]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_Status] FOREIGN KEY([CorrectiveActionStatusID])
REFERENCES [dbo].[CorrectiveActionStatus] ([CorrectiveActionStatusID])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_Status]
GO
ALTER TABLE [dbo].[CorrectiveAction]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveAction_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[CorrectiveAction] CHECK CONSTRAINT [FK_CorrectiveAction_Workbase]
GO
ALTER TABLE [dbo].[CorrectiveActionHistory]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionHistory_CorrectiveAction] FOREIGN KEY([CorrectiveActionID])
REFERENCES [dbo].[CorrectiveAction] ([CorrectiveActonID])
GO
ALTER TABLE [dbo].[CorrectiveActionHistory] CHECK CONSTRAINT [FK_CorrectiveActionHistory_CorrectiveAction]
GO
ALTER TABLE [dbo].[CorrectiveActionHistory]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionHistory_Event] FOREIGN KEY([CorrectiveActionEventID])
REFERENCES [dbo].[CorrectiveActionEvent] ([CorrectiveActionEventID])
GO
ALTER TABLE [dbo].[CorrectiveActionHistory] CHECK CONSTRAINT [FK_CorrectiveActionHistory_Event]
GO
ALTER TABLE [dbo].[CorrectiveActionHistory]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionHistory_Occupation] FOREIGN KEY([UserOccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[CorrectiveActionHistory] CHECK CONSTRAINT [FK_CorrectiveActionHistory_Occupation]
GO
ALTER TABLE [dbo].[CorrectiveActionHistory]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionHistory_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[CorrectiveActionHistory] CHECK CONSTRAINT [FK_CorrectiveActionHistory_User]
GO
ALTER TABLE [dbo].[CorrectiveActionHistory]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionHistory_Workbase] FOREIGN KEY([UserWorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[CorrectiveActionHistory] CHECK CONSTRAINT [FK_CorrectiveActionHistory_Workbase]
GO
ALTER TABLE [dbo].[CorrectiveActionOtherEmailUser]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionOtherEmailUser_CorrectiveAction] FOREIGN KEY([CorrectiveActionID])
REFERENCES [dbo].[CorrectiveAction] ([CorrectiveActonID])
GO
ALTER TABLE [dbo].[CorrectiveActionOtherEmailUser] CHECK CONSTRAINT [FK_CorrectiveActionOtherEmailUser_CorrectiveAction]
GO
ALTER TABLE [dbo].[CorrectiveActionOtherEmailUser]  WITH CHECK ADD  CONSTRAINT [FK_CorrectiveActionOtherEmailUser_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[CorrectiveActionOtherEmailUser] CHECK CONSTRAINT [FK_CorrectiveActionOtherEmailUser_User]
GO
ALTER TABLE [dbo].[Department]  WITH CHECK ADD  CONSTRAINT [FK_Department_DepartmentF2508Contact] FOREIGN KEY([F2508Contact])
REFERENCES [dbo].[DepartmentF2508Contact] ([F2508Contact])
GO
ALTER TABLE [dbo].[Department] CHECK CONSTRAINT [FK_Department_DepartmentF2508Contact]
GO
ALTER TABLE [dbo].[DepartmentAccidentType]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentAccidentType_AccidentType] FOREIGN KEY([AccidentTypeID])
REFERENCES [dbo].[AccidentType] ([AccidentTypeID])
GO
ALTER TABLE [dbo].[DepartmentAccidentType] CHECK CONSTRAINT [FK_DepartmentAccidentType_AccidentType]
GO
ALTER TABLE [dbo].[DepartmentAccidentType]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentAccidentType_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[DepartmentAccidentType] CHECK CONSTRAINT [FK_DepartmentAccidentType_Department]
GO
ALTER TABLE [dbo].[DepartmentIncidentType]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentIncidentType_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[DepartmentIncidentType] CHECK CONSTRAINT [FK_DepartmentIncidentType_Department]
GO
ALTER TABLE [dbo].[DepartmentIncidentType]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentIncidentType_IncidentType] FOREIGN KEY([IncidentTypeID])
REFERENCES [dbo].[IncidentType] ([IncidentTypeID])
GO
ALTER TABLE [dbo].[DepartmentIncidentType] CHECK CONSTRAINT [FK_DepartmentIncidentType_IncidentType]
GO
ALTER TABLE [dbo].[DivisionSection]  WITH CHECK ADD  CONSTRAINT [FK_DivisionSection_Division] FOREIGN KEY([DivisionID])
REFERENCES [dbo].[Division] ([DivisionID])
GO
ALTER TABLE [dbo].[DivisionSection] CHECK CONSTRAINT [FK_DivisionSection_Division]
GO
ALTER TABLE [dbo].[DivisionSection]  WITH CHECK ADD  CONSTRAINT [FK_DivisionSection_Section] FOREIGN KEY([SectionID])
REFERENCES [dbo].[Section] ([SectionID])
GO
ALTER TABLE [dbo].[DivisionSection] CHECK CONSTRAINT [FK_DivisionSection_Section]
GO
ALTER TABLE [dbo].[FunctionContent]  WITH CHECK ADD  CONSTRAINT [FK_FunctionContent_Content] FOREIGN KEY([ContentID])
REFERENCES [dbo].[Content] ([ContentID])
GO
ALTER TABLE [dbo].[FunctionContent] CHECK CONSTRAINT [FK_FunctionContent_Content]
GO
ALTER TABLE [dbo].[FunctionContent]  WITH CHECK ADD  CONSTRAINT [FK_FunctionContent_WFunction] FOREIGN KEY([FunctionID])
REFERENCES [dbo].[WFunction] ([FunctionID])
GO
ALTER TABLE [dbo].[FunctionContent] CHECK CONSTRAINT [FK_FunctionContent_WFunction]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_AccidentReason] FOREIGN KEY([AccidentReasonID])
REFERENCES [dbo].[AccidentReason] ([AccidentReasonID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_AccidentReason]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_AccidentType] FOREIGN KEY([AccidentTypeID])
REFERENCES [dbo].[AccidentType] ([AccidentTypeID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_AccidentType]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_BodyPart] FOREIGN KEY([BodyPartID])
REFERENCES [dbo].[BodyPart] ([BodyPartID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_BodyPart]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Department]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_F2508Injury] FOREIGN KEY([F2508DInjuryID])
REFERENCES [dbo].[F2508Injury] ([F2508InjuryID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_F2508Injury]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_F2508Person] FOREIGN KEY([F2508DPersonID])
REFERENCES [dbo].[F2508Person] ([F2508PersonID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_F2508Person]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_F2508Where] FOREIGN KEY([F2508BWhereID])
REFERENCES [dbo].[F2508Where] ([F2508WhereID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_F2508Where]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_IncidentLocation] FOREIGN KEY([IncidentLocationID])
REFERENCES [dbo].[IncidentLocation] ([IncidentLocationID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentLocation]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_IncidentStatus] FOREIGN KEY([CurrentStatus])
REFERENCES [dbo].[IncidentStatus] ([IncidentStatusID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentStatus]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_IncidentType] FOREIGN KEY([IncidentTypeID])
REFERENCES [dbo].[IncidentType] ([IncidentTypeID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentType]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_injuredoccupation_Occupation] FOREIGN KEY([InjuredOccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_injuredoccupation_Occupation]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_InjuredStatus] FOREIGN KEY([InjuredStatusID])
REFERENCES [dbo].[InjuredStatus] ([InjuredStatusID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_InjuredStatus]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Injury] FOREIGN KEY([InjuryID])
REFERENCES [dbo].[Injury] ([InjuryID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Injury]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Occupation] FOREIGN KEY([ReportedToOccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Occupation]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_responsible_Occupation] FOREIGN KEY([ResponsibleOccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_responsible_Occupation]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Section] FOREIGN KEY([SectionID])
REFERENCES [dbo].[Section] ([SectionID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Section]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_TradeUnion] FOREIGN KEY([InjuredTradeUnionID])
REFERENCES [dbo].[TradeUnion] ([TradeUnionID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_TradeUnion]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_User] FOREIGN KEY([ResponsibleUserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_User]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Workbase] FOREIGN KEY([InjuredWorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Workbase]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_Workbase2] FOREIGN KEY([ResponsibleWorkBaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Workbase2]
GO
ALTER TABLE [dbo].[IncidentApprovalHistory]  WITH CHECK ADD  CONSTRAINT [FK_IncidentApprovalHistory_ActionTaken] FOREIGN KEY([ActionTaken])
REFERENCES [dbo].[IncidentApprovalHistoryActionTaken] ([ActionTaken])
GO
ALTER TABLE [dbo].[IncidentApprovalHistory] CHECK CONSTRAINT [FK_IncidentApprovalHistory_ActionTaken]
GO
ALTER TABLE [dbo].[IncidentApprovalHistory]  WITH CHECK ADD  CONSTRAINT [FK_IncidentApprovalHistory_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentApprovalHistory] CHECK CONSTRAINT [FK_IncidentApprovalHistory_Incident]
GO
ALTER TABLE [dbo].[IncidentApprovalHistory]  WITH CHECK ADD  CONSTRAINT [FK_IncidentApprovalHistory_Occupation] FOREIGN KEY([UserOccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[IncidentApprovalHistory] CHECK CONSTRAINT [FK_IncidentApprovalHistory_Occupation]
GO
ALTER TABLE [dbo].[IncidentApprovalHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_IncidentApprovalHistory_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[IncidentApprovalHistory] CHECK CONSTRAINT [FK_IncidentApprovalHistory_User]
GO
ALTER TABLE [dbo].[IncidentApprovalHistory]  WITH CHECK ADD  CONSTRAINT [FK_IncidentApprovalHistory_Workbase] FOREIGN KEY([UserWorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[IncidentApprovalHistory] CHECK CONSTRAINT [FK_IncidentApprovalHistory_Workbase]
GO
ALTER TABLE [dbo].[IncidentContent]  WITH CHECK ADD  CONSTRAINT [FK_IncidentContent_Content] FOREIGN KEY([ContentID])
REFERENCES [dbo].[Content] ([ContentID])
GO
ALTER TABLE [dbo].[IncidentContent] CHECK CONSTRAINT [FK_IncidentContent_Content]
GO
ALTER TABLE [dbo].[IncidentContent]  WITH CHECK ADD  CONSTRAINT [FK_IncidentContent_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentContent] CHECK CONSTRAINT [FK_IncidentContent_Incident]
GO
ALTER TABLE [dbo].[IncidentDiary]  WITH CHECK ADD  CONSTRAINT [FK_IncidentDiary_Diary] FOREIGN KEY([DiaryID])
REFERENCES [dbo].[Diary] ([DiaryID])
GO
ALTER TABLE [dbo].[IncidentDiary] CHECK CONSTRAINT [FK_IncidentDiary_Diary]
GO
ALTER TABLE [dbo].[IncidentDiary]  WITH CHECK ADD  CONSTRAINT [FK_IncidentDiary_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentDiary] CHECK CONSTRAINT [FK_IncidentDiary_Incident]
GO
ALTER TABLE [dbo].[IncidentOtherBodyPart]  WITH CHECK ADD  CONSTRAINT [FK_IncidentOtherBodyPart_BodyPart] FOREIGN KEY([BodyPartID])
REFERENCES [dbo].[BodyPart] ([BodyPartID])
GO
ALTER TABLE [dbo].[IncidentOtherBodyPart] CHECK CONSTRAINT [FK_IncidentOtherBodyPart_BodyPart]
GO
ALTER TABLE [dbo].[IncidentOtherBodyPart]  WITH CHECK ADD  CONSTRAINT [FK_IncidentOtherBodyPart_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentOtherBodyPart] CHECK CONSTRAINT [FK_IncidentOtherBodyPart_Incident]
GO
ALTER TABLE [dbo].[IncidentOtherEmailUser]  WITH CHECK ADD  CONSTRAINT [FK_IncidentOtherEmailUser_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentOtherEmailUser] CHECK CONSTRAINT [FK_IncidentOtherEmailUser_Incident]
GO
ALTER TABLE [dbo].[IncidentOtherEmailUser]  WITH CHECK ADD  CONSTRAINT [FK_IncidentOtherEmailUser_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[IncidentOtherEmailUser] CHECK CONSTRAINT [FK_IncidentOtherEmailUser_User]
GO
ALTER TABLE [dbo].[IncidentWitness]  WITH CHECK ADD  CONSTRAINT [FK_IncidentWitness_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([IncidentID])
GO
ALTER TABLE [dbo].[IncidentWitness] CHECK CONSTRAINT [FK_IncidentWitness_Incident]
GO
ALTER TABLE [dbo].[InjuredStatus]  WITH CHECK ADD  CONSTRAINT [FK_InjuredStatus_InjuredStatusType] FOREIGN KEY([Type])
REFERENCES [dbo].[InjuredStatusType] ([Type])
GO
ALTER TABLE [dbo].[InjuredStatus] CHECK CONSTRAINT [FK_InjuredStatus_InjuredStatusType]
GO
ALTER TABLE [dbo].[Occupation]  WITH CHECK ADD  CONSTRAINT [FK_Occupation_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[Occupation] CHECK CONSTRAINT [FK_Occupation_Department]
GO
ALTER TABLE [dbo].[RiskAssessment]  WITH CHECK ADD  CONSTRAINT [FK_RiskAssessment_Section] FOREIGN KEY([SectionID])
REFERENCES [dbo].[Section] ([SectionID])
GO
ALTER TABLE [dbo].[RiskAssessment] CHECK CONSTRAINT [FK_RiskAssessment_Section]
GO
ALTER TABLE [dbo].[Section]  WITH CHECK ADD  CONSTRAINT [FK_Section_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[Section] CHECK CONSTRAINT [FK_Section_Department]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Department] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Department]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Department_DefaultUser] FOREIGN KEY([DefaultDepartmentID])
REFERENCES [dbo].[Department] ([DepartmentID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Department_DefaultUser]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Occupation] FOREIGN KEY([OccupationID])
REFERENCES [dbo].[Occupation] ([OccupationID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Occupation]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Section] FOREIGN KEY([SectionID])
REFERENCES [dbo].[Section] ([SectionID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Section]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_Workbase]
GO
ALTER TABLE [dbo].[UserAccess]  WITH CHECK ADD  CONSTRAINT [FK_UserAccess_User] FOREIGN KEY([UserID])
REFERENCES [dbo].[User] ([UserId])
GO
ALTER TABLE [dbo].[UserAccess] CHECK CONSTRAINT [FK_UserAccess_User]
GO
ALTER TABLE [dbo].[Workbase]  WITH CHECK ADD  CONSTRAINT [FK_Workbase_Property] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([PropertyID])
GO
ALTER TABLE [dbo].[Workbase] CHECK CONSTRAINT [FK_Workbase_Property]
GO
ALTER TABLE [dbo].[Workbase]  WITH CHECK ADD  CONSTRAINT [FK_Workbase_Section] FOREIGN KEY([SectionID])
REFERENCES [dbo].[Section] ([SectionID])
GO
ALTER TABLE [dbo].[Workbase] CHECK CONSTRAINT [FK_Workbase_Section]
GO
ALTER TABLE [dbo].[WorkbaseContent]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseContent_Content] FOREIGN KEY([ContentID])
REFERENCES [dbo].[Content] ([ContentID])
GO
ALTER TABLE [dbo].[WorkbaseContent] CHECK CONSTRAINT [FK_WorkbaseContent_Content]
GO
ALTER TABLE [dbo].[WorkbaseContent]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseContent_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[WorkbaseContent] CHECK CONSTRAINT [FK_WorkbaseContent_Workbase]
GO
ALTER TABLE [dbo].[WorkbaseDiary]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseDiary_Diary] FOREIGN KEY([DiaryID])
REFERENCES [dbo].[Diary] ([DiaryID])
GO
ALTER TABLE [dbo].[WorkbaseDiary] CHECK CONSTRAINT [FK_WorkbaseDiary_Diary]
GO
ALTER TABLE [dbo].[WorkbaseDiary]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseDiary_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[WorkbaseDiary] CHECK CONSTRAINT [FK_WorkbaseDiary_Workbase]
GO
ALTER TABLE [dbo].[WorkbaseFunction]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseFunction_WFunction] FOREIGN KEY([FunctionID])
REFERENCES [dbo].[WFunction] ([FunctionID])
GO
ALTER TABLE [dbo].[WorkbaseFunction] CHECK CONSTRAINT [FK_WorkbaseFunction_WFunction]
GO
ALTER TABLE [dbo].[WorkbaseFunction]  WITH CHECK ADD  CONSTRAINT [FK_WorkbaseFunction_Workbase] FOREIGN KEY([WorkbaseID])
REFERENCES [dbo].[Workbase] ([WorkBaseID])
GO
ALTER TABLE [dbo].[WorkbaseFunction] CHECK CONSTRAINT [FK_WorkbaseFunction_Workbase]
GO
/****** Object:  StoredProcedure [dbo].[sp_BlobAttachment]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_BlobAttachment]
	
	@ContentStoreID INT
 AS
SELECT ContentStoreID, Attachment
FROM ContentStore
	WHERE ContentStoreID = @ContentStoreID
GO
/****** Object:  StoredProcedure [dbo].[sp_FormatAddress]    Script Date: 09/12/2025 16:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_FormatAddress]
	
	@PropertyID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @ReturnString as VARCHAR
	SET @ReturnString = (SELECT BuildingName + '<br />'  + IsNull(Convert(Varchar(10), HouseNumber), '') + ' ' + HouseSuffix + ' ' + StreetName
		FROM Property
		WHERE Property.PropertyID = @PropertyID)
    -- Insert statements for procedure here
	RETURN @ReturnString
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AdvisoryOfficerView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AdvisoryOfficerView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[30] 2[8] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Section"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 391
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 429
               Bottom = 121
               Right = 581
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Workbase"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Property"
            Begin Extent = 
               Top = 6
               Left = 619
               Bottom = 121
               Right = 787
            End
            DisplayFlags = 280
            TopColumn = 13
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 645
         Width = 1620
         Width = 345
         Width = 2625
         Width = 1485
         Width = 1755
         Width = 1020
         Width = 690
         Width = 3615
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1605
         Table = 1980
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 2010
         Or = 1350
         Or = 1350
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CommunityFacilitiesSchool'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CommunityFacilitiesSchool'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CommunityFacilitiesSchool'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CorrectiveAction"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Workbase"
            Begin Extent = 
               Top = 6
               Left = 303
               Bottom = 135
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 138
               Left = 256
               Bottom = 267
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 256
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User_1"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 531
               Right = 256
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User_2"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 663
               Right = 256
            End
            DisplayFlags ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CorrectiveActionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 280
            TopColumn = 0
         End
         Begin Table = "Property"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 795
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CorrectiveActionStatus"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 910
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ContentCategory"
            Begin Extent = 
               Top = 666
               Left = 265
               Bottom = 795
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User_3"
            Begin Extent = 
               Top = 6
               Left = 511
               Bottom = 135
               Right = 729
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CorrectiveActionOtherEmailUser"
            Begin Extent = 
               Top = 6
               Left = 767
               Bottom = 135
               Right = 956
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CorrectiveActionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CorrectiveActionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Division"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DivisionSection"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 110
               Right = 423
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 6
               Left = 461
               Bottom = 125
               Right = 632
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 670
               Bottom = 125
               Right = 830
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
    ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DepartmentDivisionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'  End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DepartmentDivisionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DepartmentDivisionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[20] 4[32] 2[30] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[19] 4[32] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 1
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Division"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "DivisionSection"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 110
               Right = 407
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 6
               Left = 445
               Bottom = 125
               Right = 616
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 654
               Bottom = 125
               Right = 814
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
      PaneHidden = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 135' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DivisionSectionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DivisionSectionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DivisionSectionView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Incident"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentType"
            Begin Extent = 
               Top = 6
               Left = 287
               Bottom = 125
               Right = 450
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentStatus"
            Begin Extent = 
               Top = 126
               Left = 247
               Bottom = 245
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 246
               Left = 282
               Bottom = 365
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3960
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IncidentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IncidentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IncidentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Mapping"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 205
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DivisionSection"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 187
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mDivisionSection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mDivisionSection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Mapping"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Incident"
            Begin Extent = 
               Top = 6
               Left = 265
               Bottom = 125
               Right = 476
            End
            DisplayFlags = 280
            TopColumn = 60
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Mapping"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 176
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RiskAssessment"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 244
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mRiskAssessment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mRiskAssessment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UserAccess"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 125
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 491
               Bottom = 125
               Right = 651
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MultipleServiceView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MultipleServiceView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[19] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -1569
      End
      Begin Tables = 
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UserAccess"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 125
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ResponsibleUserView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ResponsibleUserView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Division"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "DivisionSection"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 110
               Right = 423
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RiskAssessment"
            Begin Extent = 
               Top = 6
               Left = 461
               Bottom = 125
               Right = 637
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 6
               Left = 675
               Bottom = 125
               Right = 846
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 114
               Left = 252
               Bottom = 233
               Right = 412
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "User"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RiskAssessmentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RiskAssessmentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'RiskAssessmentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[10] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "User"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 20
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 2730
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VIEW1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VIEW1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Incident"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 61
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 114
               Right = 429
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentType"
            Begin Extent = 
               Top = 114
               Left = 238
               Bottom = 222
               Right = 392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "InjuredStatus"
            Begin Extent = 
               Top = 222
               Left = 38
               Bottom = 330
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TradeUnion"
            Begin Extent = 
               Top = 222
               Left = 233
               Bottom = 330
               Right = 384
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BodyPart"
            Begin Extent = 
               Top = 330
               Left = 38
               Bottom = 438
               Right = 189
            End
            ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AccidentReason"
            Begin Extent = 
               Top = 330
               Left = 227
               Bottom = 438
               Right = 395
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentStatus"
            Begin Extent = 
               Top = 438
               Left = 38
               Bottom = 546
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentLocation"
            Begin Extent = 
               Top = 438
               Left = 237
               Bottom = 546
               Right = 407
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Injury"
            Begin Extent = 
               Top = 546
               Left = 38
               Bottom = 654
               Right = 189
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F2508Injury"
            Begin Extent = 
               Top = 546
               Left = 227
               Bottom = 654
               Right = 378
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F2508Person"
            Begin Extent = 
               Top = 654
               Left = 38
               Bottom = 762
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F2508Where"
            Begin Extent = 
               Top = 654
               Left = 230
               Bottom = 762
               Right = 383
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AccidentType"
            Begin Extent = 
               Top = 762
               Left = 38
               Bottom = 870
               Right = 194
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IncidentStatus_1"
            Begin Extent = 
               Top = 762
               Left = 232
               Bottom = 870
               Right = 393
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2415
         Alias = 2460
         Table = 2625
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[35] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "RiskAssessment"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Section"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 125
               Right = 423
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 461
               Bottom = 125
               Right = 621
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vRiskAssessment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vRiskAssessment'
GO
