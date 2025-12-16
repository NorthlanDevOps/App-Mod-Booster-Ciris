namespace AppModBooster.Models;

public class ErrorInfo
{
    public string Message { get; set; } = string.Empty;
    public string? Source { get; set; }
    public string? StackTrace { get; set; }
}
