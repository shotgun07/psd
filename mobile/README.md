# OBLNS - Advanced Logistics Platform

A comprehensive Flutter application for logistics and delivery services in the Middle East, featuring AI-powered chatbots, AR navigation, blockchain payments, IoT integration, and machine learning analytics.

## 🚀 Features

### Core Features
- **User Authentication**: Firebase Auth with enhanced login screens
- **Real-time Tracking**: GPS-based trip tracking with maps integration
- **Payment System**: Secure payments with wallet functionality
- **Driver Management**: Comprehensive driver onboarding and management
- **Order Management**: Full order lifecycle from booking to delivery

### Advanced Features
- **AI Chatbot**: OpenAI-powered customer support with Arabic language support
- **AR Navigation**: Augmented reality navigation for drivers (Android/iOS)
- **Blockchain Payments**: Ethereum-based secure transactions with smart contracts
- **IoT Integration**: Real-time sensor monitoring and vehicle control
- **Machine Learning**: Demand prediction, route optimization, and driver behavior analysis
- **Wearable Support**: Smartwatch integration for driver monitoring
- **Government API Integration**: License verification and compliance
- **Offline Sync**: Seamless offline functionality with automatic sync
- **Sustainability Tracking**: Carbon footprint calculation and eco-friendly routing

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Appwrite (Functions, Database, Storage)
- **Authentication**: Firebase Auth
- **Database**: Appwrite Database + Firestore
- **Maps**: Flutter Map + Google Maps
- **AI/ML**: OpenAI API, ML Algorithms
- **Blockchain**: Web3Dart, Ethereum
- **IoT**: MQTT Protocol
- **AR**: ARCore (Android), ARKit (iOS)
- **State Management**: Riverpod
- **Local Storage**: Hive

## 📋 Prerequisites

- Flutter SDK (>=3.8.0)
- Dart SDK (>=3.8.0)
- Android Studio / Xcode
- Firebase project
- Appwrite instance
- OpenAI API key
- Government API access (for Libya)

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/oblns.git
   cd oblns/mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   - Copy `.env.example` to `.env`
   - Fill in your API keys and configuration

4. **Firebase Setup**
   - Add `google-services.json` to `android/app/`
   - Configure Firebase project

5. **Appwrite Setup**
   - Configure Appwrite instance
   - Set up functions and database

## 🚀 Running the App

```bash
flutter run
```

## 🧪 Testing

```bash
flutter test
```

## 📱 Build & Release

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Environment Variables

Create a `.env` file with:

```env
APPWRITE_ENDPOINT=https://your-appwrite-instance.com/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_DATABASE_ID=oblns
FIREBASE_API_KEY=your-firebase-key
OPENAI_API_KEY=your-openai-key
GOV_API_KEY=your-government-api-key
```

## 📊 Architecture

The app follows Clean Architecture principles with:
- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and entities
- **Infrastructure Layer**: External services and data sources
- **Core Layer**: Shared utilities and services

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support, email support@oblns.com or join our Discord community.

## 🌟 Roadmap

- [x] Basic logistics platform
- [x] AI chatbot integration
- [x] AR navigation
- [x] Blockchain payments
- [x] IoT dashboard
- [x] ML analytics
- [x] Wearable support
- [x] Government API integration
- [x] Offline sync
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Integration with delivery drones
- [ ] Predictive maintenance
