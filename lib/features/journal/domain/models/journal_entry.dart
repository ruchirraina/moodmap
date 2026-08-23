import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/journal_constants.dart';

class JournalEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String? title;
  final String body;
  final String? songTitle;
  final String? songArtist;
  final String? songCoverUrl;
  final String? songPreviewUrl;
  final String? aiSummary;
  final List<String>? aiColors;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.title,
    required this.body,
    this.songTitle,
    this.songArtist,
    this.songCoverUrl,
    this.songPreviewUrl,
    this.aiSummary,
    this.aiColors,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data[JournalConstants.fieldUserId] as String? ?? '',
      date: (data[JournalConstants.fieldDate] as Timestamp).toDate(),
      title: data[JournalConstants.fieldTitle] as String?,
      body: data[JournalConstants.fieldBody] as String? ?? '',
      songTitle: data[JournalConstants.fieldSongTitle] as String?,
      songArtist: data[JournalConstants.fieldSongArtist] as String?,
      songCoverUrl: data[JournalConstants.fieldSongCoverUrl] as String?,
      songPreviewUrl: data[JournalConstants.fieldSongPreviewUrl] as String?,
      aiSummary: data[JournalConstants.fieldAiSummary] as String?,
      aiColors: (data[JournalConstants.fieldAiColors] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: (data[JournalConstants.fieldCreatedAt] as Timestamp).toDate(),
      updatedAt: (data[JournalConstants.fieldUpdatedAt] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      JournalConstants.fieldUserId: userId,
      JournalConstants.fieldDate: Timestamp.fromDate(date),
      JournalConstants.fieldTitle: title,
      JournalConstants.fieldBody: body,
      JournalConstants.fieldSongTitle: songTitle,
      JournalConstants.fieldSongArtist: songArtist,
      JournalConstants.fieldSongCoverUrl: songCoverUrl,
      JournalConstants.fieldSongPreviewUrl: songPreviewUrl,
      JournalConstants.fieldAiSummary: aiSummary,
      JournalConstants.fieldAiColors: aiColors,
      JournalConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      JournalConstants.fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }
}
