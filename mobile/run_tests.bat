@echo off
echo Running Static Analysis...
call flutter analyze
if %errorlevel% neq 0 exit /b %errorlevel%

echo Running Unit Tests...
call flutter test test/core/utils/polyline_util_test.dart test/core/models/user_model_test.dart
if %errorlevel% neq 0 exit /b %errorlevel%

echo All Tests Passed!
