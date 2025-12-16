using Microsoft.AspNetCore.Mvc;
using ExpenseManagement.Models;
using ExpenseManagement.Services;

namespace ExpenseManagement.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ExpensesController : ControllerBase
{
    private readonly DatabaseService _databaseService;
    private readonly ILogger<ExpensesController> _logger;

    public ExpensesController(DatabaseService databaseService, ILogger<ExpensesController> logger)
    {
        _databaseService = databaseService;
        _logger = logger;
    }

    /// <summary>
    /// Get all expenses with optional filters
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<Expense>>> GetExpenses(
        [FromQuery] int? userId = null,
        [FromQuery] int? statusId = null,
        [FromQuery] int? categoryId = null)
    {
        try
        {
            var expenses = await _databaseService.GetExpensesAsync(userId, statusId, categoryId);
            return Ok(expenses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expenses");
            return StatusCode(500, new { error = "Error retrieving expenses", details = ex.Message });
        }
    }

    /// <summary>
    /// Get expense by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<Expense>> GetExpenseById(int id)
    {
        try
        {
            var expense = await _databaseService.GetExpenseByIdAsync(id);
            if (expense == null)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(expense);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense by ID");
            return StatusCode(500, new { error = "Error retrieving expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Create a new expense
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<int>> CreateExpense([FromBody] CreateExpenseRequest request)
    {
        try
        {
            var expenseId = await _databaseService.CreateExpenseAsync(request);
            return CreatedAtAction(nameof(GetExpenseById), new { id = expenseId }, new { expenseId });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating expense");
            return StatusCode(500, new { error = "Error creating expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Update an existing expense
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateExpense(int id, [FromBody] UpdateExpenseRequest request)
    {
        try
        {
            request.ExpenseId = id;
            var rowsAffected = await _databaseService.UpdateExpenseAsync(request);
            if (rowsAffected == 0)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(new { message = "Expense updated successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating expense");
            return StatusCode(500, new { error = "Error updating expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Submit an expense for approval
    /// </summary>
    [HttpPost("{id}/submit")]
    public async Task<ActionResult> SubmitExpense(int id)
    {
        try
        {
            var rowsAffected = await _databaseService.SubmitExpenseAsync(id);
            if (rowsAffected == 0)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(new { message = "Expense submitted successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error submitting expense");
            return StatusCode(500, new { error = "Error submitting expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Approve an expense
    /// </summary>
    [HttpPost("{id}/approve")]
    public async Task<ActionResult> ApproveExpense(int id, [FromQuery] int reviewedBy)
    {
        try
        {
            var rowsAffected = await _databaseService.ApproveExpenseAsync(id, reviewedBy);
            if (rowsAffected == 0)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(new { message = "Expense approved successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error approving expense");
            return StatusCode(500, new { error = "Error approving expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Reject an expense
    /// </summary>
    [HttpPost("{id}/reject")]
    public async Task<ActionResult> RejectExpense(int id, [FromQuery] int reviewedBy)
    {
        try
        {
            var rowsAffected = await _databaseService.RejectExpenseAsync(id, reviewedBy);
            if (rowsAffected == 0)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(new { message = "Expense rejected successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error rejecting expense");
            return StatusCode(500, new { error = "Error rejecting expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Delete an expense
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteExpense(int id)
    {
        try
        {
            var rowsAffected = await _databaseService.DeleteExpenseAsync(id);
            if (rowsAffected == 0)
            {
                return NotFound(new { error = "Expense not found" });
            }
            return Ok(new { message = "Expense deleted successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting expense");
            return StatusCode(500, new { error = "Error deleting expense", details = ex.Message });
        }
    }

    /// <summary>
    /// Get expenses for manager review
    /// </summary>
    [HttpGet("review/{managerId}")]
    public async Task<ActionResult<List<Expense>>> GetExpensesForReview(int managerId)
    {
        try
        {
            var expenses = await _databaseService.GetExpensesForReviewAsync(managerId);
            return Ok(expenses);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expenses for review");
            return StatusCode(500, new { error = "Error retrieving expenses for review", details = ex.Message });
        }
    }

    /// <summary>
    /// Get expense summary statistics
    /// </summary>
    [HttpGet("summary")]
    public async Task<ActionResult<List<ExpenseSummary>>> GetExpenseSummary([FromQuery] int? userId = null)
    {
        try
        {
            var summary = await _databaseService.GetExpenseSummaryAsync(userId);
            return Ok(summary);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting expense summary");
            return StatusCode(500, new { error = "Error retrieving expense summary", details = ex.Message });
        }
    }
}
