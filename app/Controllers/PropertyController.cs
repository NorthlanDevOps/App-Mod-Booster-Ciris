using Microsoft.AspNetCore.Mvc;
using AppModBooster.Services;
using AppModBooster.Models;

namespace AppModBooster.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PropertyController : ControllerBase
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<PropertyController> _logger;

    public PropertyController(DatabaseService databaseService, ILogger<PropertyController> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    /// <summary>
    /// Get all properties
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Property>>> GetAll()
    {
        var properties = await _databaseService.GetAllPropertiesAsync();
        return Ok(properties);
    }

    /// <summary>
    /// Get a property by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Property>> GetById(int id)
    {
        var property = await _databaseService.GetPropertyByIdAsync(id);
        if (property == null)
        {
            return NotFound();
        }
        return Ok(property);
    }
}
