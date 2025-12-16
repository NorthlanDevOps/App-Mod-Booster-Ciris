using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Pages;

public class WorkbasesModel : PageModel
{
    private readonly DatabaseService _databaseService;

    public WorkbasesModel(DatabaseService databaseService)
    {
        _databaseService = databaseService;
    }

    public List<Workbase> Workbases { get; set; } = new();
    public ErrorInfo? ErrorInfo { get; set; }

    public async Task OnGetAsync()
    {
        Workbases = await _databaseService.GetAllWorkbasesAsync();
        ErrorInfo = _databaseService.GetLastError();
    }
}
