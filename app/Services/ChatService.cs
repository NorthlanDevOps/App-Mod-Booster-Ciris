using Azure;
using Azure.AI.OpenAI;
using Azure.Identity;
using AppModBooster.Models;
using System.Text.Json;

namespace AppModBooster.Services;

public class ChatService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<ChatService> _logger;
    private readonly DatabaseService _databaseService;

    public ChatService(IConfiguration configuration, ILogger<ChatService> logger, DatabaseService databaseService)
    {
        _configuration = configuration;
        _logger = logger;
        _databaseService = databaseService;
    }

    public async Task<string> GetChatResponseAsync(string userMessage)
    {
        var openAIEndpoint = _configuration["OpenAI:Endpoint"];
        var deploymentName = _configuration["OpenAI:DeploymentName"];

        // Check if GenAI is configured
        if (string.IsNullOrEmpty(openAIEndpoint) || string.IsNullOrEmpty(deploymentName))
        {
            return "GenAI services are not deployed. Please run deploy-with-chat.sh to deploy the Azure OpenAI resources and enable AI-powered chat functionality.";
        }

        try
        {
            // Use ManagedIdentityCredential with explicit client ID
            var managedIdentityClientId = _configuration["ManagedIdentityClientId"];
            Azure.Core.TokenCredential credential;
            
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

            var client = new OpenAIClient(new Uri(openAIEndpoint), credential);

            var chatCompletionsOptions = new ChatCompletionsOptions()
            {
                DeploymentName = deploymentName,
                Messages =
                {
                    new ChatRequestSystemMessage(@"You are a helpful assistant for managing properties, sections, workbases, and users.
You have access to the following functions to interact with the database:
- get_all_properties: Retrieves all properties from the database
- get_all_sections: Retrieves all sections from the database
- get_all_workbases: Retrieves all workbases from the database
- get_all_users: Retrieves all users from the database

When a user asks to list or view data, use the appropriate function to fetch the data.
Format your responses in a user-friendly way using markdown for better readability:
- Use **bold** for emphasis
- Use numbered lists (1. 2. 3.) for ordered items
- Use bullet points (- or *) for unordered lists
- Use line breaks for better readability"),
                    new ChatRequestUserMessage(userMessage)
                },
                Tools =
                {
                    new ChatCompletionsFunctionToolDefinition()
                    {
                        Name = "get_all_properties",
                        Description = "Retrieves all properties from the database",
                        Parameters = BinaryData.FromObjectAsJson(new { type = "object", properties = new { } })
                    },
                    new ChatCompletionsFunctionToolDefinition()
                    {
                        Name = "get_all_sections",
                        Description = "Retrieves all sections from the database",
                        Parameters = BinaryData.FromObjectAsJson(new { type = "object", properties = new { } })
                    },
                    new ChatCompletionsFunctionToolDefinition()
                    {
                        Name = "get_all_workbases",
                        Description = "Retrieves all workbases from the database",
                        Parameters = BinaryData.FromObjectAsJson(new { type = "object", properties = new { } })
                    },
                    new ChatCompletionsFunctionToolDefinition()
                    {
                        Name = "get_all_users",
                        Description = "Retrieves all users from the database",
                        Parameters = BinaryData.FromObjectAsJson(new { type = "object", properties = new { } })
                    }
                },
                MaxTokens = 1500,
                Temperature = 0.7f
            };

            // First API call
            var response = await client.GetChatCompletionsAsync(chatCompletionsOptions);
            var responseChoice = response.Value.Choices[0];

            // Check if the model wants to call a function
            while (responseChoice.FinishReason == CompletionsFinishReason.ToolCalls && responseChoice.Message.ToolCalls.Count > 0)
            {
                // Add the assistant's response to the conversation
                chatCompletionsOptions.Messages.Add(new ChatRequestAssistantMessage(responseChoice.Message));

                // Process each tool call
                foreach (var toolCall in responseChoice.Message.ToolCalls)
                {
                    if (toolCall is ChatCompletionsFunctionToolCall functionToolCall)
                    {
                        var functionName = functionToolCall.Name;
                        var functionResult = await ExecuteFunctionAsync(functionName);

                        // Add the function result to the conversation
                        chatCompletionsOptions.Messages.Add(new ChatRequestToolMessage(
                            toolCallId: functionToolCall.Id,
                            content: functionResult
                        ));
                    }
                }

                // Make another API call with the function results
                response = await client.GetChatCompletionsAsync(chatCompletionsOptions);
                responseChoice = response.Value.Choices[0];
            }

            return responseChoice.Message.Content;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting chat response");
            return $"Error: {ex.Message}. Please ensure the Azure OpenAI resources are properly configured and the managed identity has the required permissions.";
        }
    }

    private async Task<string> ExecuteFunctionAsync(string functionName)
    {
        try
        {
            return functionName switch
            {
                "get_all_properties" => await GetAllPropertiesJsonAsync(),
                "get_all_sections" => await GetAllSectionsJsonAsync(),
                "get_all_workbases" => await GetAllWorkbasesJsonAsync(),
                "get_all_users" => await GetAllUsersJsonAsync(),
                _ => JsonSerializer.Serialize(new { error = $"Unknown function: {functionName}" })
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error executing function {FunctionName}", functionName);
            return JsonSerializer.Serialize(new { error = ex.Message });
        }
    }

    private async Task<string> GetAllPropertiesJsonAsync()
    {
        var properties = await _databaseService.GetAllPropertiesAsync();
        return JsonSerializer.Serialize(properties);
    }

    private async Task<string> GetAllSectionsJsonAsync()
    {
        var sections = await _databaseService.GetAllSectionsAsync();
        return JsonSerializer.Serialize(sections);
    }

    private async Task<string> GetAllWorkbasesJsonAsync()
    {
        var workbases = await _databaseService.GetAllWorkbasesAsync();
        return JsonSerializer.Serialize(workbases);
    }

    private async Task<string> GetAllUsersJsonAsync()
    {
        var users = await _databaseService.GetAllUsersAsync();
        return JsonSerializer.Serialize(users);
    }
}
