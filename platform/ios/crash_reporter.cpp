// Keep Apple's native crash reporting; the desktop libbacktrace/signal handler
// is intentionally not installed in the iOS application.
#include "crash_reporter.hpp"

bool CrashReporter_Init(const std::filesystem::path&) { return false; }
void CrashReporter_SetContextProvider(CrashContextProvider) {}
void CrashReporter_Shutdown() {}
const char* CrashReporter_GetSystemInfo() { return "iOS: native Apple crash reporting"; }
const std::filesystem::path& CrashReporter_GetReportPath() {
    static const std::filesystem::path empty;
    return empty;
}
const std::filesystem::path& CrashReporter_GetSymbolPath() {
    return CrashReporter_GetReportPath();
}
