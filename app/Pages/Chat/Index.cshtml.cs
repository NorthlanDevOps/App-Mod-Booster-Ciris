using Microsoft.AspNetCore.Mvc.RazorPages;

namespace ExpenseManagement.Pages.Chat;

public class IndexModel : PageModel
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<IndexModel> _logger;
    
    public bool IsGenAIConfigured { get; set; }

    public IndexModel(IConfiguration configuration, ILogger<IndexModel> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public void OnGet()
    {
        var endpoint = _configuration["OpenAI:Endpoint"];
        IsGenAIConfigured = !string.IsNullOrEmpty(endpoint);
        
        if (!IsGenAIConfigured)
        {
            _logger.LogWarning("GenAI services are not configured. Chat functionality is limited.");
        }
    }
}
