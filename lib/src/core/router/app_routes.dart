class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String card = '/card';
  static const String cardDetails = '/card/:id'; 

  static String cardDetailsPath(String id) => '/card/$id'; // Helper method to generate path
}