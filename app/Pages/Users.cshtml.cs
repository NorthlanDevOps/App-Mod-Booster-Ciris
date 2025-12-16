using Microsoft.AspNetCore.Mvc.RazorPages;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Pages;

public class UsersModel : PageModel
{
    private readonly DatabaseService _databaseService;

    public UsersModel(DatabaseService databaseService)
    {
        _databaseService = databaseService;
    }

    public List<User> Users { get; set; } = new();
    public ErrorInfo? ErrorInfo { get; set; }

    public async Task OnGetAsync()
    {
        Users = await _databaseService.GetAllUsersAsync();
        ErrorInfo = _databaseService.GetLastError();
    }
}
