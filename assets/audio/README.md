# Audio Assets

This directory is for background music and sound effects.

## Required Audio Files (Optional)

To add background music and sound effects to your app, add the following files:

### Background Music
- `bgm_traditional.mp3` - Traditional Indonesian gamelan music or cultural background music

**Recommended Sources for Free Traditional Music:**
- https://freesound.org/ (search: "gamelan" or "traditional indonesia")
- https://freemusicarchive.org/
- YouTube Audio Library (search: "Traditional Asian")

### Sound Effects (Optional)
- `correct.mp3` - Sound when answer is correct
- `wrong.mp3` - Sound when answer is wrong
- `complete.mp3` - Sound when quiz is completed

## How to Add Audio

1. Download license-free audio files
2. Convert to MP3 format if needed
3. Place files in this directory
4. Uncomment the audio loading lines in `lib/services/audio_service.dart`

## Note

The app works without audio files - they are optional enhancements. The audio service is already implemented but commented out to prevent errors when files are missing.
