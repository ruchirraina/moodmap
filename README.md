# MoodMap

A cross-platform journal app built with Flutter and Dart, focused on logging entries, attaching music, and generating AI mood maps.

## Architecture
* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Backend & Auth:** Firebase (Google Auth, Email/Password)
* **Local Storage:** On-device storage for offline viewing

## Core Features
* **Authentication:** Secure sign-up, sign-in, and password reset flows with inline validations and dynamic focus handling.
* **Interactive Calendar:** Navigate past journal entries through a split-layout UI using swipe gestures. Past entries are strictly read-only.
* **Music Integration:** Search and attach songs to daily entries. Streams a 30-second audio preview with high-resolution cover art while online. Audio fades smoothly across date changes.
* **AI Mood Mapping:** An AI persona, "The Whimsical Sage," generates a poetic summary and a custom three-color hex gradient based on the entry's text and music. This requires a network connection and is strictly limited to one generation per day per entry.
* **Offline Mode:** Journal text and song metadata are stored locally, allowing full read-only access to past entries without an internet connection.
* **Custom Theme:** Dynamic light and dark modes utilizing a custom color palette and typography.