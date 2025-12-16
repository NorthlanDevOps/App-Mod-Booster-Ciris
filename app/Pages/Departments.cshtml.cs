using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Models;
using AppModBooster.Services;

namespace AppModBooster.Pages;

public class DepartmentsModel : PageModel
{
    private readonly DatabaseService _dbService;
    private readonly ILogger<DepartmentsModel> _logger;

    public List<Department> Departments { get; set; } = new();
    public ErrorInfo? ErrorInfo { get; set; }

    public DepartmentsModel(DatabaseService dbService, ILogger<DepartmentsModel> logger)
    {
        _dbService = dbService;
        _logger = logger;
    }

    public async Task OnGetAsync()
    {
        Departments = await _dbService.GetAllDepartmentsAsync();
        ErrorInfo = _dbService.GetLastError();
    }
}
