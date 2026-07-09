import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _SimpleDelegate();

  static final Map<String, Map<String, String>> _localized = {
    'fr': {
      'welcome': 'Bienvenue',
      'login': 'Connexion',
      'register': 'S\'inscrire',
      'phone_hint': 'Numéro (+228)',
      'password_hint': 'Mot de passe',
      'login_button': 'Se connecter',
      'create_account': 'Créer un compte',
      'account_pending': 'Compte en attente de validation',
      'login_failed': 'Échec de la connexion',
      'error_prefix': 'Erreur: ',
      'user_type_label': 'Type d\'utilisateur',
      'user_type_scholar': 'Boursier',
      'user_type_contractor': 'Contractuel',
      'verification_title': 'Vérification',
      'code_sent_message': 'Un code a été envoyé sur votre numéro',
      'code_hint': 'Entrez le code',
      'verify_button': 'Vérifier',
      'phone_verified': 'Numéro vérifié',
      'code_invalid': 'Code invalide',
    },
    'en': {
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'phone_hint': 'Phone (+228)',
      'password_hint': 'Password',
      'login_button': 'Login',
      'create_account': 'Create Account',
      'account_pending': 'Account pending validation',
      'login_failed': 'Login failed',
      'error_prefix': 'Error: ',
      'user_type_label': 'User Type',
      'user_type_scholar': 'Scholar',
      'user_type_contractor': 'Contractor',
      'verification_title': 'Verification',
      'code_sent_message': 'A code has been sent to your number',
      'code_hint': 'Enter code',
      'verify_button': 'Verify',
      'phone_verified': 'Phone verified',
      'code_invalid': 'Invalid code',
    },
    'ru': {
      'welcome': 'Добро пожаловать',
      'login': 'Вход',
      'register': 'Регистрация',
      'phone_hint': 'Телефон (+228)',
      'password_hint': 'Пароль',
      'login_button': 'Войти',
      'create_account': 'Создать аккаунт',
      'account_pending': 'Аккаунт ожидает подтверждения',
      'login_failed': 'Ошибка входа',
      'error_prefix': 'Ошибка: ',
      'user_type_label': 'Тип пользователя',
      'user_type_scholar': 'Стипендиат',
      'user_type_contractor': 'Контрактник',
      'verification_title': 'Подтверждение',
      'code_sent_message': 'Код отправлен на ваш номер',
      'code_hint': 'Введите код',
      'verify_button': 'Подтвердить',
      'phone_verified': 'Номер подтвержден',
      'code_invalid': 'Неверный код',
    },
  };

  String? _t(String key) => _localized[locale.languageCode]?[key];

  String get welcomeMessage => _t('welcome') ?? 'Welcome';
  String get login => _t('login') ?? 'Login';
  String get register => _t('register') ?? 'Register';
  String get phoneHint => _t('phone_hint') ?? 'Phone';
  String get passwordHint => _t('password_hint') ?? 'Password';
  String get loginButton => _t('login_button') ?? 'Login';
  String get createAccount => _t('create_account') ?? 'Create Account';
  String get accountPending =>
      _t('account_pending') ?? 'Account pending validation';
  String get loginFailed => _t('login_failed') ?? 'Login failed';
  String get errorPrefix => _t('error_prefix') ?? 'Error: ';
  String get userTypeLabel => _t('user_type_label') ?? 'User Type';
  String get userTypeScholar => _t('user_type_scholar') ?? 'Scholar';
  String get userTypeContractor => _t('user_type_contractor') ?? 'Contractor';
  String get verificationTitle => _t('verification_title') ?? 'Verification';
  String get codeSentMessage =>
      _t('code_sent_message') ?? 'A code has been sent to your number';
  String get codeHint => _t('code_hint') ?? 'Enter code';
  String get verifyButton => _t('verify_button') ?? 'Verify';
  String get phoneVerified => _t('phone_verified') ?? 'Phone verified';
  String get codeInvalid => _t('code_invalid') ?? 'Invalid code';

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class _SimpleDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _SimpleDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
