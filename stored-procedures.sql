-- Stored Procedures for Expense Management System

-- Get all expenses (with optional filters)
CREATE OR ALTER PROCEDURE dbo.GetExpenses
    @UserId INT = NULL,
    @StatusId INT = NULL,
    @CategoryId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseId,
        e.UserId,
        u.UserName,
        u.Email,
        e.CategoryId,
        c.CategoryName,
        e.StatusId,
        s.StatusName,
        e.AmountMinor,
        e.Currency,
        e.ExpenseDate,
        e.Description,
        e.ReceiptFile,
        e.SubmittedAt,
        e.ReviewedBy,
        reviewer.UserName AS ReviewerName,
        e.ReviewedAt,
        e.CreatedAt
    FROM dbo.Expenses e
    INNER JOIN dbo.Users u ON e.UserId = u.UserId
    INNER JOIN dbo.ExpenseCategories c ON e.CategoryId = c.CategoryId
    INNER JOIN dbo.ExpenseStatus s ON e.StatusId = s.StatusId
    LEFT JOIN dbo.Users reviewer ON e.ReviewedBy = reviewer.UserId
    WHERE (@UserId IS NULL OR e.UserId = @UserId)
      AND (@StatusId IS NULL OR e.StatusId = @StatusId)
      AND (@CategoryId IS NULL OR e.CategoryId = @CategoryId)
    ORDER BY e.CreatedAt DESC;
END
GO

-- Get single expense by ID
CREATE OR ALTER PROCEDURE dbo.GetExpenseById
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        e.ExpenseId,
        e.UserId,
        u.UserName,
        u.Email,
        e.CategoryId,
        c.CategoryName,
        e.StatusId,
        s.StatusName,
        e.AmountMinor,
        e.Currency,
        e.ExpenseDate,
        e.Description,
        e.ReceiptFile,
        e.SubmittedAt,
        e.ReviewedBy,
        reviewer.UserName AS ReviewerName,
        e.ReviewedAt,
        e.CreatedAt
    FROM dbo.Expenses e
    INNER JOIN dbo.Users u ON e.UserId = u.UserId
    INNER JOIN dbo.ExpenseCategories c ON e.CategoryId = c.CategoryId
    INNER JOIN dbo.ExpenseStatus s ON e.StatusId = s.StatusId
    LEFT JOIN dbo.Users reviewer ON e.ReviewedBy = reviewer.UserId
    WHERE e.ExpenseId = @ExpenseId;
END
GO

-- Create new expense
CREATE OR ALTER PROCEDURE dbo.CreateExpense
    @UserId INT,
    @CategoryId INT,
    @AmountMinor INT,
    @Currency NVARCHAR(3),
    @ExpenseDate DATE,
    @Description NVARCHAR(1000),
    @ReceiptFile NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StatusId INT;
    SELECT @StatusId = StatusId FROM dbo.ExpenseStatus WHERE StatusName = 'Draft';
    
    INSERT INTO dbo.Expenses (UserId, CategoryId, StatusId, AmountMinor, Currency, ExpenseDate, Description, ReceiptFile, CreatedAt)
    VALUES (@UserId, @CategoryId, @StatusId, @AmountMinor, @Currency, @ExpenseDate, @Description, @ReceiptFile, SYSUTCDATETIME());
    
    SELECT SCOPE_IDENTITY() AS ExpenseId;
END
GO

-- Update expense
CREATE OR ALTER PROCEDURE dbo.UpdateExpense
    @ExpenseId INT,
    @CategoryId INT,
    @AmountMinor INT,
    @Currency NVARCHAR(3),
    @ExpenseDate DATE,
    @Description NVARCHAR(1000),
    @ReceiptFile NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE dbo.Expenses
    SET CategoryId = @CategoryId,
        AmountMinor = @AmountMinor,
        Currency = @Currency,
        ExpenseDate = @ExpenseDate,
        Description = @Description,
        ReceiptFile = @ReceiptFile
    WHERE ExpenseId = @ExpenseId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Submit expense
CREATE OR ALTER PROCEDURE dbo.SubmitExpense
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StatusId INT;
    SELECT @StatusId = StatusId FROM dbo.ExpenseStatus WHERE StatusName = 'Submitted';
    
    UPDATE dbo.Expenses
    SET StatusId = @StatusId,
        SubmittedAt = SYSUTCDATETIME()
    WHERE ExpenseId = @ExpenseId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Approve expense
CREATE OR ALTER PROCEDURE dbo.ApproveExpense
    @ExpenseId INT,
    @ReviewedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StatusId INT;
    SELECT @StatusId = StatusId FROM dbo.ExpenseStatus WHERE StatusName = 'Approved';
    
    UPDATE dbo.Expenses
    SET StatusId = @StatusId,
        ReviewedBy = @ReviewedBy,
        ReviewedAt = SYSUTCDATETIME()
    WHERE ExpenseId = @ExpenseId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Reject expense
CREATE OR ALTER PROCEDURE dbo.RejectExpense
    @ExpenseId INT,
    @ReviewedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StatusId INT;
    SELECT @StatusId = StatusId FROM dbo.ExpenseStatus WHERE StatusName = 'Rejected';
    
    UPDATE dbo.Expenses
    SET StatusId = @StatusId,
        ReviewedBy = @ReviewedBy,
        ReviewedAt = SYSUTCDATETIME()
    WHERE ExpenseId = @ExpenseId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Delete expense
CREATE OR ALTER PROCEDURE dbo.DeleteExpense
    @ExpenseId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM dbo.Expenses
    WHERE ExpenseId = @ExpenseId;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- Get all users
CREATE OR ALTER PROCEDURE dbo.GetUsers
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.UserId,
        u.UserName,
        u.Email,
        u.RoleId,
        r.RoleName,
        u.ManagerId,
        m.UserName AS ManagerName,
        u.IsActive,
        u.CreatedAt
    FROM dbo.Users u
    INNER JOIN dbo.Roles r ON u.RoleId = r.RoleId
    LEFT JOIN dbo.Users m ON u.ManagerId = m.UserId
    WHERE u.IsActive = 1
    ORDER BY u.UserName;
END
GO

-- Get user by ID
CREATE OR ALTER PROCEDURE dbo.GetUserById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.UserId,
        u.UserName,
        u.Email,
        u.RoleId,
        r.RoleName,
        u.ManagerId,
        m.UserName AS ManagerName,
        u.IsActive,
        u.CreatedAt
    FROM dbo.Users u
    INNER JOIN dbo.Roles r ON u.RoleId = r.RoleId
    LEFT JOIN dbo.Users m ON u.ManagerId = m.UserId
    WHERE u.UserId = @UserId;
END
GO

-- Get all expense categories
CREATE OR ALTER PROCEDURE dbo.GetExpenseCategories
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT CategoryId, CategoryName, IsActive
    FROM dbo.ExpenseCategories
    WHERE IsActive = 1
    ORDER BY CategoryName;
END
GO

-- Get all expense statuses
CREATE OR ALTER PROCEDURE dbo.GetExpenseStatuses
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT StatusId, StatusName
    FROM dbo.ExpenseStatus
    ORDER BY StatusId;
END
GO

-- Get expenses for a manager to review
CREATE OR ALTER PROCEDURE dbo.GetExpensesForReview
    @ManagerId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StatusId INT;
    SELECT @StatusId = StatusId FROM dbo.ExpenseStatus WHERE StatusName = 'Submitted';
    
    SELECT 
        e.ExpenseId,
        e.UserId,
        u.UserName,
        u.Email,
        e.CategoryId,
        c.CategoryName,
        e.StatusId,
        s.StatusName,
        e.AmountMinor,
        e.Currency,
        e.ExpenseDate,
        e.Description,
        e.ReceiptFile,
        e.SubmittedAt,
        e.CreatedAt
    FROM dbo.Expenses e
    INNER JOIN dbo.Users u ON e.UserId = u.UserId
    INNER JOIN dbo.ExpenseCategories c ON e.CategoryId = c.CategoryId
    INNER JOIN dbo.ExpenseStatus s ON e.StatusId = s.StatusId
    WHERE u.ManagerId = @ManagerId
      AND e.StatusId = @StatusId
    ORDER BY e.SubmittedAt ASC;
END
GO

-- Get expense summary statistics
CREATE OR ALTER PROCEDURE dbo.GetExpenseSummary
    @UserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StatusName,
        COUNT(*) AS ExpenseCount,
        SUM(e.AmountMinor) AS TotalAmountMinor
    FROM dbo.Expenses e
    INNER JOIN dbo.ExpenseStatus s ON e.StatusId = s.StatusId
    WHERE (@UserId IS NULL OR e.UserId = @UserId)
    GROUP BY s.StatusName, s.StatusId
    ORDER BY s.StatusId;
END
GO
