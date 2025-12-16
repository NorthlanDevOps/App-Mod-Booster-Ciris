namespace AppModBooster.Models;

public class Workbase
{
    public int WorkBaseID { get; set; }
    public int SectionID { get; set; }
    public int PropertyID { get; set; }
    public bool Archived { get; set; }
    public string? SectionDescription { get; set; }
    public string? PropertyName { get; set; }
}
