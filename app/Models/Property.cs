namespace AppModBooster.Models;

public class Property
{
    public int PropertyID { get; set; }
    public string BuildingName { get; set; } = string.Empty;
    public int? HouseNumber { get; set; }
    public string? HouseSuffix { get; set; }
    public string StreetName { get; set; } = string.Empty;
    public string? TownVillage { get; set; }
    public string PostalTown { get; set; } = string.Empty;
    public string? County { get; set; }
    public string Postcode { get; set; } = string.Empty;
    public string? TelephoneNumber { get; set; }
    public string? PropertyManager { get; set; }
    public string? EmailAddress { get; set; }
    public string? Information { get; set; }
    public int? UPRN { get; set; }
    public bool Archived { get; set; }
}
