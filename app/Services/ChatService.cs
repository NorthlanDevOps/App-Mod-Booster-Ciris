using Azure.AI.OpenAI;
using Azure.Identity;
using Azure.Core;
using System.Text.Json;
using ExpenseManagement.Models;

namespace ExpenseManagement.Services;

public class ChatService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<ChatService> _logger;
    private readonly DatabaseService _databaseService;
    private OpenAIClient? _client;
    private string? _deploymentName;

    public ChatService(IConfiguration configuration, ILogger<ChatService> logger, DatabaseService databaseService)
    {
        _configuration = configuration;
        _logger = logger;
        _databaseService = databaseService;
        
        InitializeClient();
    }

    private void InitializeClient()
    {
        var endpoint = _configuration["OpenAI:Endpoint"];
        _deploymentName = _configuration["OpenAI:DeploymentName"];
        
        if (string.IsNullOrEmpty(endpoint))
        {
            _logger.LogWarning("OpenAI endpoint not configured");
            return;
        }

        try
        {
            var managedIdentityClientId = _configuration["ManagedIdentityClientId"];
            TokenCredential credential;
            
            if (!string.IsNullOrEmpty(managedIdentityClientId))
            {
                _logger.LogInformation("Using ManagedIdentityCredential with client ID: {ClientId}", managedIdentityClientId);
                credential = new ManagedIdentityCredential(managedIdentityClientId);
            }
            else
            {
                _logger.LogInformation("Using DefaultAzureCredential");
                credential = new DefaultAzureCredential();
            }

            _client = new OpenAIClient(new Uri(endpoint), credential);
            _logger.LogInformation("OpenAI client initialized successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize OpenAI client");
        }
    }

    public async Task<string> GetChatResponseAsync(string userMessage, List<string> conversationHistory)
    {
        if (_client == null || string.IsNullOrEmpty(_deploymentName))
        {
            return "I'm sorry, but the AI service is not configured. Please deploy with GenAI support using deploy-with-chat.sh";
        }

        try
        {
            var messages = new List<ChatRequestMessage>
            {
                new ChatRequestSystemMessage(@"You are a helpful AI assistant for an expense management system. 
You can help users view, create, and manage their expenses. You have access to functions that let you interact with the database.
When users ask about their expenses, use the available functions to retrieve real data.
Format lists nicely with numbers or bullets. Be concise but helpful.")
            };

            // Add conversation history
            foreach (var msg in conversationHistory)
            {
                messages.Add(new ChatRequestUserMessage(msg));
            }

            // Add current message
            messages.Add(new ChatRequestUserMessage(userMessage));

            var chatCompletionsOptions = new ChatCompletionsOptions(_deploymentName, messages);
            
            // Define function tools for function calling
            chatCompletionsOptions.Tools.Add(new ChatCompletionsFunctionToolDefinition
            {
                Name = "get_expenses",
                Description = "Get a list of expenses, optionally filtered by user, status, or category",
                Parameters = BinaryData.FromObjectAsJson(new
                {
                    type = "object",
                    properties = new
                    {
                        userId = new { type = "integer", description = "User ID to filter by" },
                        statusId = new { type = "integer", description = "Status ID to filter by (1=Draft, 2=Submitted, 3=Approved, 4=Rejected)" },
                        categoryId = new { type = "integer", description = "Category ID to filter by" }
                    }
                })
            });

            chatCompletionsOptions.Tools.Add(new ChatCompletionsFunctionToolDefinition
            {
                Name = "get_expense_summary",
                Description = "Get a summary of expenses by status",
                Parameters = BinaryData.FromObjectAsJson(new
                {
                    type = "object",
                    properties = new
                    {
                        userId = new { type = "integer", description = "Optional user ID to get summary for specific user" }
                    }
                })
            });

            chatCompletionsOptions.Tools.Add(new ChatCompletionsFunctionToolDefinition
            {
                Name = "get_users",
                Description = "Get a list of all users in the system",
                Parameters = BinaryData.FromObjectAsJson(new
                {
                    type = "object",
                    properties = new { }
                })
            });

            chatCompletionsOptions.Tools.Add(new ChatCompletionsFunctionToolDefinition
            {
                Name = "get_categories",
                Description = "Get a list of expense categories",
                Parameters = BinaryData.FromObjectAsJson(new
                {
                    type = "object",
                    properties = new { }
                })
            });

            var response = await _client.GetChatCompletionsAsync(chatCompletionsOptions);
            var choice = response.Value.Choices[0];

            // Handle function calls
            if (choice.FinishReason == CompletionsFinishReason.ToolCalls)
            {
                var toolCalls = choice.Message.ToolCalls;
                
                // Add assistant message with tool calls (using the full message from response)
                var assistantMessage = new ChatRequestAssistantMessage(choice.Message);
                messages.Add(assistantMessage);

                foreach (var toolCall in toolCalls)
                {
                    if (toolCall is ChatCompletionsFunctionToolCall functionToolCall)
                    {
                        var functionResult = await ExecuteFunctionAsync(functionToolCall.Name, functionToolCall.Arguments);
                        messages.Add(new ChatRequestToolMessage(functionResult, functionToolCall.Id));
                    }
                }

                // Get final response with function results
                var finalOptions = new ChatCompletionsOptions(_deploymentName, messages);
                var finalResponse = await _client.GetChatCompletionsAsync(finalOptions);
                return finalResponse.Value.Choices[0].Message.Content;
            }

            return choice.Message.Content;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting chat response");
            return $"I apologize, but I encountered an error: {ex.Message}";
        }
    }

    private async Task<string> ExecuteFunctionAsync(string functionName, string argumentsJson)
    {
        try
        {
            _logger.LogInformation("Executing function: {FunctionName} with args: {Args}", functionName, argumentsJson);

            switch (functionName)
            {
                case "get_expenses":
                    var expenseArgs = JsonSerializer.Deserialize<Dictionary<string, object>>(argumentsJson);
                    int? userId = expenseArgs?.ContainsKey("userId") == true ? Convert.ToInt32(expenseArgs["userId"]) : null;
                    int? statusId = expenseArgs?.ContainsKey("statusId") == true ? Convert.ToInt32(expenseArgs["statusId"]) : null;
                    int? categoryId = expenseArgs?.ContainsKey("categoryId") == true ? Convert.ToInt32(expenseArgs["categoryId"]) : null;
                    
                    var expenses = await _databaseService.GetExpensesAsync(userId, statusId, categoryId);
                    return JsonSerializer.Serialize(expenses);

                case "get_expense_summary":
                    var summaryArgs = JsonSerializer.Deserialize<Dictionary<string, object>>(argumentsJson);
                    int? summaryUserId = summaryArgs?.ContainsKey("userId") == true ? Convert.ToInt32(summaryArgs["userId"]) : null;
                    
                    var summary = await _databaseService.GetExpenseSummaryAsync(summaryUserId);
                    return JsonSerializer.Serialize(summary);

                case "get_users":
                    var users = await _databaseService.GetUsersAsync();
                    return JsonSerializer.Serialize(users);

                case "get_categories":
                    var categories = await _databaseService.GetExpenseCategoriesAsync();
                    return JsonSerializer.Serialize(categories);

                default:
                    return $"Unknown function: {functionName}";
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error executing function {FunctionName}", functionName);
            return $"Error executing function: {ex.Message}";
        }
    }
}
