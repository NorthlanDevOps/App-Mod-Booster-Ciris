using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Pages;

public class IndexModel : PageModel
{
    private readonly DatabaseService _databaseService;

    public IndexModel(DatabaseService databaseService)
    {
        _databaseService = databaseService;
    }

    public ErrorInfo? ErrorInfo { get; set; }

    public async Task OnGetAsync()
    {
        // Test database connection by trying to fetch properties
        await _databaseService.GetAllPropertiesAsync();
        ErrorInfo = _databaseService.GetLastError();
    }
}
