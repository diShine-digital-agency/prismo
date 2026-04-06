# Security Policy

## Scope

Prismo is a portable consulting toolkit designed for on-site diagnostics. It is **not an enterprise security product** and is not intended for use in regulated environments (GDPR processing, HIPAA, PCI-DSS, ISO 27001 scoping).

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.1.x   | Yes       |
| < 1.1   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability in Prismo, please report it responsibly:

1. **Email**: Send a description to kevin@dishine.it with the subject line `[Prismo Security]`.
2. **Do not** open a public GitHub issue for security vulnerabilities.
3. Include:
   - A description of the vulnerability.
   - Steps to reproduce it.
   - The potential impact.
   - A suggested fix, if you have one.

We will acknowledge your report within 48 hours and aim to release a fix within 7 days for critical issues.

## Known Security Considerations

These are inherent to the tool's design and are documented for transparency:

- **Credentials on USB**: API keys and session tokens are stored on the USB drive in plaintext. Users should encrypt their USB drive (BitLocker, VeraCrypt, FileVault).
- **API data transit**: Diagnostic data is sent to Anthropic's API for processing. Do not use Prismo on systems containing classified or sensitive personal data.
- **Command execution**: The AI engine can propose and execute system commands. Users must review and approve every command before execution.
- **Checksum verification**: SHA256 checksums detect script tampering at launch, but this does not cover all files on the USB drive.

## Best Practices for Users

- Encrypt your USB drive.
- Use API keys with spending limits.
- Rotate credentials periodically.
- Review every proposed command before confirming.
- Use Prismo only on non-critical, non-regulated systems.
- If you lose the USB drive, revoke your API credentials immediately at [console.anthropic.com](https://console.anthropic.com).
