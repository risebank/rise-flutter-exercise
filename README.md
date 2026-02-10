# Rise Flutter Exercise

This repository contains a live-coding exercise for Flutter developers, typically completed in a **1-hour session** with AI coding assistance (e.g. Cursor, Claude, Copilot, etc.).

## Overview

This is a simplified accounting application built with Flutter. The exercise assesses your ability to interpret an assignment, make implementation decisions, and deliver working code within the session.

## Purpose

This exercise is designed to assess:
- **Interpretation**: Understanding requirements and following existing patterns
- **Flutter skills**: State management, API integration, UI implementation
- **Architecture**: Fitting new features into the existing structure
- **Code quality**: Formatting, analysis, tests
- **UI/UX design decisions**: Apply your own knowledge and preferred approach while implementing both tasks and explain your rationale for the team's understanding
- **Collaboration with AI**: Effective use of AI tools to enhance the implementation process

AI coding tools are encouraged. The focus is on your ability to guide the implementation and make correct technical choices.

## Getting Started

Please refer to `INSTRUCTIONS.md` for detailed setup instructions and task requirements.

## Repository Structure

```
rise-flutter-exercise/
├── .github/workflows/ci.yml
├── docs/
│   └── API_REFERENCE.md    # API contract details
├── lib/src/
│   ├── features/           # auth, sales
│   └── globals/            # ApiClient, theme, etc.
├── test/
├── android/                # Android platform
├── ios/                    # iOS platform
├── web/                    # Web platform
├── .fvmrc                  # Flutter version (optional FVM)
├── INSTRUCTIONS.md         # Exercise instructions
└── README.md
```

## CI/CD Pipeline

This repository includes a CI/CD pipeline that runs automatically on:
- Pull requests targeting `main` or `develop` branches
- Pushes to `main` or `develop` branches
- Merge groups

The pipeline checks:
- **Code Quality**: Runs `flutter analyze` to check for errors and warnings
- **Code Formatting**: Verifies code follows Dart formatting standards
- **Tests**: Runs all tests in the `test/` directory

All checks must pass before a PR can be merged.

## Requirements

- **Flutter SDK**: 3.24+ (stable) — recommended: use [FVM](https://fvm.app/) with project `.fvmrc` (Flutter 3.38.3)
- **Dart SDK**: 3.5+ (bundled with Flutter)
- IDE: Cursor, VS Code, Android Studio, etc.
- Git

**Platforms:** Web (Chrome), Android, iOS — desktop is not supported.

## Exercise Tasks

The exercise consists of two main tasks:

1. **Task 1**: Implement the feature for creation of a new sales invoice
2. **Task 2**: Implement the feature for updating existing sales invoices

For detailed requirements and instructions, please see `INSTRUCTIONS.md`.
