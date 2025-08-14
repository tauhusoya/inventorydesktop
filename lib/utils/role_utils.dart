import '../services/auth_service.dart';

class RoleUtils {
  /// Check if the current user is an admin
  static bool isAdmin(AppUser? user) {
    if (user == null) return false;
    
    // Support multiple admin role formats
    final role = user.role.toLowerCase();
    return role == 'admin' || 
           role == 'administrator' || 
           role == 'superadmin' ||
           role == 'super_admin' ||
           role == 'system_admin';
  }

  /// Check if the current user has a specific role
  static bool hasRole(AppUser? user, String role) {
    if (user == null) return false;
    return user.role.toLowerCase() == role.toLowerCase();
  }

  /// Check if the current user has any of the specified roles
  static bool hasAnyRole(AppUser? user, List<String> roles) {
    if (user == null) return false;
    final userRole = user.role.toLowerCase();
    return roles.any((role) => role.toLowerCase() == userRole);
  }

  /// Check if the current user has all of the specified roles
  static bool hasAllRoles(AppUser? user, List<String> roles) {
    if (user == null) return false;
    final userRole = user.role.toLowerCase();
    return roles.every((role) => role.toLowerCase() == userRole);
  }

  /// Get the display name for a role
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superadmin':
      case 'super_admin':
      case 'system_admin':
        return 'Administrator';
      case 'manager':
      case 'management':
        return 'Manager';
      case 'sales':
      case 'salesperson':
      case 'sales_rep':
        return 'Sales';
      case 'inventory':
      case 'stock':
      case 'warehouse':
        return 'Inventory';
      case 'viewer':
      case 'readonly':
      case 'guest':
        return 'Viewer';
      case 'staff':
      case 'employee':
      case 'user':
        return 'Staff';
      default:
        return role;
    }
  }

  /// Get the color for a role badge
  static int getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superadmin':
      case 'super_admin':
      case 'system_admin':
        return 0xFFE53E3E; // Red
      case 'manager':
      case 'management':
        return 0xFFDD6B20; // Orange
      case 'sales':
      case 'salesperson':
      case 'sales_rep':
        return 0xFF3182CE; // Blue
      case 'inventory':
      case 'stock':
      case 'warehouse':
        return 0xFF38A169; // Green
      case 'viewer':
      case 'readonly':
      case 'guest':
        return 0xFF718096; // Gray
      case 'staff':
      case 'employee':
      case 'user':
        return 0xFF805AD5; // Purple
      default:
        return 0xFF718096; // Gray
    }
  }

  /// Check if a feature requires admin access
  static bool requiresAdmin(String feature) {
    const adminFeatures = [
      'users_management',
      'user_creation',
      'user_deletion',
      'role_management',
      'system_settings',
      'audit_logs',
    ];
    return adminFeatures.contains(feature.toLowerCase());
  }

  /// Check if user can access a specific feature
  static bool canAccessFeature(AppUser? user, String feature) {
    if (user == null) return false;
    
    // Admin can access everything
    if (isAdmin(user)) return true;
    
    // Check feature-specific permissions
    switch (feature.toLowerCase()) {
      case 'users_management':
      case 'user_creation':
      case 'user_deletion':
      case 'role_management':
      case 'system_settings':
      case 'audit_logs':
        return isAdmin(user);
      
      case 'inventory_management':
        return hasAnyRole(user, ['admin', 'manager', 'inventory', 'staff']);
      
      case 'sales_management':
        return hasAnyRole(user, ['admin', 'manager', 'sales', 'staff']);
      
      case 'reports_viewing':
        return hasAnyRole(user, ['admin', 'manager', 'sales', 'inventory', 'staff']);
      
      default:
        return true; // Default to allowing access for unknown features
    }
  }

  /// Get all possible role values (for dropdowns, etc.)
  static List<String> getAllRoles() {
    return [
      'Admin',
      'Manager', 
      'Sales',
      'Inventory',
      'Staff',
      'Viewer',
    ];
  }

  /// Check if a role string is valid
  static bool isValidRole(String role) {
    final validRoles = getAllRoles().map((r) => r.toLowerCase()).toList();
    return validRoles.contains(role.toLowerCase());
  }

  /// Normalize role string to standard format
  static String normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superadmin':
      case 'super_admin':
      case 'system_admin':
        return 'Admin';
      case 'manager':
      case 'management':
        return 'Manager';
      case 'sales':
      case 'salesperson':
      case 'sales_rep':
        return 'Sales';
      case 'inventory':
      case 'stock':
      case 'warehouse':
        return 'Inventory';
      case 'viewer':
      case 'readonly':
      case 'guest':
        return 'Viewer';
      case 'staff':
      case 'employee':
      case 'user':
        return 'Staff';
      default:
        return role; // Return as-is if unknown
    }
  }
}
