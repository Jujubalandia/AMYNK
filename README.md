oi# AMYNK - Everything you need to know about your medicine

## About

This is a mobile application that helps blind people or who cannot read due to some disability to recognize the medicine they need to take using their voices, celular camera and artificial intelligence.

## Author

- [@jujubalandia](https://www.github.com/jujubalandia)

## Inspiration

### [medgrandma-ai](https://github.com/laysaalves/medgrandma-ai)

By

- [@Layseiras](https://github.com/laysaalves)

## Why

Think in people with visual disabilities or blind, or illiterate in their native language or in the language of medicine packing. How this people have sure about with drug needed to take.

## Solution

An application capable to recognizes speech to text and image recognition and processing to allow people to know about name, details, dosage and more information about the drug usability. This is an application with an advanced Voice UI Interface to allow people to interact with this application with only voice, not buttons, text and neither visual components to interact via touch.

## How it works

## Features

- Multi lingual voice interface
- Text to Speech
- Voice recognition
- Image Recognition
- Medicine name, dosage, contraindication, medical recommendations
- Reads box, medicine bottle and pill pack


## Demo

[![IAmynk Demo](https://img.youtube.com/vi/TlWp9PKqS0w/0.jpg)](https://www.youtube.com/watch?v=TlWp9PKqS0w)

## Tech Stack

- Flutter 
- Dart 
- Google Gemini API

Libraries

- speech_to_text: ^6.6.2
- permission_handler: ^10.2.0
- camera: ^0.11.0+2
- flutter_tts: ^3.8.5 
- google_generative_ai: ^0.4.4
- logger: ^2.4.0
- flutter_native_splash: ^2.4.1
- flutter_local_notifications: ^17.2.2
- intl: ^0.19.0
- timezone: ^0.9.4
 

## Installation

Firstly, you will need to have Flutter and Dart installed on your machine to build the app. You can find installation instructions for Flutter and Dart on the Flutter website. Follow the instructions below for each platform

#### ANDROID

1. Clone the repository
```
git clone https://github.com/jujubalandia/amynk.git
```
2. Install the dependencies
```
cd amynk
flutter pub get
```
3. Connect an Android device or start an Android emulator
```
flutter devices
```
4. Build the app
```
flutter build apk
```
5. Install the app on the device or emulator
```
flutter install
```

#### IOS

1. Clone the repository
```
git clone https://github.com/jujubalandia/amynk.git
```
2. Install the dependencies
```
cd amynk
flutter pub get
```
3. Connect an Android device or start an IOS emulator
```
flutter devices
```
4. Build the app
```
flutter build ios
```
5. Install the app on the device or emulator
```
flutter install
```

## Roadmap

- Multi lingual enabled 
- Auto detect language end to end of the user interaction (phone, objects, etc)
- Being able to schedule times to take medicine
- Being able to remember when the user need to take the medicine
- Apple Play Store
- Google Play Store



