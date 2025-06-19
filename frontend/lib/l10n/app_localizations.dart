import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood Diary'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @start2.
  ///
  /// In en, this message translates to:
  /// **'Record your emotional state and get helpful tips to feel better.'**
  String get start2;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @settingTitle.
  ///
  /// In en, this message translates to:
  /// **'My Setting'**
  String get settingTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @logoutYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get logoutYes;

  /// No description provided for @logoutNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get logoutNo;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @formatMyDiary.
  ///
  /// In en, this message translates to:
  /// **'Format My Diary'**
  String get formatMyDiary;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get getHelp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security and Privacy'**
  String get security;

  /// No description provided for @languageChange.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageChange;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @emailbox1.
  ///
  /// In en, this message translates to:
  /// **'Your email is verified'**
  String get emailbox1;

  /// No description provided for @emailbox2.
  ///
  /// In en, this message translates to:
  /// **'Change Your Password'**
  String get emailbox2;

  /// No description provided for @faqbox1.
  ///
  /// In en, this message translates to:
  /// **'How to change my Password?'**
  String get faqbox1;

  /// No description provided for @faqbox2.
  ///
  /// In en, this message translates to:
  /// **'How to stop notifications to my email?'**
  String get faqbox2;

  /// No description provided for @faqbox3.
  ///
  /// In en, this message translates to:
  /// **'How to format my diary?'**
  String get faqbox3;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @chatbot1.
  ///
  /// In en, this message translates to:
  /// **'ChatBot Emoa'**
  String get chatbot1;

  /// No description provided for @chatbot2.
  ///
  /// In en, this message translates to:
  /// **'You can ask me anything'**
  String get chatbot2;

  /// No description provided for @inputbox.
  ///
  /// In en, this message translates to:
  /// **'Input Your message...'**
  String get inputbox;

  /// No description provided for @suggested1.
  ///
  /// In en, this message translates to:
  /// **'How did you feel today?'**
  String get suggested1;

  /// No description provided for @suggested2.
  ///
  /// In en, this message translates to:
  /// **'Can you recommend an activity that might improve my mood?'**
  String get suggested2;

  /// No description provided for @suggested3.
  ///
  /// In en, this message translates to:
  /// **'How do you think I\'m feeling today?'**
  String get suggested3;

  /// No description provided for @suggested4.
  ///
  /// In en, this message translates to:
  /// **'Can you say something comforting to me?'**
  String get suggested4;

  /// No description provided for @diarytitle.
  ///
  /// In en, this message translates to:
  /// **'My Diary'**
  String get diarytitle;

  /// No description provided for @diary1.
  ///
  /// In en, this message translates to:
  /// **'Today Diary'**
  String get diary1;

  /// No description provided for @diary2.
  ///
  /// In en, this message translates to:
  /// **'There is no diary entry'**
  String get diary2;

  /// No description provided for @diary3.
  ///
  /// In en, this message translates to:
  /// **'How to improve your mood'**
  String get diary3;

  /// No description provided for @diary4.
  ///
  /// In en, this message translates to:
  /// **'There are no activities. Please add some.'**
  String get diary4;

  /// No description provided for @diary5.
  ///
  /// In en, this message translates to:
  /// **'Enter an activity to add.'**
  String get diary5;

  /// No description provided for @diary6.
  ///
  /// In en, this message translates to:
  /// **'+ add'**
  String get diary6;

  /// No description provided for @diary7.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 items only.'**
  String get diary7;

  /// No description provided for @diary8.
  ///
  /// In en, this message translates to:
  /// **'This activity already exists.'**
  String get diary8;

  /// No description provided for @writescreen1.
  ///
  /// In en, this message translates to:
  /// **'Hello, '**
  String get writescreen1;

  /// No description provided for @writescreen2.
  ///
  /// In en, this message translates to:
  /// **'Edit or write for the selected date.'**
  String get writescreen2;

  /// No description provided for @writescreen3.
  ///
  /// In en, this message translates to:
  /// **'Describe your mood.'**
  String get writescreen3;

  /// No description provided for @writescreen4.
  ///
  /// In en, this message translates to:
  /// **'Enter a message.'**
  String get writescreen4;

  /// No description provided for @edit1.
  ///
  /// In en, this message translates to:
  /// **'Edit Diary'**
  String get edit1;

  /// No description provided for @edit2.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get edit2;

  /// No description provided for @edit3.
  ///
  /// In en, this message translates to:
  /// **'Cancle'**
  String get edit3;

  /// No description provided for @login1.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login1;

  /// No description provided for @login2.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login2;

  /// No description provided for @login3.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login3;

  /// No description provided for @login4.
  ///
  /// In en, this message translates to:
  /// **'Forget password?'**
  String get login4;

  /// No description provided for @login5.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have any account?'**
  String get login5;

  /// No description provided for @login6.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get login6;

  /// No description provided for @logininfo1.
  ///
  /// In en, this message translates to:
  /// **'Please enter both your email and password.'**
  String get logininfo1;

  /// No description provided for @loginmain.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get loginmain;

  /// No description provided for @logininfo2.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get logininfo2;

  /// No description provided for @logoutmsg.
  ///
  /// In en, this message translates to:
  /// **'Logout Success'**
  String get logoutmsg;

  /// No description provided for @write1.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get write1;

  /// No description provided for @write2.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get write2;

  /// No description provided for @write3.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get write3;

  /// No description provided for @write4.
  ///
  /// In en, this message translates to:
  /// **'Please enter your text.'**
  String get write4;

  /// No description provided for @cheerful.
  ///
  /// In en, this message translates to:
  /// **'cheerful'**
  String get cheerful;

  /// No description provided for @relaxed.
  ///
  /// In en, this message translates to:
  /// **'relaxed'**
  String get relaxed;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'neutral'**
  String get neutral;

  /// No description provided for @confident.
  ///
  /// In en, this message translates to:
  /// **'confident'**
  String get confident;

  /// No description provided for @angry.
  ///
  /// In en, this message translates to:
  /// **'angry'**
  String get angry;

  /// No description provided for @tired.
  ///
  /// In en, this message translates to:
  /// **'tired'**
  String get tired;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'sad'**
  String get sad;

  /// No description provided for @cry.
  ///
  /// In en, this message translates to:
  /// **'cry'**
  String get cry;

  /// No description provided for @serene.
  ///
  /// In en, this message translates to:
  /// **'serene'**
  String get serene;

  /// No description provided for @surprised.
  ///
  /// In en, this message translates to:
  /// **'surprised'**
  String get surprised;

  /// No description provided for @love.
  ///
  /// In en, this message translates to:
  /// **'love'**
  String get love;

  /// No description provided for @save_failed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get save_failed;

  /// No description provided for @diary_not_found.
  ///
  /// In en, this message translates to:
  /// **'Diary not Found.'**
  String get diary_not_found;

  /// No description provided for @alert1.
  ///
  /// In en, this message translates to:
  /// **'Alert Setting'**
  String get alert1;

  /// No description provided for @alert2.
  ///
  /// In en, this message translates to:
  /// **'Allow app notifications?'**
  String get alert2;

  /// No description provided for @alert3.
  ///
  /// In en, this message translates to:
  /// **'Alert Allow'**
  String get alert3;

  /// No description provided for @alert4.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get alert4;

  /// No description provided for @alert5.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get alert5;

  /// No description provided for @alert6.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled.'**
  String get alert6;

  /// No description provided for @terms1.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms1;

  /// No description provided for @terms2.
  ///
  /// In en, this message translates to:
  /// **'\'By using this app, you agree to the Privacy Policy and Terms of Service.\\nFor more details, please refer to the official website or contact customer support.\'\n'**
  String get terms2;

  /// No description provided for @privacy1.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy1;

  /// No description provided for @privacy2.
  ///
  /// In en, this message translates to:
  /// **'This app values your privacy\nand collects only the minimum necessary personal information\nto provide its services, storing it securely.\n\nPersonal data is never shared with third parties without your consent,\nand you may request to view or delete your information at any time.\n\nThe information collected during app usage may include:\n- your email,\n- emotion diary entries,\n- and activity records.\n\nThis data is used solely for emotional analysis and statistical purposes.'**
  String get privacy2;

  /// No description provided for @report1.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get report1;

  /// No description provided for @report2.
  ///
  /// In en, this message translates to:
  /// **'Please describe any issues or bugs you encountered while using the app below.'**
  String get report2;

  /// No description provided for @report3.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem.'**
  String get report3;

  /// No description provided for @report4.
  ///
  /// In en, this message translates to:
  /// **'Your report has been received. Thank you.'**
  String get report4;

  /// No description provided for @report5.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get report5;

  /// No description provided for @contact1.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact1;

  /// No description provided for @contact2.
  ///
  /// In en, this message translates to:
  /// **'If you send your inquiry to the email address below, we will respond promptly.\\n📨 support@mooddiary.app\\nAlternatively, you can also report it via the \"Report a Problem\" menu in the app.'**
  String get contact2;

  /// No description provided for @contact3.
  ///
  /// In en, this message translates to:
  /// **'Please open your mail app and send us your inquiry.'**
  String get contact3;

  /// No description provided for @contact4.
  ///
  /// In en, this message translates to:
  /// **'Send Mail'**
  String get contact4;

  /// No description provided for @contact5.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get contact5;

  /// No description provided for @delete1.
  ///
  /// In en, this message translates to:
  /// **'Would you like to reset?'**
  String get delete1;

  /// No description provided for @delete2.
  ///
  /// In en, this message translates to:
  /// **'All diary data will be deleted and cannot be recovered.'**
  String get delete2;

  /// No description provided for @delete3.
  ///
  /// In en, this message translates to:
  /// **'The reset has been completed.'**
  String get delete3;

  /// No description provided for @delete4.
  ///
  /// In en, this message translates to:
  /// **'Reset failed.'**
  String get delete4;

  /// No description provided for @delete5.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the server.'**
  String get delete5;

  /// No description provided for @delete6.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get delete6;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get noImage;

  /// No description provided for @faqanswer1.
  ///
  /// In en, this message translates to:
  /// **'You can change your password from the My Profile screen.'**
  String get faqanswer1;

  /// No description provided for @faqanswer2.
  ///
  /// In en, this message translates to:
  /// **'You can disable notifications in the My Page settings.'**
  String get faqanswer2;

  /// No description provided for @faqanswer3.
  ///
  /// In en, this message translates to:
  /// **'You can reset your diary through the reset function in My Page.'**
  String get faqanswer3;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmPassword;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @passwordConfirmMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match.'**
  String get passwordConfirmMismatch;

  /// No description provided for @wrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get wrongCurrentPassword;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangeSuccess;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ko':
      return SKo();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
