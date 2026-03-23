/// Wizard Step Indicator Widget
///
/// Displays step progress for multi-step wizard flows.
library;

import 'package:flutter/material.dart';

class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final bool showLabels;

  const WizardStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  // Circle indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : isCurrent
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            )
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isCurrent
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                  // Connector line (except for last step)
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // Labels
        if (showLabels && stepLabels != null && stepLabels!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalSteps, (index) {
              final isCurrent = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Text(
                  index < stepLabels!.length ? stepLabels![index] : '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isCurrent || isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
