class Env {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://talentlink-backend-879841675037.europe-west1.run.app/api',
  );

  static const String baseUrl2 = String.fromEnvironment(
    'API_BASE_URL2',
    defaultValue:
        'https://talentlink-backend-879841675037.europe-west1.run.app',
  );
}
