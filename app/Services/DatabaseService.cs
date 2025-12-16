using Microsoft.Data.SqlClient;
using AppModBooster.Models;
using Azure.Identity;

namespace AppModBooster.Services;

public class DatabaseService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<DatabaseService> _logger;
    private ErrorInfo? _lastError;

    public DatabaseService(IConfiguration configuration, ILogger<DatabaseService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public ErrorInfo? GetLastError() => _lastError;

    private SqlConnection GetConnection()
    {
        var connectionString = _configuration.GetConnectionString("DefaultConnection");
        
        if (string.IsNullOrEmpty(connectionString))
        {
            throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        var connection = new SqlConnection(connectionString);
        
        // If using managed identity, set access token
        var managedIdentityClientId = _configuration["ManagedIdentityClientId"];
        if (!string.IsNullOrEmpty(managedIdentityClientId) && 
            connectionString.Contains("Active Directory Managed Identity"))
        {
            try
            {
                var credential = new ManagedIdentityCredential(managedIdentityClientId);
                var token = credential.GetToken(
                    new Azure.Core.TokenRequestContext(new[] { "https://database.windows.net/.default" }));
                connection.AccessToken = token.Token;
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Failed to get managed identity token: {ex.Message}");
            }
        }
        else if (connectionString.Contains("Active Directory Default"))
        {
            try
            {
                var credential = new DefaultAzureCredential();
                var token = credential.GetToken(
                    new Azure.Core.TokenRequestContext(new[] { "https://database.windows.net/.default" }));
                connection.AccessToken = token.Token;
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Failed to get Azure AD token: {ex.Message}");
            }
        }

        return connection;
    }

    private async Task<T?> ExecuteWithErrorHandling<T>(Func<Task<T>> operation, T fallbackValue)
    {
        try
        {
            _lastError = null;
            return await operation();
        }
        catch (Exception ex)
        {
            _lastError = new ErrorInfo
            {
                Message = $"Database error: {ex.Message}. Using dummy data. " +
                         $"If using Managed Identity, ensure the identity '{_configuration["ManagedIdentityClientId"]}' " +
                         $"has been granted db_datareader, db_datawriter, and EXECUTE permissions on the database. " +
                         $"Source: {GetType().Name}",
                Source = ex.Source,
                StackTrace = ex.StackTrace
            };
            _logger.LogError(ex, "Database operation failed");
            return fallbackValue;
        }
    }

    // Property Methods
    public async Task<List<Property>> GetAllPropertiesAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllProperties", connection);
            command.CommandType = System.Data.CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            var properties = new List<Property>();

            while (await reader.ReadAsync())
            {
                properties.Add(new Property
                {
                    PropertyID = reader.GetInt32(0),
                    BuildingName = reader.IsDBNull(1) ? null : reader.GetString(1),
                    HouseNumber = reader.IsDBNull(2) ? null : reader.GetInt32(2),
                    HouseSuffix = reader.IsDBNull(3) ? null : reader.GetString(3),
                    StreetName = reader.IsDBNull(4) ? null : reader.GetString(4),
                    PostalTown = reader.IsDBNull(5) ? null : reader.GetString(5),
                    Postcode = reader.IsDBNull(6) ? null : reader.GetString(6)
                });
            }

            return properties;
        }, GetDummyProperties()) ?? GetDummyProperties();
    }

    public async Task<Property?> GetPropertyByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetPropertyById", connection);
            command.CommandType = System.Data.CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@PropertyID", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                return new Property
                {
                    PropertyID = reader.GetInt32(0),
                    BuildingName = reader.IsDBNull(1) ? null : reader.GetString(1),
                    HouseNumber = reader.IsDBNull(2) ? null : reader.GetInt32(2),
                    HouseSuffix = reader.IsDBNull(3) ? null : reader.GetString(3),
                    StreetName = reader.IsDBNull(4) ? null : reader.GetString(4),
                    PostalTown = reader.IsDBNull(7) ? null : reader.GetString(7),
                    Postcode = reader.IsDBNull(8) ? null : reader.GetString(8)
                };
            }

            return null;
        }, null);
    }

    // Section Methods
    public async Task<List<Section>> GetAllSectionsAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllSections", connection);
            command.CommandType = System.Data.CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            var sections = new List<Section>();

            while (await reader.ReadAsync())
            {
                sections.Add(new Section
                {
                    SectionID = reader.GetInt32(0),
                    WorkbaseID = reader.IsDBNull(1) ? null : reader.GetInt32(1),
                    SectionName = reader.IsDBNull(2) ? null : reader.GetString(2)
                });
            }

            return sections;
        }, GetDummySections()) ?? GetDummySections();
    }

    // Workbase Methods
    public async Task<List<Workbase>> GetAllWorkbasesAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllWorkbases", connection);
            command.CommandType = System.Data.CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            var workbases = new List<Workbase>();

            while (await reader.ReadAsync())
            {
                workbases.Add(new Workbase
                {
                    WorkbaseID = reader.GetInt32(0),
                    WorkbaseName = reader.IsDBNull(1) ? null : reader.GetString(1),
                    Address1 = reader.IsDBNull(2) ? null : reader.GetString(2),
                    Address2 = reader.IsDBNull(3) ? null : reader.GetString(3),
                    Address3 = reader.IsDBNull(4) ? null : reader.GetString(4),
                    Postcode = reader.IsDBNull(5) ? null : reader.GetString(5),
                    Telephone = reader.IsDBNull(6) ? null : reader.GetString(6)
                });
            }

            return workbases;
        }, GetDummyWorkbases()) ?? GetDummyWorkbases();
    }

    // User Methods
    public async Task<List<User>> GetAllUsersAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllUsers", connection);
            command.CommandType = System.Data.CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            var users = new List<User>();

            while (await reader.ReadAsync())
            {
                users.Add(new User
                {
                    UserID = reader.GetInt32(0),
                    UserName = reader.IsDBNull(1) ? null : reader.GetString(1),
                    FirstName = reader.IsDBNull(2) ? null : reader.GetString(2),
                    Email = reader.IsDBNull(3) ? null : reader.GetString(3),
                    SectionID = reader.IsDBNull(5) ? null : reader.GetInt32(5)
                });
            }

            return users;
        }, GetDummyUsers()) ?? GetDummyUsers();
    }

    // Dummy Data Methods
    private List<Property> GetDummyProperties()
    {
        return new List<Property>
        {
            new() { PropertyID = 1, BuildingName = "Demo Building 1", HouseNumber = 10, StreetName = "Demo Street", PostalTown = "Demo Town", Postcode = "AB1 2CD" },
            new() { PropertyID = 2, BuildingName = "Demo Building 2", HouseNumber = 20, StreetName = "Sample Road", PostalTown = "Sample Town", Postcode = "EF3 4GH" }
        };
    }

    private List<Section> GetDummySections()
    {
        return new List<Section>
        {
            new() { SectionID = 1, SectionName = "Demo Section 1", WorkbaseID = 1 },
            new() { SectionID = 2, SectionName = "Demo Section 2", WorkbaseID = 1 }
        };
    }

    private List<Workbase> GetDummyWorkbases()
    {
        return new List<Workbase>
        {
            new() { WorkbaseID = 1, WorkbaseName = "Demo Workbase", Address1 = "123 Demo Street", Postcode = "AB1 2CD", Telephone = "0123456789" }
        };
    }

    private List<User> GetDummyUsers()
    {
        return new List<User>
        {
            new() { UserID = 1, UserName = "demo.user", FirstName = "Demo", LastName = "User", Email = "demo@example.com", SectionID = 1 }
        };
    }
}
