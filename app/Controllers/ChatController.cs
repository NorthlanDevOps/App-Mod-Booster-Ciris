using Microsoft.AspNetCore.Mvc;
using ExpenseManagement.Services;

namespace ExpenseManagement.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChatController : ControllerBase
{
    private readonly ChatService _chatService;
    private readonly ILogger<ChatController> _logger;

    public ChatController(ChatService chatService, ILogger<ChatController> logger)
    {
        _chatService = chatService;
        _logger = logger;
    }

    public class ChatRequest
    {
        public string Message { get; set; } = string.Empty;
        public List<string> History { get; set; } = new();
    }

    public class ChatResponse
    {
        public string Response { get; set; } = string.Empty;
    }

    /// <summary>
    /// Send a message to the AI chat assistant
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ChatResponse>> Chat([FromBody] ChatRequest request)
    {
        try
        {
            if (string.IsNullOrEmpty(request.Message))
            {
                return BadRequest(new { error = "Message is required" });
            }

            var response = await _chatService.GetChatResponseAsync(request.Message, request.History ?? new());
            return Ok(new ChatResponse { Response = response });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing chat request");
            return StatusCode(500, new { error = "Error processing chat request", details = ex.Message });
        }
    }
}
