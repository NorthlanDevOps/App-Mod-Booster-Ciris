namespace AppModBooster.Models;

public class User
{
    public int UserID { get; set; }
    public string? UserName { get; set; }
    public string? Email { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public int? SectionID { get; set; }
    public bool? Active { get; set; }
}
