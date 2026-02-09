# Rise Flutter Exercise

This repository contains a live-coding exercise for Flutter developers.

## Overview

This is a simplified accounting application built with Flutter, designed to assess Flutter development skills, mobile app architecture understanding, API integration capabilities, and code quality practices.

## Purpose

This exercise is designed to assess:
- Flutter development skills
- Mobile app architecture understanding
- API integration capabilities
- Code quality and best practices
- UI/UX design decisions

## Getting Started

Please refer to `INSTRUCTIONS.md` for detailed setup instructions and task requirements.

## Repository Structure

```
rise-flutter-exercise/
├── .github/
│   └── workflows/
│       └── ci.yml          # CI/CD pipeline configuration
├── lib/
│   └── src/
│       ├── features/       # Feature modules (auth, sales)
│       └── globals/        # Shared utilities and services
├── test/
│   └── widget_test.dart    # Test files
├── analysis_options.yaml   # Dart analyzer configuration
├── pubspec.yaml            # Flutter project dependencies
├── README.md               # This file
└── INSTRUCTIONS.md         # Detailed exercise instructions
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

- Flutter SDK (latest stable version)
- Dart SDK
- IDE of your choice (VS Code, Android Studio, etc.)
- Git

## Exercise Tasks

The exercise consists of two main tasks:

1. **Task 1**: Implement the feature for creation of a new sales invoice
2. **Task 2**: Implement the feature for updating existing sales invoices

For detailed requirements and instructions, please see `INSTRUCTIONS.md`.
