using Microsoft.AspNetCore.Mvc;
using AppModBooster.Models;
using AppModBooster.Services;

namespace AppModBooster.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DepartmentController : ControllerBase
{
    private readonly DatabaseService _dbService;
    private readonly ILogger<DepartmentController> _logger;

    public DepartmentController(DatabaseService dbService, ILogger<DepartmentController> logger)
    {
        _dbService = dbService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<List<Department>>> GetAll()
    {
        try
        {
            var departments = await _dbService.GetAllDepartmentsAsync();
            return Ok(departments);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting departments");
            return StatusCode(500, "An error occurred while retrieving departments");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Department>> GetById(int id)
    {
        try
        {
            var department = await _dbService.GetDepartmentByIdAsync(id);
            if (department == null)
                return NotFound();
            
            return Ok(department);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting department {Id}", id);
            return StatusCode(500, "An error occurred while retrieving the department");
        }
    }

    [HttpPost]
    public async Task<ActionResult<int>> Create([FromBody] Department department)
    {
        try
        {
            var id = await _dbService.CreateDepartmentAsync(department);
            return CreatedAtAction(nameof(GetById), new { id }, id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating department");
            return StatusCode(500, "An error occurred while creating the department");
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> Update(int id, [FromBody] Department department)
    {
        try
        {
            department.DepartmentID = id;
            var success = await _dbService.UpdateDepartmentAsync(department);
            if (!success)
                return NotFound();
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating department {Id}", id);
            return StatusCode(500, "An error occurred while updating the department");
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        try
        {
            var success = await _dbService.DeleteDepartmentAsync(id);
            if (!success)
                return NotFound();
            
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting department {Id}", id);
            return StatusCode(500, "An error occurred while deleting the department");
        }
    }
}
