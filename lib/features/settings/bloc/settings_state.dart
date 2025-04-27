import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isApiKeyVisible;
  final String apiKey;
  final String? error;

  const SettingsState({
    this.isApiKeyVisible = false,
    this.apiKey = '',
    this.error,
  });

  SettingsState copyWith({
    bool? isApiKeyVisible,
    String? apiKey,
    String? error,
  }) {
    return SettingsState(
      isApiKeyVisible: isApiKeyVisible ?? this.isApiKeyVisible,
      apiKey: apiKey ?? this.apiKey,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isApiKeyVisible,
        apiKey,
        error,
      ];
}
