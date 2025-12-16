namespace AppModBooster.Models;

public class Department
{
    public int DepartmentID { get; set; }
    public string Description { get; set; } = string.Empty;
    public bool Archived { get; set; }
    public int F2508Contact { get; set; }
}
