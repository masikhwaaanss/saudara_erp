/// Application Constants
class AppConstants {
  // App Info
  static const String appName = 'SAUDARA ERP';
  static const String companyName = 'SAUDARA PLAFON PVC METESEH';
  static const String version = '1.0.0';
  
  // Database
  static const String databaseName = 'saudara_erp';
  
  // Timing
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedFileExtensions = ['xls', 'xlsx', 'csv'];
  
  // Currency
  static const String currencySymbol = 'Rp';
  static const int decimalPlaces = 0;
  
  // Invoice Settings
  static const String invoicePrefix = 'INV';
  static const String deliveryNotePrefix = 'SJ';
  static const String quotationPrefix = 'QT';
  
  // Print
  static const double thermalPrintWidth = 80; // mm
  
  // Stock
  static const bool allowNegativeStock = false;
  
  // Business Hours
  static const String businessStartTime = '08:00';
  static const String businessEndTime = '17:00';
}
