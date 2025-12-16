using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using ExpenseManagement.Models;
using ExpenseManagement.Services;

namespace ExpenseManagement.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    private readonly DatabaseService _databaseService;

    public string? ErrorMessage { get; set; }
    public string? ErrorDetails { get; set; }
    public List<Expense> Expenses { get; set; } = new();
    public List<ExpenseCategory> Categories { get; set; } = new();
    public List<ExpenseStatus> Statuses { get; set; } = new();
    public List<User> Users { get; set; } = new();
    public List<ExpenseSummary> Summary { get; set; } = new();
    
    [BindProperty(SupportsGet = true)]
    public int? FilterUserId { get; set; }
    
    [BindProperty(SupportsGet = true)]
    public int? FilterStatusId { get; set; }
    
    [BindProperty(SupportsGet = true)]
    public int? FilterCategoryId { get; set; }

    public IndexModel(ILogger<IndexModel> logger, DatabaseService databaseService)
    {
        _logger = logger;
        _databaseService = databaseService;
    }

    public async Task OnGetAsync()
    {
        try
        {
            // Load all reference data
            Categories = await _databaseService.GetExpenseCategoriesAsync();
            Statuses = await _databaseService.GetExpenseStatusesAsync();
            Users = await _databaseService.GetUsersAsync();
            
            // Load expenses with filters
            Expenses = await _databaseService.GetExpensesAsync(FilterUserId, FilterStatusId, FilterCategoryId);
            
            // Load summary
            Summary = await _databaseService.GetExpenseSummaryAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error loading expense data");
            ErrorMessage = "Database Connection Error";
            ErrorDetails = $"Unable to connect to the database. This may be a managed identity configuration issue. " +
                          $"Please ensure the managed identity is correctly configured with database access permissions. " +
                          $"Error in: Pages/Index.cshtml.cs, line 48. " +
                          $"Details: {ex.Message}";
            
            // Load dummy data for display
            LoadDummyData();
        }
    }

    private void LoadDummyData()
    {
        Categories = new List<ExpenseCategory>
        {
            new() { CategoryId = 1, CategoryName = "Travel", IsActive = true },
            new() { CategoryId = 2, CategoryName = "Meals", IsActive = true },
            new() { CategoryId = 3, CategoryName = "Supplies", IsActive = true }
        };
        
        Statuses = new List<ExpenseStatus>
        {
            new() { StatusId = 1, StatusName = "Draft" },
            new() { StatusId = 2, StatusName = "Submitted" },
            new() { StatusId = 3, StatusName = "Approved" }
        };
        
        Users = new List<User>
        {
            new() { UserId = 1, UserName = "Alice Example", Email = "alice@example.co.uk", RoleName = "Employee" },
            new() { UserId = 2, UserName = "Bob Manager", Email = "bob@example.co.uk", RoleName = "Manager" }
        };
        
        Expenses = new List<Expense>
        {
            new() 
            { 
                ExpenseId = 1, 
                UserName = "Alice Example", 
                CategoryName = "Travel", 
                StatusName = "Submitted",
                AmountMinor = 2540,
                Currency = "GBP",
                ExpenseDate = DateTime.Now.AddDays(-5),
                Description = "Taxi from airport to client site",
                CreatedAt = DateTime.Now.AddDays(-5)
            },
            new() 
            { 
                ExpenseId = 2, 
                UserName = "Alice Example", 
                CategoryName = "Meals", 
                StatusName = "Approved",
                AmountMinor = 1425,
                Currency = "GBP",
                ExpenseDate = DateTime.Now.AddDays(-10),
                Description = "Client lunch meeting",
                CreatedAt = DateTime.Now.AddDays(-10)
            }
        };
        
        Summary = new List<ExpenseSummary>
        {
            new() { StatusName = "Draft", ExpenseCount = 1, TotalAmountMinor = 799 },
            new() { StatusName = "Submitted", ExpenseCount = 1, TotalAmountMinor = 2540 },
            new() { StatusName = "Approved", ExpenseCount = 1, TotalAmountMinor = 1425 }
        };
    }
}
