import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/services/presentation/controllers/services_notifier.dart';

void main() {
  test('ServicesNotifier fetch returns list', () async {
    final notifier = ServicesNotifier();
    await notifier.fetch();

    final state = notifier.state;
    expect(state.isLoading || state.hasValue, true);
    expect(state.value, isNotNull);
    expect(state.value!.length, greaterThanOrEqualTo(1));
  });

  test('ServicesNotifier can create a service and state updates', () async {
    final notifier = ServicesNotifier();

    final payload = {
      'providerId': 'prov_test',
      'title': 'Test Service',
      'description': 'Created by unit test',
      'price': 1000,
      'currency': 'XOF',
      'priceType': 'FIXED',
      'images': <String>[],
      'scope': 'CITY_ONLY',
    };

    await notifier.create(payload);

    final state = notifier.state;
    expect(state.hasValue, true);
    final created = state.value!.firstWhere((s) => s.title == 'Test Service');
    expect(created.id, isNotEmpty);
    expect(created.title, 'Test Service');
  });
}
