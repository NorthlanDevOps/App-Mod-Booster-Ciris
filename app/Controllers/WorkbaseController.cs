using Microsoft.AspNetCore.Mvc;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WorkbaseController : ControllerBase
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<WorkbaseController> _logger;

    public WorkbaseController(DatabaseService databaseService, ILogger<WorkbaseController> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    /// <summary>
    /// Get all workbases
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Workbase>>> GetAll()
    {
        var workbases = await _databaseService.GetAllWorkbasesAsync();
        return Ok(workbases);
    }
}
