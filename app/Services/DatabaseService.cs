using Microsoft.Data.SqlClient;
using AppModBooster.Models;
using Azure.Identity;
using System.Data;

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
                         $"Run the database role configuration script (run-sql-dbrole.py) to fix this. " +
                         $"Source: {GetType().Name}",
                Source = ex.Source,
                StackTrace = ex.StackTrace
            };
            _logger.LogError(ex, "Database operation failed");
            return fallbackValue;
        }
    }

    // Department Methods
    public async Task<List<Department>> GetAllDepartmentsAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllDepartments", connection);
            command.CommandType = CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            var departments = new List<Department>();
            while (await reader.ReadAsync())
            {
                departments.Add(new Department
                {
                    DepartmentID = reader.GetInt32(0),
                    Description = reader.GetString(1),
                    Archived = reader.GetBoolean(2),
                    F2508Contact = reader.GetInt32(3)
                });
            }
            return departments;
        }, GetDummyDepartments());
    }

    public async Task<Department?> GetDepartmentByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetDepartmentById", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@DepartmentID", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new Department
                {
                    DepartmentID = reader.GetInt32(0),
                    Description = reader.GetString(1),
                    Archived = reader.GetBoolean(2),
                    F2508Contact = reader.GetInt32(3)
                };
            }
            return null;
        }, null);
    }

    public async Task<int> CreateDepartmentAsync(Department department)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_CreateDepartment", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@Description", department.Description);
            command.Parameters.AddWithValue("@F2508Contact", department.F2508Contact);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }, 0);
    }

    public async Task<bool> UpdateDepartmentAsync(Department department)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_UpdateDepartment", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@DepartmentID", department.DepartmentID);
            command.Parameters.AddWithValue("@Description", department.Description);
            command.Parameters.AddWithValue("@F2508Contact", department.F2508Contact);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    public async Task<bool> DeleteDepartmentAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_DeleteDepartment", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@DepartmentID", id);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    // Property Methods
    public async Task<List<Property>> GetAllPropertiesAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllProperties", connection);
            command.CommandType = CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            var properties = new List<Property>();
            while (await reader.ReadAsync())
            {
                properties.Add(new Property
                {
                    PropertyID = reader.GetInt32(0),
                    BuildingName = reader.GetString(1),
                    HouseNumber = reader.IsDBNull(2) ? null : reader.GetInt32(2),
                    HouseSuffix = reader.IsDBNull(3) ? null : reader.GetString(3),
                    StreetName = reader.GetString(4),
                    PostalTown = reader.GetString(5),
                    Postcode = reader.GetString(6),
                    Archived = reader.GetBoolean(7)
                });
            }
            return properties;
        }, GetDummyProperties());
    }

    public async Task<Property?> GetPropertyByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetPropertyById", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@PropertyID", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new Property
                {
                    PropertyID = reader.GetInt32(0),
                    BuildingName = reader.GetString(1),
                    HouseNumber = reader.IsDBNull(2) ? null : reader.GetInt32(2),
                    HouseSuffix = reader.IsDBNull(3) ? null : reader.GetString(3),
                    StreetName = reader.GetString(4),
                    TownVillage = reader.IsDBNull(5) ? null : reader.GetString(5),
                    PostalTown = reader.GetString(6),
                    County = reader.IsDBNull(7) ? null : reader.GetString(7),
                    Postcode = reader.GetString(8),
                    TelephoneNumber = reader.IsDBNull(9) ? null : reader.GetString(9),
                    PropertyManager = reader.IsDBNull(10) ? null : reader.GetString(10),
                    EmailAddress = reader.IsDBNull(11) ? null : reader.GetString(11),
                    Information = reader.IsDBNull(12) ? null : reader.GetString(12),
                    UPRN = reader.IsDBNull(13) ? null : reader.GetInt32(13),
                    Archived = reader.GetBoolean(14)
                };
            }
            return null;
        }, null);
    }

    public async Task<int> CreatePropertyAsync(Property property)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_CreateProperty", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@BuildingName", property.BuildingName);
            command.Parameters.AddWithValue("@HouseNumber", property.HouseNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@HouseSuffix", property.HouseSuffix ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@StreetName", property.StreetName);
            command.Parameters.AddWithValue("@TownVillage", property.TownVillage ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@PostalTown", property.PostalTown);
            command.Parameters.AddWithValue("@County", property.County ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Postcode", property.Postcode);
            command.Parameters.AddWithValue("@TelephoneNumber", property.TelephoneNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@PropertyManager", property.PropertyManager ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@EmailAddress", property.EmailAddress ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Information", property.Information ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@UPRN", property.UPRN ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }, 0);
    }

    public async Task<bool> UpdatePropertyAsync(Property property)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_UpdateProperty", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@PropertyID", property.PropertyID);
            command.Parameters.AddWithValue("@BuildingName", property.BuildingName);
            command.Parameters.AddWithValue("@HouseNumber", property.HouseNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@HouseSuffix", property.HouseSuffix ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@StreetName", property.StreetName);
            command.Parameters.AddWithValue("@TownVillage", property.TownVillage ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@PostalTown", property.PostalTown);
            command.Parameters.AddWithValue("@County", property.County ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Postcode", property.Postcode);
            command.Parameters.AddWithValue("@TelephoneNumber", property.TelephoneNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@PropertyManager", property.PropertyManager ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@EmailAddress", property.EmailAddress ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Information", property.Information ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@UPRN", property.UPRN ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    public async Task<bool> DeletePropertyAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_DeleteProperty", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@PropertyID", id);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    // Section Methods
    public async Task<List<Section>> GetAllSectionsAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllSections", connection);
            command.CommandType = CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            var sections = new List<Section>();
            while (await reader.ReadAsync())
            {
                sections.Add(new Section
                {
                    SectionID = reader.GetInt32(0),
                    DepartmentID = reader.GetInt32(1),
                    Description = reader.GetString(2),
                    Archived = reader.GetBoolean(3)
                });
            }
            return sections;
        }, GetDummySections());
    }

    public async Task<Section?> GetSectionByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetSectionById", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@SectionID", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new Section
                {
                    SectionID = reader.GetInt32(0),
                    DepartmentID = reader.GetInt32(1),
                    Description = reader.GetString(2),
                    Archived = reader.GetBoolean(3)
                };
            }
            return null;
        }, null);
    }

    public async Task<int> CreateSectionAsync(Section section)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_CreateSection", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@DepartmentID", section.DepartmentID);
            command.Parameters.AddWithValue("@Description", section.Description);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }, 0);
    }

    public async Task<bool> UpdateSectionAsync(Section section)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_UpdateSection", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@SectionID", section.SectionID);
            command.Parameters.AddWithValue("@DepartmentID", section.DepartmentID);
            command.Parameters.AddWithValue("@Description", section.Description);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    public async Task<bool> DeleteSectionAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_DeleteSection", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@SectionID", id);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    // Workbase Methods
    public async Task<List<Workbase>> GetAllWorkbasesAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllWorkbases", connection);
            command.CommandType = CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            var workbases = new List<Workbase>();
            while (await reader.ReadAsync())
            {
                workbases.Add(new Workbase
                {
                    WorkBaseID = reader.GetInt32(0),
                    SectionID = reader.GetInt32(1),
                    PropertyID = reader.GetInt32(2),
                    Archived = reader.GetBoolean(3),
                    SectionDescription = reader.IsDBNull(4) ? null : reader.GetString(4),
                    PropertyName = reader.IsDBNull(5) ? null : reader.GetString(5)
                });
            }
            return workbases;
        }, GetDummyWorkbases());
    }

    public async Task<Workbase?> GetWorkbaseByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetWorkbaseById", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@WorkbaseID", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new Workbase
                {
                    WorkBaseID = reader.GetInt32(0),
                    SectionID = reader.GetInt32(1),
                    PropertyID = reader.GetInt32(2),
                    Archived = reader.GetBoolean(3),
                    SectionDescription = reader.IsDBNull(4) ? null : reader.GetString(4),
                    PropertyName = reader.IsDBNull(5) ? null : reader.GetString(5)
                };
            }
            return null;
        }, null);
    }

    public async Task<int> CreateWorkbaseAsync(Workbase workbase)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_CreateWorkbase", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@SectionID", workbase.SectionID);
            command.Parameters.AddWithValue("@PropertyID", workbase.PropertyID);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }, 0);
    }

    public async Task<bool> UpdateWorkbaseAsync(Workbase workbase)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_UpdateWorkbase", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@WorkbaseID", workbase.WorkBaseID);
            command.Parameters.AddWithValue("@SectionID", workbase.SectionID);
            command.Parameters.AddWithValue("@PropertyID", workbase.PropertyID);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    public async Task<bool> DeleteWorkbaseAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_DeleteWorkbase", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@WorkbaseID", id);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    // User Methods
    public async Task<List<User>> GetAllUsersAsync()
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetAllUsers", connection);
            command.CommandType = CommandType.StoredProcedure;

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            var users = new List<User>();
            while (await reader.ReadAsync())
            {
                users.Add(new User
                {
                    UserId = reader.GetInt32(0),
                    Forename = reader.GetString(1),
                    Surname = reader.GetString(2),
                    NetworkLogon = reader.GetString(3),
                    DepartmentID = reader.GetInt32(4),
                    SectionID = reader.GetInt32(5),
                    WorkbaseID = reader.GetInt32(6),
                    OccupationID = reader.GetInt32(7),
                    EmailAddress = reader.IsDBNull(8) ? null : reader.GetString(8),
                    TelephoneNumber = reader.IsDBNull(9) ? null : reader.GetString(9),
                    Role = reader.GetInt32(10),
                    DefaultDepartmentID = reader.GetInt32(11),
                    DataAccessType = reader.GetInt32(12),
                    Archived = reader.GetBoolean(13)
                });
            }
            return users;
        }, GetDummyUsers());
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_GetUserById", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@UserId", id);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();
            
            if (await reader.ReadAsync())
            {
                return new User
                {
                    UserId = reader.GetInt32(0),
                    Forename = reader.GetString(1),
                    Surname = reader.GetString(2),
                    NetworkLogon = reader.GetString(3),
                    DepartmentID = reader.GetInt32(4),
                    SectionID = reader.GetInt32(5),
                    WorkbaseID = reader.GetInt32(6),
                    OccupationID = reader.GetInt32(7),
                    EmailAddress = reader.IsDBNull(8) ? null : reader.GetString(8),
                    TelephoneNumber = reader.IsDBNull(9) ? null : reader.GetString(9),
                    Role = reader.GetInt32(10),
                    DefaultDepartmentID = reader.GetInt32(11),
                    DataAccessType = reader.GetInt32(12),
                    Archived = reader.GetBoolean(13)
                };
            }
            return null;
        }, null);
    }

    public async Task<int> CreateUserAsync(User user)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_CreateUser", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@Forename", user.Forename);
            command.Parameters.AddWithValue("@Surname", user.Surname);
            command.Parameters.AddWithValue("@NetworkLogon", user.NetworkLogon);
            command.Parameters.AddWithValue("@DepartmentID", user.DepartmentID);
            command.Parameters.AddWithValue("@SectionID", user.SectionID);
            command.Parameters.AddWithValue("@WorkbaseID", user.WorkbaseID);
            command.Parameters.AddWithValue("@OccupationID", user.OccupationID);
            command.Parameters.AddWithValue("@EmailAddress", user.EmailAddress ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@TelephoneNumber", user.TelephoneNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Role", user.Role);
            command.Parameters.AddWithValue("@DefaultDepartmentID", user.DefaultDepartmentID);
            command.Parameters.AddWithValue("@DataAccessType", user.DataAccessType);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            var result = await command.ExecuteScalarAsync();
            return Convert.ToInt32(result);
        }, 0);
    }

    public async Task<bool> UpdateUserAsync(User user)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_UpdateUser", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@UserId", user.UserId);
            command.Parameters.AddWithValue("@Forename", user.Forename);
            command.Parameters.AddWithValue("@Surname", user.Surname);
            command.Parameters.AddWithValue("@NetworkLogon", user.NetworkLogon);
            command.Parameters.AddWithValue("@DepartmentID", user.DepartmentID);
            command.Parameters.AddWithValue("@SectionID", user.SectionID);
            command.Parameters.AddWithValue("@WorkbaseID", user.WorkbaseID);
            command.Parameters.AddWithValue("@OccupationID", user.OccupationID);
            command.Parameters.AddWithValue("@EmailAddress", user.EmailAddress ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@TelephoneNumber", user.TelephoneNumber ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Role", user.Role);
            command.Parameters.AddWithValue("@DefaultDepartmentID", user.DefaultDepartmentID);
            command.Parameters.AddWithValue("@DataAccessType", user.DataAccessType);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    public async Task<bool> DeleteUserAsync(int id)
    {
        return await ExecuteWithErrorHandling(async () =>
        {
            using var connection = GetConnection();
            using var command = new SqlCommand("sp_DeleteUser", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@UserId", id);
            command.Parameters.AddWithValue("@AuditUser", "system");

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();
            return true;
        }, false);
    }

    // Dummy Data Methods
    private List<Department> GetDummyDepartments()
    {
        return new List<Department>
        {
            new() { DepartmentID = 1, Description = "Demo Department 1", Archived = false, F2508Contact = 0 },
            new() { DepartmentID = 2, Description = "Demo Department 2", Archived = false, F2508Contact = 0 }
        };
    }

    private List<Property> GetDummyProperties()
    {
        return new List<Property>
        {
            new() { PropertyID = 1, BuildingName = "Demo Building", StreetName = "Demo Street", PostalTown = "Demo Town", Postcode = "AB1 2CD", Archived = false }
        };
    }

    private List<Section> GetDummySections()
    {
        return new List<Section>
        {
            new() { SectionID = 1, DepartmentID = 1, Description = "Demo Section 1", Archived = false },
            new() { SectionID = 2, DepartmentID = 1, Description = "Demo Section 2", Archived = false }
        };
    }

    private List<Workbase> GetDummyWorkbases()
    {
        return new List<Workbase>
        {
            new() { WorkBaseID = 1, SectionID = 1, PropertyID = 1, Archived = false, SectionDescription = "Demo Section", PropertyName = "Demo Building" }
        };
    }

    private List<User> GetDummyUsers()
    {
        return new List<User>
        {
            new() { UserId = 1, Forename = "Demo", Surname = "User", NetworkLogon = "demo.user", DepartmentID = 1, SectionID = 1, WorkbaseID = 1, OccupationID = 0, Role = 0, DefaultDepartmentID = 1, DataAccessType = 0, Archived = false }
        };
    }
}
