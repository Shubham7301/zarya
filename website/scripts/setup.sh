#!/bin/bash

# Zarya Appointment Booking Platform Setup Script

echo "🚀 Setting up Zarya Appointment Booking Platform..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first:"
    echo "   https://nodejs.org/"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Set up customer web app
echo "📱 Setting up customer web app..."
cd customer_web
flutter pub get
cd ..

# Set up merchant mobile app
echo "📱 Setting up merchant mobile app..."
cd merchant_mobile
flutter pub get
cd ..

# Set up Firebase functions
echo "🔥 Setting up Firebase functions..."
cd firebase/functions
npm install
cd ../..

echo "✅ Dependencies installed successfully!"

# Firebase setup instructions
echo ""
echo "🔧 Next steps:"
echo "1. Create a Firebase project at https://console.firebase.google.com"
echo "2. Enable Authentication (Email/Password)"
echo "3. Create Firestore database"
echo "4. Enable Cloud Messaging"
echo "5. Configure Firebase for your apps:"
echo ""
echo "   For Web (Customer):"
echo "   - Add a web app to your Firebase project"
echo "   - Copy the config and update customer_web/web/index.html"
echo "   - Update customer_web/lib/main.dart with your Firebase config"
echo ""
echo "   For Mobile (Merchant):"
echo "   - Add Android/iOS apps to your Firebase project"
echo "   - Download google-services.json (Android) or GoogleService-Info.plist (iOS)"
echo "   - Place files in merchant_mobile/android/app/ or merchant_mobile/ios/Runner/"
echo ""
echo "6. Deploy Firebase rules and functions:"
echo "   cd firebase"
echo "   firebase login"
echo "   firebase init (select your project)"
echo "   firebase deploy"
echo ""
echo "7. Build and deploy customer web app:"
echo "   cd customer_web"
echo "   flutter build web"
echo "   firebase deploy --only hosting"
echo ""
echo "8. Test the merchant mobile app:"
echo "   cd merchant_mobile"
echo "   flutter run"
echo ""
echo "🎉 Setup complete! Check the documentation in docs/ for detailed instructions."
