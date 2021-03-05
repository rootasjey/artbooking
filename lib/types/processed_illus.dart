class ProcessedIllustration {
  final String illustrationId;
  final bool success;

  ProcessedIllustration({
    this.illustrationId = '',
    this.success = false,
  });

  factory ProcessedIllustration.fromJSON(Map<String, dynamic> data) {
    return ProcessedIllustration(
      illustrationId: data['illustrationId'] ?? '',
      success: data['success'] ?? false,
    );
  }
}
