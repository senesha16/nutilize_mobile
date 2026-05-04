import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ReportTarget {
  final int? roomId;
  final int? itemId;
  final String label;
  final String type;

  const ReportTarget({
    required this.label,
    required this.type,
    this.roomId,
    this.itemId,
  });

  bool get isRoom => roomId != null;
  bool get isItem => itemId != null;
}

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _buildLegacyReportInfo({
    required String description,
    required int targetCount,
    required int imageCount,
    int? reservationId,
  }) {
    final safeDescription = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    final shortDescription = safeDescription.length > 120
        ? '${safeDescription.substring(0, 120)}...'
        : safeDescription;

    final text =
        'desc=$shortDescription | targets=$targetCount | images=$imageCount | reservation=${reservationId ?? 'none'}';

    if (text.length <= 255) {
      return text;
    }
    return text.substring(0, 255);
  }

  Future<void> submitReports({
    required int userId,
    required List<ReportTarget> targets,
    required String description,
    required List<String> proofImagePaths,
    required List<File> imageFiles,
    int? reservationId,
  }) async {
    if (targets.isEmpty) {
      throw Exception('Please select at least one target to report.');
    }
    if (proofImagePaths.isEmpty || imageFiles.isEmpty) {
      throw Exception('Please upload at least one proof photo.');
    }

    final now = DateTime.now().toIso8601String();

    // Upload images to Supabase and get public URLs
    final uploadedImageUrls = <String>[];
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final url = await _uploadImageToSupabase(
          imageFile: imageFiles[i],
          index: i,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        uploadedImageUrls.add(url);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ReportService] Failed to upload image $i: $e');
        }
        throw Exception('Failed to upload image ${i + 1}: $e');
      }
    }

    final primaryProofImage = uploadedImageUrls.first;

    final payload = jsonEncode({
      'description': description,
      'proof_image_url': primaryProofImage,
      'proof_image_urls': uploadedImageUrls,
      'reservation_id': reservationId,
      'submitted_at': now,
      'target_count': targets.length,
    });

    final legacyReportInfo = _buildLegacyReportInfo(
      description: description,
      targetCount: targets.length,
      imageCount: uploadedImageUrls.length,
      reservationId: reservationId,
    );

    final parent = await _supabase
        .from('reports')
        .insert({
          'user_id': userId,
          'reservation_id': reservationId,
          'description': description,
          'proof_image_url': primaryProofImage,
          'status': 'pending',
          // Keep for backward compatibility with existing NOT NULL schema.
          'report_info': legacyReportInfo,
          'generated_at': now,
          'created_at': now,
          'updated_at': now,
        })
        .select('report_id')
        .single();

    final reportId = parent['report_id'] as int;

    final targetRows = targets.map((target) {
      final targetType = target.isRoom
          ? 'room'
          : (target.isItem ? 'item' : 'unknown');

      if (targetType == 'unknown') {
        throw Exception('Invalid report target selection.');
      }

      return {
        'report_id': reportId,
        'target_type': targetType,
        'room_id': target.roomId,
        'item_id': target.itemId,
      };
    }).toList();

    try {
      await _supabase.from('report_targets').insert(targetRows);
    } catch (e) {
      // Best-effort rollback to avoid orphaned parent reports.
      await _supabase.from('reports').delete().eq('report_id', reportId);
      rethrow;
    }
  }

  Future<String> _uploadImageToSupabase({
    required File imageFile,
    required int index,
    required int timestamp,
  }) async {
    try {
      // Generate a unique filename
      final filename = 'report_${timestamp}_$index.jpg';

      // Upload file to 'assets' bucket
      await _supabase.storage.from('assets').upload(
        'issues/$filename',
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Get public URL for the uploaded file
      final publicUrl = _supabase.storage.from('assets').getPublicUrl('issues/$filename');

      if (kDebugMode) {
        debugPrint('[ReportService] Uploaded image: $publicUrl');
      }

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReportService] Upload error: $e');
      }
      rethrow;
    }
  }
}