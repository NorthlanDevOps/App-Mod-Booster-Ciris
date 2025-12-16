using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Pages;

public class PropertiesModel : PageModel
{
    private readonly DatabaseService _databaseService;

    public PropertiesModel(DatabaseService databaseService)
    {
        _databaseService = databaseService;
    }

    public List<Property> Properties { get; set; } = new();
    public ErrorInfo? ErrorInfo { get; set; }

    public async Task OnGetAsync()
    {
        Properties = await _databaseService.GetAllPropertiesAsync();
        ErrorInfo = _databaseService.GetLastError();
    }
}
