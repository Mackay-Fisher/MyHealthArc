# myHealthArc

## Repository Overview

This repository contains the source code for the myHealthArc application, which is designed to help users monitor and manage their health data as an all in one iOS app. The repository is divided into two main parts:
- `myHealthArc`: The backend server-side code.
- `myHealthArc-new-frontend`: The frontend iOS application.

## App Functionalities

### Backend (myHealthArc)
- **User Management**: Handles user registration, authentication, and profile management.
- **Health Data Integration**: Integrates with Apple HealthKit to fetch and store health data such as vital metrics, fitness data, and nutrition information.
- **Nutrition Management**: Allows users to log and track their meals, providing detailed nutritional information such as macros.
- **Medication Management**: Enables users to manage their medications and check for potential interactions between them.
- **Fitness Goals and Streaks**: Users can set fitness goals and track their progress over time.
- **Recipe Management**: Users can save and manage their favorite recipes that were generated.

### Frontend (myHealthArc-new-frontend)
- **User Interface**: Provides a user-friendly interface for interacting with the app's functionalities.
- **Health Data Visualization**: Displays health data in an easy-to-understand format, including graphs and charts.
- **Streaks**: Provides icons for each goal representing daily streaks.
- **Widgets**: Includes modular widgets for quick access to important health information.

## Technical Aspects

### Backend
- **Framework**: Built using the Vapor framework for Swift.
- **Database**: Uses MongoDB for data storage.
- **APIs**: Integrates with external APIs for fetching health data, checking medication interactions, and validating nutrition information.
- **Authentication**: Implements secure authentication and requests using Swift Keychain Wrapper and HTTPS requests.

### Frontend
- **Language**: Written in Swift using SwiftUI for the user interface.
- **HealthKit**: Integrates with Apple HealthKit to fetch and display health data.
- **Networking**: Uses URLSession for network requests to the backend server.
- **State Management**: Utilizes SwiftUI's state management features for handling app state.

## Getting Started

### Prerequisites
- Xcode 15.2 or later
- Swift 5.0 or later

### Installation

1. Clone the repository:
    ```
    git clone https://github.com/yourusername/myHealthArc.git
    ```

2. Navigate to the backend directory and install dependencies:
    ```
    cd myHealthArc
    swift build
    ```

3. Navigate to the frontend directory and open the Xcode project:
    ```
    cd ../myHealthArc-new-frontend
    open myHealthArc-new-frontend.xcodeproj
    ```

4. Build and run the project in Xcode. The project will be displayed in Xcode's Built-in Simulator.