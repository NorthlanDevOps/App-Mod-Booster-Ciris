namespace AppModBooster.Models;

public class User
{
    public int UserId { get; set; }
    public string Forename { get; set; } = string.Empty;
    public string Surname { get; set; } = string.Empty;
    public string NetworkLogon { get; set; } = string.Empty;
    public int DepartmentID { get; set; }
    public int SectionID { get; set; }
    public int WorkbaseID { get; set; }
    public int OccupationID { get; set; }
    public string? EmailAddress { get; set; }
    public string? TelephoneNumber { get; set; }
    public int Role { get; set; }
    public int DefaultDepartmentID { get; set; }
    public int DataAccessType { get; set; }
    public bool Archived { get; set; }
}
