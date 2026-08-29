import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../../../../core/constants/app_colors.dart';
import '../../constants/ai_constants.dart';

class AiService {
  Future<Map<String, dynamic>?> generateMoodMap(
    String text,
    String? songTitle,
    String? songArtist,
  ) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: AiConstants.modelName,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
        systemInstruction: Content.system(AiConstants.systemInstruction),
      );

      final prompt =
          'Journal Entry: $text\nSong: ${songTitle ?? "No song"} by ${songArtist ?? "Unknown"}';
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        String cleanJson = response.text!;
        final startIndex = cleanJson.indexOf('{');
        final endIndex = cleanJson.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          cleanJson = cleanJson.substring(startIndex, endIndex + 1);
        }

        final data = jsonDecode(cleanJson);
        final num rawScore =
            data['spectrumScore'] ?? AiConstants.defaultSpectrumScore;
        final int score = rawScore.toInt();

        final double t = (score.clamp(0, 100)) / 100.0;
        final Color c1 = Color.lerp(
          AppColors.coreWisteria,
          AppColors.corePetal,
          t,
        )!;
        final Color c2 = Color.lerp(
          AppColors.corePetal,
          AppColors.coreMulberry,
          t,
        )!;
        final Color c3 = Color.lerp(
          AppColors.coreWisteria,
          AppColors.coreMulberry,
          t,
        )!;

        String toHex(Color c) =>
            '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

        return {
          'summary': data['summary'],
          'colors': [toHex(c1), toHex(c2), toHex(c3)],
        };
      }
      return null;
    } catch (e) {
      debugPrint('AI Service Error: $e');
      return null;
    }
  }
}
