import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gttp/features/auth/presentation/screens/login_screen.dart';
import 'package:gttp/features/auth/domain/repositories/auth_repository.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/core/widgets/custom_text_field.dart';
import 'package:gttp/core/widgets/custom_button.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    when(() => mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);
    when(() => mockSecureStorage.getPendingUserId()).thenAnswer((_) async => null);
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) =>
              const Scaffold(body: Text('forgot-password')),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) => const Scaffold(body: Text('verify-otp')),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Scaffold(body: Text('dashboard')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders login screen elements', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome to GTTP India'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(2));
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('shows email validation error when email field is blank', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final loginButtonFinder = find.byType(CustomButton);
    expect(tester.widget<CustomButton>(loginButtonFinder).isEnabled, isFalse);

    await tester.enterText(find.byType(CustomTextField).first, ' ');
    await tester.enterText(find.byType(CustomTextField).last, 'password123');
    await tester.pump();
    expect(tester.widget<CustomButton>(loginButtonFinder).isEnabled, isTrue);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows email format validation error for invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(CustomTextField).first, 'notanemail');
    await tester.enterText(find.byType(CustomTextField).last, 'password123');
    await tester.pump();

    await tester.tap(find.byType(CustomButton));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('calls login on AuthRepository when valid credentials are provided', (WidgetTester tester) async {
    when(() => mockAuthRepository.login(
          usernameOrEmail: any(named: 'usernameOrEmail'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});

    when(() => mockSecureStorage.getAccessToken()).thenAnswer((_) async => 'test-access-token');

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(CustomTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomTextField).last, 'password123');
    await tester.pump();

    final loginButtonFinder = find.byType(CustomButton);
    expect(tester.widget<CustomButton>(loginButtonFinder).isEnabled, isTrue);

    await tester.tap(loginButtonFinder);
    await tester.pump();

    verify(() => mockAuthRepository.login(
          usernameOrEmail: 'test@example.com',
          password: 'password123',
        )).called(1);

    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
  });
}
