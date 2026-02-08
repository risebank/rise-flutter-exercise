# Rise Flutter Exercise

This repository contains a live-coding exercise for candidates applying to lead the development of the `rise-mobile-app`.

## Overview

The `rise-mobile-app` is a mobile application built with Flutter, designed for release on iOS and Android. The app consumes APIs from the `rise` monorepository backend.

## Purpose

This exercise is designed to assess:
- Flutter development skills
- Mobile app architecture understanding
- API integration capabilities
- Code quality and best practices

## Getting Started

Instructions for the exercise will be provided during the live-coding session.

## Repository Structure

```
rise-flutter-exercise/
├── .github/
│   └── workflows/
│       └── ci.yml          # CI/CD pipeline configuration
├── test/
│   └── widget_test.dart    # Test files
├── analysis_options.yaml   # Dart analyzer configuration
├── pubspec.yaml            # Flutter project dependencies
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

- Flutter SDK (latest stable version)
- Dart SDK
- iOS development tools (for iOS builds)
- Android development tools (for Android builds)
