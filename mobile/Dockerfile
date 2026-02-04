# Dockerfile for Flutter app build
FROM cirrusci/flutter:stable

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build apk --release

# For web build
RUN flutter build web