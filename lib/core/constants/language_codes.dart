import 'package:equatable/equatable.dart';

class LanguageCode extends Equatable {
  final String name;
  final String code;

  const LanguageCode({required this.name, required this.code});

  @override
  List<Object?> get props => [name, code];
}

const List<LanguageCode> languageCodes = [
  LanguageCode(name: 'Auto-detect', code: ''),
  LanguageCode(name: 'English', code: 'en'),
  LanguageCode(name: 'Spanish', code: 'es'),
  LanguageCode(name: 'French', code: 'fr'),
  LanguageCode(name: 'German', code: 'de'),
  LanguageCode(name: 'Italian', code: 'it'),
  LanguageCode(name: 'Portuguese', code: 'pt'),
  LanguageCode(name: 'Russian', code: 'ru'),
  LanguageCode(name: 'Japanese', code: 'ja'),
  LanguageCode(name: 'Korean', code: 'ko'),
  LanguageCode(name: 'Chinese', code: 'zh'),
  LanguageCode(name: 'Arabic', code: 'ar'),
  LanguageCode(name: 'Hindi', code: 'hi'),
  LanguageCode(name: 'Turkish', code: 'tr'),
  LanguageCode(name: 'Dutch', code: 'nl'),
  LanguageCode(name: 'Polish', code: 'pl'),
  LanguageCode(name: 'Vietnamese', code: 'vi'),
  LanguageCode(name: 'Thai', code: 'th'),
  LanguageCode(name: 'Swedish', code: 'sv'),
  LanguageCode(name: 'Danish', code: 'da'),
  LanguageCode(name: 'Finnish', code: 'fi'),
];
