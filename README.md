# MoodMap

MoodMap is a Flutter-based daily journal and reflection app designed around personal routine, mood, and music.

## Overview

* A journal app for capturing daily thoughts, feelings, and moments.
* Entries are navigated through a calendar and day-by-day browsing, with the selected date and visible entry kept in sync.
* Music can be attached to an entry through an iTunes-powered search flow, bringing in artist, title, cover art, and short preview playback.
* Each entry can generate a mood map that blends the journal text and selected music into a poetic summary and a three-color gradient.

## Product direction

* The experience is intentionally calm, soft, and artistic, with Lottie motion and a polished light/dark theme.
* The app centers on a simple daily ritual: write, attach a song, reflect, and revisit the day later.
* Past entries are preserved as an archive, while the current day remains the place for new writing and updates.
* Music is previewed from public iTunes sources rather than stored locally as full audio files, keeping the experience lightweight and streaming-focused.

## Architecture

* Built in Flutter and Dart with a feature-first structure.
* Uses Provider for state management and Firebase for authentication and backend services.
* Stores journal content and metadata locally for offline viewing while keeping the music experience lightweight and stream-based.