using Microsoft.Data.SqlClient;
using ExpenseManagement.Models;
using Azure.Identity;
using Azure.Core;

namespace ExpenseManagement.Services;

public class DatabaseService
{
    private readonly string _connectionString;
    private readonly ILogger<DatabaseService> _logger;
    private readonly IConfiguration _configuration;

    public DatabaseService(IConfiguration configuration, ILogger<DatabaseService> logger)
    {
        _configuration = configuration;
        _logger = logger;
        
        var server = configuration["Database:Server"] ?? "example.database.windows.net";
        var database = configuration["Database:Database"] ?? "Northwind";
        var clientId = configuration["ManagedIdentityClientId"];
        
        if (!string.IsNullOrEmpty(clientId))
        {
            _connectionString = $"Server=tcp:{server};Database={database};Authentication=Active Directory Managed Identity;User Id={clientId};";
        }
        else
        {
            // For local development
            _connectionString = $"Server=tcp:{server};Database={database};Authentication=Active Directory Default;";
        }
    }

    private async Task<SqlConnection> GetConnectionAsync()
    {
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        return connection;
    }

    public async Task<List<Expense>> GetExpensesAsync(int? userId = null, int? statusId = null, int? categoryId = null)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpenses", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@UserId", (object?)userId ?? DBNull.Value);
            command.Parameters.AddWithValue("@StatusId", (object?)statusId ?? DBNull.Value);
            command.Parameters.AddWithValue("@CategoryId", (object?)categoryId ?? DBNull.Value);
            
            var expenses = new List<Expense>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                expenses.Add(new Expense
                {
                    ExpenseId = reader.GetInt32(reader.GetOrdinal("ExpenseId")),
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    UserName = reader.GetString(reader.GetOrdinal("UserName")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    CategoryId = reader.GetInt32(reader.GetOrdinal("CategoryId")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    StatusId = reader.GetInt32(reader.GetOrdinal("StatusId")),
                    StatusName = reader.GetString(reader.GetOrdinal("StatusName")),
                    AmountMinor = reader.GetInt32(reader.GetOrdinal("AmountMinor")),
                    Currency = reader.GetString(reader.GetOrdinal("Currency")),
                    ExpenseDate = reader.GetDateTime(reader.GetOrdinal("ExpenseDate")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    ReceiptFile = reader.IsDBNull(reader.GetOrdinal("ReceiptFile")) ? null : reader.GetString(reader.GetOrdinal("ReceiptFile")),
                    SubmittedAt = reader.IsDBNull(reader.GetOrdinal("SubmittedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmittedAt")),
                    ReviewedBy = reader.IsDBNull(reader.GetOrdinal("ReviewedBy")) ? null : reader.GetInt32(reader.GetOrdinal("ReviewedBy")),
                    ReviewerName = reader.IsDBNull(reader.GetOrdinal("ReviewerName")) ? null : reader.GetString(reader.GetOrdinal("ReviewerName")),
                    ReviewedAt = reader.IsDBNull(reader.GetOrdinal("ReviewedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("ReviewedAt")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            
            return expenses;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expenses");
            throw;
        }
    }

    public async Task<Expense?> GetExpenseByIdAsync(int expenseId)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpenseById", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new Expense
                {
                    ExpenseId = reader.GetInt32(reader.GetOrdinal("ExpenseId")),
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    UserName = reader.GetString(reader.GetOrdinal("UserName")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    CategoryId = reader.GetInt32(reader.GetOrdinal("CategoryId")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    StatusId = reader.GetInt32(reader.GetOrdinal("StatusId")),
                    StatusName = reader.GetString(reader.GetOrdinal("StatusName")),
                    AmountMinor = reader.GetInt32(reader.GetOrdinal("AmountMinor")),
                    Currency = reader.GetString(reader.GetOrdinal("Currency")),
                    ExpenseDate = reader.GetDateTime(reader.GetOrdinal("ExpenseDate")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    ReceiptFile = reader.IsDBNull(reader.GetOrdinal("ReceiptFile")) ? null : reader.GetString(reader.GetOrdinal("ReceiptFile")),
                    SubmittedAt = reader.IsDBNull(reader.GetOrdinal("SubmittedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmittedAt")),
                    ReviewedBy = reader.IsDBNull(reader.GetOrdinal("ReviewedBy")) ? null : reader.GetInt32(reader.GetOrdinal("ReviewedBy")),
                    ReviewerName = reader.IsDBNull(reader.GetOrdinal("ReviewerName")) ? null : reader.GetString(reader.GetOrdinal("ReviewerName")),
                    ReviewedAt = reader.IsDBNull(reader.GetOrdinal("ReviewedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("ReviewedAt")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                };
            }
            
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense by ID");
            throw;
        }
    }

    public async Task<int> CreateExpenseAsync(CreateExpenseRequest request)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.CreateExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@UserId", request.UserId);
            command.Parameters.AddWithValue("@CategoryId", request.CategoryId);
            command.Parameters.AddWithValue("@AmountMinor", request.AmountMinor);
            command.Parameters.AddWithValue("@Currency", request.Currency);
            command.Parameters.AddWithValue("@ExpenseDate", request.ExpenseDate);
            command.Parameters.AddWithValue("@Description", (object?)request.Description ?? DBNull.Value);
            command.Parameters.AddWithValue("@ReceiptFile", (object?)request.ReceiptFile ?? DBNull.Value);
            
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating expense");
            throw;
        }
    }

    public async Task<int> UpdateExpenseAsync(UpdateExpenseRequest request)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.UpdateExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", request.ExpenseId);
            command.Parameters.AddWithValue("@CategoryId", request.CategoryId);
            command.Parameters.AddWithValue("@AmountMinor", request.AmountMinor);
            command.Parameters.AddWithValue("@Currency", request.Currency);
            command.Parameters.AddWithValue("@ExpenseDate", request.ExpenseDate);
            command.Parameters.AddWithValue("@Description", (object?)request.Description ?? DBNull.Value);
            command.Parameters.AddWithValue("@ReceiptFile", (object?)request.ReceiptFile ?? DBNull.Value);
            
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return reader.GetInt32(0);
            }
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating expense");
            throw;
        }
    }

    public async Task<int> SubmitExpenseAsync(int expenseId)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.SubmitExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return reader.GetInt32(0);
            }
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error submitting expense");
            throw;
        }
    }

    public async Task<int> ApproveExpenseAsync(int expenseId, int reviewedBy)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.ApproveExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            command.Parameters.AddWithValue("@ReviewedBy", reviewedBy);
            
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return reader.GetInt32(0);
            }
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error approving expense");
            throw;
        }
    }

    public async Task<int> RejectExpenseAsync(int expenseId, int reviewedBy)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.RejectExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            command.Parameters.AddWithValue("@ReviewedBy", reviewedBy);
            
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return reader.GetInt32(0);
            }
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error rejecting expense");
            throw;
        }
    }

    public async Task<int> DeleteExpenseAsync(int expenseId)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.DeleteExpense", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ExpenseId", expenseId);
            
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return reader.GetInt32(0);
            }
            return 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting expense");
            throw;
        }
    }

    public async Task<List<User>> GetUsersAsync()
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetUsers", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            var users = new List<User>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                users.Add(new User
                {
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    UserName = reader.GetString(reader.GetOrdinal("UserName")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    RoleId = reader.GetInt32(reader.GetOrdinal("RoleId")),
                    RoleName = reader.GetString(reader.GetOrdinal("RoleName")),
                    ManagerId = reader.IsDBNull(reader.GetOrdinal("ManagerId")) ? null : reader.GetInt32(reader.GetOrdinal("ManagerId")),
                    ManagerName = reader.IsDBNull(reader.GetOrdinal("ManagerName")) ? null : reader.GetString(reader.GetOrdinal("ManagerName")),
                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            
            return users;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting users");
            throw;
        }
    }

    public async Task<List<ExpenseCategory>> GetExpenseCategoriesAsync()
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpenseCategories", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            var categories = new List<ExpenseCategory>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                categories.Add(new ExpenseCategory
                {
                    CategoryId = reader.GetInt32(reader.GetOrdinal("CategoryId")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive"))
                });
            }
            
            return categories;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense categories");
            throw;
        }
    }

    public async Task<List<ExpenseStatus>> GetExpenseStatusesAsync()
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpenseStatuses", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            var statuses = new List<ExpenseStatus>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                statuses.Add(new ExpenseStatus
                {
                    StatusId = reader.GetInt32(reader.GetOrdinal("StatusId")),
                    StatusName = reader.GetString(reader.GetOrdinal("StatusName"))
                });
            }
            
            return statuses;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense statuses");
            throw;
        }
    }

    public async Task<List<Expense>> GetExpensesForReviewAsync(int managerId)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpensesForReview", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@ManagerId", managerId);
            
            var expenses = new List<Expense>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                expenses.Add(new Expense
                {
                    ExpenseId = reader.GetInt32(reader.GetOrdinal("ExpenseId")),
                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                    UserName = reader.GetString(reader.GetOrdinal("UserName")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    CategoryId = reader.GetInt32(reader.GetOrdinal("CategoryId")),
                    CategoryName = reader.GetString(reader.GetOrdinal("CategoryName")),
                    StatusId = reader.GetInt32(reader.GetOrdinal("StatusId")),
                    StatusName = reader.GetString(reader.GetOrdinal("StatusName")),
                    AmountMinor = reader.GetInt32(reader.GetOrdinal("AmountMinor")),
                    Currency = reader.GetString(reader.GetOrdinal("Currency")),
                    ExpenseDate = reader.GetDateTime(reader.GetOrdinal("ExpenseDate")),
                    Description = reader.IsDBNull(reader.GetOrdinal("Description")) ? null : reader.GetString(reader.GetOrdinal("Description")),
                    ReceiptFile = reader.IsDBNull(reader.GetOrdinal("ReceiptFile")) ? null : reader.GetString(reader.GetOrdinal("ReceiptFile")),
                    SubmittedAt = reader.IsDBNull(reader.GetOrdinal("SubmittedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("SubmittedAt")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                });
            }
            
            return expenses;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expenses for review");
            throw;
        }
    }

    public async Task<List<ExpenseSummary>> GetExpenseSummaryAsync(int? userId = null)
    {
        try
        {
            using var connection = await GetConnectionAsync();
            using var command = new SqlCommand("dbo.GetExpenseSummary", connection)
            {
                CommandType = System.Data.CommandType.StoredProcedure
            };
            
            command.Parameters.AddWithValue("@UserId", (object?)userId ?? DBNull.Value);
            
            var summaries = new List<ExpenseSummary>();
            using var reader = await command.ExecuteReaderAsync();
            
            while (await reader.ReadAsync())
            {
                summaries.Add(new ExpenseSummary
                {
                    StatusName = reader.GetString(reader.GetOrdinal("StatusName")),
                    ExpenseCount = reader.GetInt32(reader.GetOrdinal("ExpenseCount")),
                    TotalAmountMinor = reader.GetInt32(reader.GetOrdinal("TotalAmountMinor"))
                });
            }
            
            return summaries;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense summary");
            throw;
        }
    }
}
