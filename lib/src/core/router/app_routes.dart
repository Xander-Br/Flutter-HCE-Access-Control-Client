class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String itemDetails = 'item/:id'; // Example of a sub-route or route with parameter

  // For named routes with parameters, you might want helper functions:
  static String itemDetailsPath(String id) => '/item/$id';
}