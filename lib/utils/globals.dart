//library globals;

String? currentUser;            // the logged-in username
bool isLoggedIn = false;

int totalDays = 30;            // demo total days (for percent)
int attendanceCount = 0;       // how many days attended
bool scannedToday = false;     // prevents double-marking in same session

// Example valid QR payload (the scanner will match this)
const String validQrPayload = "VALID_QR_123";
