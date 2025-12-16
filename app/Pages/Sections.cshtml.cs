using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Pages;

public class SectionsModel : PageModel
{
    private readonly DatabaseService _databaseService;

    public SectionsModel(DatabaseService databaseService)
    {
        _databaseService = databaseService;
    }

    public List<Section> Sections { get; set; } = new();
    public ErrorInfo? ErrorInfo { get; set; }

    public async Task OnGetAsync()
    {
        Sections = await _databaseService.GetAllSectionsAsync();
        ErrorInfo = _databaseService.GetLastError();
    }
}
