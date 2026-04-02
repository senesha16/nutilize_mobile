import 'package:flutter/material.dart';
import 'package:nutilize/core/design/app_spacing.dart';
import 'package:nutilize/core/widgets/app_button.dart';
import 'package:nutilize/core/widgets/app_card.dart';
import 'package:nutilize/core/widgets/app_input.dart';
import 'package:nutilize/core/widgets/app_section_header.dart';

class ReserveScreen extends StatelessWidget {
  const ReserveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          AppSectionHeader(title: 'Reserve'),
          SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                AppInput(label: 'Resource', hint: 'Meeting room, equipment...'),
                SizedBox(height: AppSpacing.md),
                AppInput(label: 'Date', hint: 'YYYY-MM-DD'),
                SizedBox(height: AppSpacing.md),
                AppInput(label: 'Time', hint: '09:00 AM'),
                SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Submit Reservation', onPressed: null),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
