# Zarya - Appointment Booking Platform

A comprehensive appointment booking platform with customer web interface, merchant mobile app, and Firebase backend.

## Architecture

- **Customer Website**: Flutter Web - Browse services and book appointments
- **Merchant Mobile App**: Flutter Mobile - Manage bookings and services
- **Backend**: Firebase (Firestore, Auth, Cloud Functions, Cloud Messaging)

## Project Structure

```
zarya/
├── customer_web/          # Flutter Web app for customers
├── merchant_mobile/       # Flutter Mobile app for merchants
├── firebase/             # Firebase configuration and cloud functions
├── shared/               # Shared models and utilities
└── docs/                 # Documentation and setup guides
```

## Setup Instructions

1. Follow the Firebase setup guide in `docs/firebase-setup.md`
2. Configure each Flutter app according to their respective README files
3. Deploy Firebase Cloud Functions for backend logic

## Features

### Customer Website
- Browse available services and merchants
- Book appointments with or without login
- Receive booking confirmations and reminders
- Responsive web design

### Merchant Mobile App
- Secure login with admin-provided credentials
- View and manage daily bookings
- Approve, reschedule, or cancel appointments
- Manage available time slots and services

### Super Admin Panel
- Manage merchant accounts
- Platform-wide oversight (future phase)

## Tech Stack

- **Frontend**: Flutter (Web & Mobile)
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Notifications**: Firebase Cloud Messaging
- **Functions**: Firebase Cloud Functions
- **Hosting**: Firebase Hosting
