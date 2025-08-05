# Version Management Guide

## Overview

IntelliCash follows **Semantic Versioning (SemVer)** principles to ensure clear, predictable versioning that helps users and developers understand the impact of updates.

## Version Format

```
MAJOR.MINOR.PATCH+BUILD
```

### Components

- **MAJOR**: Incompatible API changes or major feature releases
- **MINOR**: New functionality in a backward compatible manner
- **PATCH**: Backward compatible bug fixes
- **BUILD**: Build number for app store releases (optional)

### Current Version: `7.5.1+750001`

- **MAJOR**: 7 (Major version)
- **MINOR**: 5 (Feature releases)
- **PATCH**: 1 (Bug fixes)
- **BUILD**: 750001 (Build number)

## Versioning Rules

### When to Increment MAJOR (X.0.0)

- Breaking changes to the API
- Major UI/UX redesigns
- Database schema changes that require migration
- Removal of deprecated features
- Changes that require user action to upgrade

**Examples:**
- Complete redesign of the transaction interface
- New database schema requiring data migration
- Removal of legacy features

### When to Increment MINOR (X.Y.0)

- New features added in a backward compatible manner
- New UI components or screens
- Performance improvements
- New integrations or services
- Enhanced functionality

**Examples:**
- New AI-powered transaction categorization
- Additional export formats
- New chart types for analytics
- Integration with new financial services

### When to Increment PATCH (X.Y.Z)

- Bug fixes
- Security patches
- Minor UI improvements
- Performance optimizations
- Documentation updates

**Examples:**
- Fix for transaction calculation errors
- Security vulnerability patches
- Minor UI alignment issues
- Performance improvements

## Version Management Process

### 1. Development Workflow

```bash
# Check current version
flutter pub deps

# Update version for new release
# Edit pubspec.yaml and update version number
```

### 2. Release Process

1. **Feature Development**
   - Work on features in feature branches
   - Use descriptive commit messages
   - Follow conventional commits

2. **Version Planning**
   - Determine impact of changes
   - Choose appropriate version increment
   - Update version in `pubspec.yaml`

3. **Testing**
   - Run comprehensive tests
   - Test on multiple devices
   - Verify database migrations

4. **Release**
   - Create release tag
   - Update changelog
   - Deploy to app stores

### 3. Conventional Commits

Follow conventional commit format for better version management:

```
type(scope): description

feat(transactions): add bulk edit functionality
fix(ui): resolve alignment issues in dashboard
docs(readme): update installation instructions
```

**Types:**
- `feat`: New features (MINOR)
- `fix`: Bug fixes (PATCH)
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Version History

| Version | Date | Changes | Type |
|---------|------|---------|------|
| 7.5.1 | 2024-12 | Security improvements, error handling | PATCH |
| 7.5.0 | 2024-11 | AI features, enhanced analytics | MINOR |
| 7.4.0 | 2024-10 | New export formats, UI improvements | MINOR |
| 7.3.0 | 2024-09 | Budget planning features | MINOR |
| 7.2.0 | 2024-08 | Multi-currency support | MINOR |
| 7.1.0 | 2024-07 | Enhanced charts and reports | MINOR |
| 7.0.0 | 2024-06 | Major redesign, new architecture | MAJOR |

## Automated Version Management

### Scripts

```bash
# Update version
./scripts/update_version.sh 7.5.2

# Generate changelog
./scripts/generate_changelog.sh

# Create release
./scripts/create_release.sh
```

### CI/CD Integration

- Automated version bumping
- Changelog generation
- Release tag creation
- App store deployment

## Best Practices

### 1. Version Communication

- Clear release notes
- User-friendly change descriptions
- Highlight breaking changes
- Provide migration guides

### 2. Database Migrations

- Always test migrations thoroughly
- Provide rollback procedures
- Document schema changes
- Version database schema separately

### 3. API Compatibility

- Maintain backward compatibility
- Use feature flags for gradual rollouts
- Deprecate features gracefully
- Provide migration paths

### 4. Testing

- Test all version changes
- Verify database migrations
- Test on multiple platforms
- Performance regression testing

## Tools and Resources

### Version Management Tools

- **pubspec.yaml**: Main version file
- **VERSIONING.md**: This documentation
- **CHANGELOG.md**: Release history
- **scripts/**: Version management scripts

### Useful Commands

```bash
# Check current version
flutter pub deps

# Update dependencies
flutter pub upgrade

# Build with specific version
flutter build apk --build-number=750001

# Generate version info
flutter pub run build_runner build
```

## Migration Guide

### For Developers

1. **Check Version Impact**
   - Review changes for breaking changes
   - Test database migrations
   - Verify API compatibility

2. **Update Version**
   - Modify `pubspec.yaml`
   - Update changelog
   - Create release notes

3. **Test Thoroughly**
   - Run all tests
   - Test on multiple devices
   - Verify user data integrity

### For Users

1. **Major Updates (X.0.0)**
   - Review breaking changes
   - Backup data before updating
   - Follow migration instructions

2. **Minor Updates (X.Y.0)**
   - New features available
   - Optional to update immediately
   - No data migration required

3. **Patch Updates (X.Y.Z)**
   - Bug fixes and security patches
   - Recommended to update promptly
   - No user action required

## Support

For questions about versioning:

- **Documentation**: This file and CHANGELOG.md
- **Issues**: GitHub issues for version-related problems
- **Discussions**: GitHub discussions for version planning

---

**Last Updated**: December 2024  
**Version**: 1.0 