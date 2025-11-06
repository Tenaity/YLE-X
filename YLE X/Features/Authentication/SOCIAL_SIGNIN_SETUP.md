# Social Sign-In Setup Guide

## Overview
This guide explains how to configure Google Sign-In and Apple Sign-In for the YLE X app.

## Files Added
- `AuthService.swift` - Updated with Google & Apple sign-in implementations
- `AuthViewModel.swift` - View model for authentication state management
- `GoogleSignInButton.swift` - Google Sign-In button UI component
- `AppleSignInButton.swift` - Apple Sign-In button UI component
- `SocialSignInView.swift` - Combined social sign-in view

## Google Sign-In Setup

### 1. Install GoogleSignIn SDK
The app already depends on Google Sign-In via Firebase. Ensure `GoogleSignIn` is linked in Podfile or SPM.

### 2. Configure Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select your project
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials:
   - Application type: iOS
   - Add iOS app with your Bundle Identifier
   - Download client ID configuration

### 3. Add GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to Xcode project
3. Ensure it's added to the target

### 4. Configure URL Schemes
In Xcode:
1. Select project → Target
2. Go to Info → URL Types
3. Add URL Scheme: `com.googleusercontent.apps.[YOUR_CLIENT_ID]`
4. Example: `com.googleusercontent.apps.123456789-abcdefg.apps.googleusercontent.com`

### 5. Update AppDelegate (if needed)
```swift
import GoogleSignIn

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

## Apple Sign-In Setup

### 1. Enable Sign in with Apple Capability
In Xcode:
1. Select project → Target
2. Go to Signing & Capabilities
3. Click "+ Capability"
4. Search for "Sign in with Apple"
5. Add it to your target

### 2. Configure Apple ID
1. Go to [Apple Developer](https://developer.apple.com/)
2. In your App ID settings, enable "Sign in with Apple"
3. Update your provisioning profile if needed
4. Regenerate certificates if necessary

### 3. Configure Service ID (for web domain association)
If your app needs to support Sign in with Apple on web:
1. Register a Service ID in Apple Developer
2. Configure domain associations
3. Configure return URLs

## Firebase Configuration

### 1. Update Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Authentication → Sign-in method
4. Enable Google sign-in provider
5. Add your OAuth 2.0 Web Client ID
6. Enable Apple as a sign-in provider

### 2. Update FirebaseAuth Rules
Ensure users are allowed to create accounts from social sign-in:
```
- Allow sign-in via Google
- Allow sign-in via Apple
- Auto-link accounts with same email address (optional)
```

## Implementation Details

### Google Sign-In Flow
```
1. User taps Google Sign-In button
2. GIDSignIn presents sign-in UI
3. Get ID Token and Access Token
4. Create Firebase credential
5. Sign in with Firebase
```

### Apple Sign-In Flow
```
1. User taps Apple Sign-In button
2. ASAuthorizationController presents authorization UI
3. Get Identity Token and Authorization Code
4. Create OAuth credential for Apple provider
5. Sign in with Firebase
6. Update user profile with name (if available)
```

## Usage in SwiftUI

### Using SocialSignInView
```swift
VStack {
    // Email/Password sign-in form here

    // Add social sign-in
    SocialSignInView()
}
```

### Using Individual Buttons
```swift
VStack(spacing: 16) {
    GoogleSignInButton {
        // Handle google sign-in
        await authViewModel.signInWithGoogle()
    }

    AppleSignInButton(
        onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        },
        onCompletion: { result in
            switch result {
            case .success(let credential):
                await authViewModel.signInWithApple(credential: credential)
            case .failure(let error):
                // Handle error
                break
            }
        }
    )
}
```

## Error Handling

Common errors and handling:
- `viewControllerNotFound` - Unable to present sign-in UI
- `googleTokenNotFound` - Failed to get Google token
- `appleTokenNotFound` - Failed to get Apple identity token
- Network errors - Check internet connection

## Testing

### Local Testing
1. Use physical device (simulator doesn't fully support some features)
2. Ensure internet connection
3. Check that App ID signing is correct

### Firebase Emulator
For development, you can use Firebase Local Emulator:
```bash
firebase emulators:start --only auth
```

## Security Considerations

1. **ID Token Validation**: Firebase automatically validates tokens
2. **HTTPS Only**: Ensure all communication uses HTTPS
3. **Keychain Storage**: Tokens are stored securely via Firebase SDK
4. **Token Refresh**: Firebase SDK handles token refresh automatically
5. **Account Linking**: Users can link multiple sign-in methods

## Troubleshooting

### Google Sign-In Not Working
- Verify GoogleService-Info.plist is in bundle
- Check URL Scheme is correctly added
- Verify OAuth 2.0 credentials are for iOS
- Check that Web Client ID is configured in Firebase

### Apple Sign-In Not Working
- Verify "Sign in with Apple" capability is enabled
- Check that App ID has Sign in with Apple capability
- Ensure provisioning profile is updated
- Verify Apple provider is enabled in Firebase

### Token Errors
- Check internet connection
- Verify credentials are valid
- Check that app is not in sandbox mode
- Ensure Bundle Identifier matches configuration

## Dependencies
- Firebase/Auth (via Firebase SDK)
- Google Sign-In SDK (via GoogleSignIn)
- AuthenticationServices (built-in iOS framework)
- CryptoKit (built-in iOS framework)

## References
- [Google Sign-In Documentation](https://developers.google.com/identity/sign-in/ios)
- [Apple Sign in with Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
