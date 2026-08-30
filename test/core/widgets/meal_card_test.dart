import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dinelify_app/core/widgets/meal_card.dart';
import 'package:dinelify_app/data/models/meal.dart';

MealModel _meal({String status = 'available'}) => MealModel(
  id: 1,
  mealType: 'lunch',
  foodType: 'veg',
  foodName: 'Dal Tadka Thali',
  status: status,
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('MealCard shows the meal name and calls onTap when available', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        MealCard(
          foodType: 'veg',
          meal: _meal(),
          selected: false,
          enabled: true,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Dal Tadka Thali'), findsOneWidget);
    expect(find.text('Veg'), findsOneWidget);

    await tester.tap(find.byType(MealCard));
    expect(tapped, isTrue);
  });

  testWidgets('MealCard does not call onTap when the meal is unavailable', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        MealCard(
          foodType: 'veg',
          meal: _meal(status: 'unavailable'),
          selected: false,
          enabled: true,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Unavailable'), findsOneWidget);

    await tester.tap(find.byType(MealCard));
    expect(tapped, isFalse);
  });

  testWidgets('MealCard renders the Skip option without a meal', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MealCard(
          foodType: 'skip',
          selected: true,
          enabled: true,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Skip'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });
}
