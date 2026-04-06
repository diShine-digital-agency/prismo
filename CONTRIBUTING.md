# Contributing to Prismo

Thank you for your interest in contributing to Prismo. This document explains how to get involved.

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](https://github.com/diShine-digital-agency/prismo/issues) to report bugs or suggest improvements.
- Include your operating system, Prismo version (check the `VERSION` file), and steps to reproduce the problem.
- For prompt improvements, describe what the current output is and what you expected.

### Suggesting Features

- Open an issue with the label `enhancement`.
- Describe the use case: what problem does the feature solve for a consultant or tech advisor?
- If possible, include a draft of the prompt or script you have in mind.

### Submitting Changes

1. Fork the repository.
2. Create a branch from `main` (`git checkout -b feature/your-feature`).
3. Make your changes. Keep commits focused and descriptive.
4. Test your changes on at least one platform (Windows, macOS, or Linux).
5. Open a pull request against `main`.

### What We Look For

- **Prompt quality**: Prompts should produce structured, actionable reports. Avoid vague instructions. Every audit should include severity classification and specific remediation steps.
- **Cross-platform compatibility**: Launcher scripts must work on Windows (CMD and PowerShell), macOS, and Linux.
- **Language support**: New user-facing text should be added to all supported languages (Italian, English, French).
- **No marketing language**: Documentation and prompts should be direct and technical. Focus on what the tool does, not on selling it.
- **Zero-footprint principle**: Changes must not write to the host system's permanent storage. Everything stays on the USB drive or in temporary directories.

### Code Style

- **Shell scripts**: Use `shellcheck`-clean bash. Follow the patterns in `launch.sh`.
- **PowerShell**: Follow the conventions in `launch.ps1`. Use `$ErrorActionPreference = "Continue"` in launchers.
- **Markdown prompts**: Follow the structure of existing prompts in `toolkit/prompts/`. Include a checklist, severity table, execution protocol, and output format template.
- **Commit messages**: Use imperative mood. First line under 72 characters. Reference issue numbers when applicable.

## Project Structure

```
prismo/
├── launch.sh / launch.bat / launch.ps1   — Platform launchers
├── setup-usb.ps1                          — One-time USB preparation
├── prismo-eject.ps1                       — Safe USB eject (Windows)
├── prismo.config.json                     — Configuration
├── VERSION                                — Current version number
└── toolkit/
    ├── prompts/                           — AI diagnostic prompts
    │   ├── system/                        — OS health checks
    │   ├── web/                           — Web performance and tech
    │   ├── seo/                           — SEO audits
    │   ├── martech/                       — Marketing technology
    │   └── security/                      — Security scans
    ├── scripts/                           — Data collection scripts
    ├── clients/                           — Client profiles (JSON)
    ├── reports/                           — Generated reports
    └── logs/                              — Session logs
```

## Contact

For questions about contributing, reach out to kevin@dishine.it or open a discussion on the repository.

## License

By contributing to Prismo, you agree that your contributions will be licensed under the [MIT License](LICENSE).
