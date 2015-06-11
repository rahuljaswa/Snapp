## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

   - Apple Developer Website
      - Create App ID (with Push Notifications and In-App Purchase enabled)
      - Create APN certificates for development and production
      - Create Ad Hoc and App Store provisioning profiles (development profile should be created automatically by Xcode)

   - Assets (https://github.com/rahuljaswa/community-assets)
      - Create App Icon and export all sizes using Icon Template
      - Create App Screenshots and export all sizes using Screenshot Template

   - Xcode
      - Go to preferences and sync the latest provisioning profiles
      - Setup bundle identifier to match the bundle identifier from Apple Developer Website
      - Setup podfile to depend on Community pod
      - Set deployment target to 7.0
      - Eliminate all remnants of storyboarding and IB files:
         - In project, use asset catalog as launch image source
         - Delete Main.storyboard and LaunchScreen.xib files
         - Delete `Launch screen interface file base name` row from .plist file
         - Delete `Main storyboard file base name` row from .plist file
      - Add launch images for all required sizes
      - Set `View controller-based status bar appearance` to `NO` in .plist file
      - Updated supported interface orientation to only Portrait
      - Add icons for all required sizes
      - Delete default AppDelegate class
      - Create subclass of RJAppDelegate and override `customizeStyleManager:` with all template styling
      - Update main.m to rely on RJAppDelegate subclass

   - Parse
      - Add categories for app with appropriate appIdentifier

## App Store Submission

To get through App Store review process, you must explain why you require phone number based authentication. Here is an explanation that seems to succeed:

> Phone number based authentication is used to protect against 
> spam and ensure user uniqueness. We've found that phone number 
> verification is the safest way that we can protect people's 
> data, prevent bots and fake accounts (because we perform two-
> factor authentication via SMS), and guarantee uniqueness. We 
> are also launching in international geographies where many 
> people do not have e-mail addresses. We have historically found 
> people very resistant to social authentication mechanisms like 
> Facebook due to data privacy concerns.

## Requirements

iOS 7.0 or greater

## Installation

Community is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

    pod "Community"

## Author

Rahul Jaswa, rahul.jaswa@gmail.com

## License

Community is available under the COMMERCIAL license. See the LICENSE file for more info.

