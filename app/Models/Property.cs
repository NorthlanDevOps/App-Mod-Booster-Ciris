namespace AppModBooster.Models;

public class Property
{
    public int PropertyID { get; set; }
    public string? BuildingName { get; set; }
    public int? HouseNumber { get; set; }
    public string? HouseSuffix { get; set; }
    public string? StreetName { get; set; }
    public string? PostalTown { get; set; }
    public string? Postcode { get; set; }
    public int? SectionID { get; set; }
    public bool? Active { get; set; }
}
