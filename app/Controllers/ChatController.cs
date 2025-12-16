using Microsoft.AspNetCore.Mvc;
using AppModBooster.Services;

namespace AppModBooster.Controllers;

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

    /// <summary>
    /// Send a chat message and get AI response
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<string>> SendMessage([FromBody] ChatRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Message))
        {
            return BadRequest("Message cannot be empty");
        }

        var response = await _chatService.GetChatResponseAsync(request.Message);
        return Ok(new { message = response });
    }
}

public record ChatRequest(string Message);
