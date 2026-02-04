# Contributing to OBLNS

Thank you for your interest in contributing to OBLNS! We welcome contributions from the community. This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.0)
- Dart SDK (>=3.8.0)
- Android Studio / Xcode
- Git

### Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/oblns.git
   cd oblns/mobile
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/original-org/oblns.git
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
5. Install dependencies:
   ```bash
   flutter pub get
   ```
6. Set up environment variables (copy `.env.example` to `.env`)

## 📝 Development Guidelines

### Code Style
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Run `flutter analyze` to check for issues
- Write meaningful commit messages

### Architecture
- Follow Clean Architecture principles
- Use Riverpod for state management
- Keep business logic separate from UI
- Write unit tests for business logic

### File Structure
```
lib/
├── app/                    # App-level configurations
├── core/                   # Core utilities and services
├── features/               # Feature modules
│   ├── auth/              # Authentication feature
│   ├── orders/            # Order management
│   └── ...
├── infrastructure/        # External services (API, DB)
├── shared/                # Shared components and utilities
└── main.dart
```

### Naming Conventions
- Use PascalCase for classes
- Use camelCase for variables and methods
- Use snake_case for file names
- Use UPPER_SNAKE_CASE for constants

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 🔄 Pull Request Process

1. **Update the README.md** with details of changes if needed
2. **Update the CHANGELOG.md** with a note about your changes
3. **Ensure tests pass** and add new tests if necessary
4. **Update documentation** for any new features
5. **Follow the commit message format**:
   ```
   type(scope): description

   [optional body]

   [optional footer]
   ```
   Types: feat, fix, docs, style, refactor, test, chore

6. **Create a Pull Request** with:
   - Clear title and description
   - Reference to any related issues
   - Screenshots for UI changes
   - Test results

## 🎯 Feature Development

### Adding a New Feature
1. Create an issue describing the feature
2. Discuss the implementation approach
3. Create a feature branch
4. Implement the feature following our guidelines
5. Write comprehensive tests
6. Update documentation
7. Submit a pull request

### Feature Checklist
- [ ] Feature is well-documented
- [ ] Unit tests are written
- [ ] Integration tests are written
- [ ] UI tests are written (if applicable)
- [ ] Documentation is updated
- [ ] CHANGELOG is updated
- [ ] Code follows style guidelines
- [ ] No breaking changes without discussion

## 🐛 Bug Reports

### How to Report a Bug
1. Check if the bug is already reported
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Environment details (Flutter version, OS, etc.)
   - Screenshots/logs if applicable

### Bug Fix Process
1. Create an issue for the bug
2. Assign yourself to the issue
3. Create a fix branch
4. Write a test that reproduces the bug
5. Fix the bug
6. Ensure all tests pass
7. Submit a pull request

## 📚 Documentation

### Code Documentation
- Use Dart doc comments for public APIs
- Document complex business logic
- Keep comments up to date

### API Documentation
- Document all API endpoints
- Include request/response examples
- Document error codes

## 🔐 Security

- Never commit sensitive information
- Use environment variables for secrets
- Follow secure coding practices
- Report security issues privately

## 📞 Communication

- Use GitHub issues for bug reports and feature requests
- Join our Discord community for discussions
- Follow our code of conduct

## 🎉 Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- GitHub contributors list
- Project documentation

Thank you for contributing to OBLNS! 🚀