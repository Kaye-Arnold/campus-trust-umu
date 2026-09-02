import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InstallCard extends StatelessWidget {
  final bool canPrompt;
  final String instructions;
  final VoidCallback onInstall;
  final VoidCallback onDismiss;

  const InstallCard({super.key, required this.canPrompt, required this.instructions, required this.onInstall, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Install CampusTrust application',
      child: Card(
        color: AppColors.bgSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.border)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(backgroundColor: AppColors.primaryMuted, child: Icon(Icons.install_mobile, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Install CampusTrust', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(canPrompt ? 'Get faster access from your home screen and use supported features more reliably.' : instructions, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              const SizedBox(height: 10),
              if (canPrompt) OutlinedButton(onPressed: onInstall, child: const Text('Install App'))
            ])),
            IconButton(tooltip: 'Not now', onPressed: onDismiss, icon: const Icon(Icons.close, size: 20)),
          ]),
        ),
      ),
    );
  }
}
