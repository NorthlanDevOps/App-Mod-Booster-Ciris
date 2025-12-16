using Microsoft.AspNetCore.Mvc;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SectionController : ControllerBase
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<SectionController> _logger;

    public SectionController(DatabaseService databaseService, ILogger<SectionController> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    /// <summary>
    /// Get all sections
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Section>>> GetAll()
    {
        var sections = await _databaseService.GetAllSectionsAsync();
        return Ok(sections);
    }
}
