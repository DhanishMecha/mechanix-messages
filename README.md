# Mechanix Messages

Mechanix Messages is a Flutter-based messaging application built for Mechanix OS using Flutter Elinux. It provides messaging experience with conversation management, message composition, and threaded message views.

## Install Guide

### Prerequisites

- [Flutter-Elinux SDK](https://github.com/flutter-elinux/flutter-elinux)
- [Dart SDK](https://dart.dev/get-dart)
- ObjectBox library

Install ObjectBox:

```bash
bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)
```

### Steps to Run the App

1. Clone the repository:

```bash
git clone https://github.com/mecha-org/mechanix-messages
cd mechanix-messages
```

2. Install dependencies:

```bash
flutter-elinux pub get
```

3. Run the application:

```bash
flutter-elinux run
```

## Testing

### Run Unit Tests

```bash
flutter-elinux test
```

### Run Integration Tests

```bash
flutter-elinux test integration_test/<test-file-name>
```

## Key Features

- View and manage SMS conversations.
- Send and receive text messages.
- Browse message threads.
- Search conversations and messages.
- Contact integration.
- Local message storage.
- Responsive user interface.
- Localization support.

## TODO

[ ] Integrate SMS SDK for sending and receiving messages.
