using Microsoft.AspNetCore.Mvc;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController : ControllerBase
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<UserController> _logger;

    public UserController(DatabaseService databaseService, ILogger<UserController> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    /// <summary>
    /// Get all users
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<User>>> GetAll()
    {
        var users = await _databaseService.GetAllUsersAsync();
        return Ok(users);
    }
}
