# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 7.5.x   | :white_check_mark: |
| 7.4.x   | :white_check_mark: |
| 7.3.x   | :x:                |
| < 7.3   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please follow these steps:

### 1. **DO NOT** create a public GitHub issue
Security vulnerabilities should be reported privately to prevent exploitation.

### 2. Email the security team
Send an email to: `security@intellicash.app`

Include the following information:
- **Type of issue** (buffer overflow, SQL injection, cross-site scripting, etc.)
- **Full paths** of source file(s) related to the vulnerability
- **The impact** of the issue, including remote code execution, data breach, etc.
- **Proof-of-concept** or steps to reproduce the issue
- **Suggested fix** (if any)

### 3. What happens next?
- You'll receive an acknowledgment within 48 hours
- We'll investigate and provide updates
- Once fixed, we'll credit you in the security advisory (unless you prefer to remain anonymous)

## Security Best Practices

### For Contributors

1. **Never commit sensitive data**
   - API keys, passwords, tokens
   - Keystore files (`.jks`, `.keystore`)
   - Environment files (`.env`)
   - Firebase configuration files

2. **Use environment variables**
   ```dart
   // ✅ Good
   final apiKey = const String.fromEnvironment('API_KEY');
   
   // ❌ Bad
   final apiKey = 'AIzaSyCRZPKNr0sJTF9DyWpZPO87IfaWeitzd0s';
   ```

3. **Validate all inputs**
   - Sanitize user inputs
   - Use parameterized queries
   - Implement proper authentication

4. **Follow secure coding practices**
   - Use HTTPS for all network requests
   - Implement proper error handling
   - Log security events appropriately

### For Users

1. **Keep the app updated**
   - Install the latest version
   - Enable automatic updates

2. **Use strong authentication**
   - Enable biometric authentication
   - Use strong passwords
   - Enable two-factor authentication if available

3. **Be cautious with data**
   - Don't share sensitive financial data
   - Use the app on trusted devices only
   - Log out when using shared devices

## Security Features

### Data Protection
- **Local encryption**: All sensitive data is encrypted locally
- **Secure transmission**: All network communication uses TLS/SSL
- **No cloud storage**: Financial data stays on your device

### Authentication
- **Biometric support**: Fingerprint and face recognition
- **PIN protection**: Custom PIN for app access
- **Session management**: Automatic logout after inactivity

### Privacy
- **No tracking**: We don't collect personal data
- **Local-first**: Data processing happens on your device
- **Transparent**: Open source code for verification

## Security Updates

We regularly update the app to address security vulnerabilities:

- **Monthly security patches**
- **Critical fixes within 24 hours**
- **Automatic vulnerability scanning**
- **Third-party dependency updates**

## Compliance

IntelliCash follows security best practices and industry standards:

- **OWASP Mobile Security Guidelines**
- **Flutter Security Best Practices**
- **Google Cloud Security Standards**
- **GDPR Compliance** (EU data protection)

## Contact

For security-related questions or concerns:
- **Email**: security@intellicash.app
- **PGP Key**: [Available upon request]
- **Response Time**: Within 48 hours

---

**Last Updated**: December 2024
**Version**: 1.0 