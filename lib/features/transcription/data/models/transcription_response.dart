class TranscriptionResponse {
  final String text;
  final GroqMetadata xGroq;

  TranscriptionResponse({
    required this.text,
    required this.xGroq,
  });

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      text: json['text'] as String,
      xGroq: GroqMetadata.fromJson(json['x_groq'] as Map<String, dynamic>),
    );
  }
}

class GroqMetadata {
  final String id;

  GroqMetadata({required this.id});

  factory GroqMetadata.fromJson(Map<String, dynamic> json) {
    return GroqMetadata(
      id: json['id'] as String,
    );
  }
}
