import 'package:flutter/material.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import 'package:habitflow/core/constants/size_constant.dart';
import 'package:habitflow/core/widgets/animated_common.dart';

class QuickAction {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const QuickAction(
      {required this.icon, required this.label, required this.onTap});
}

/// 4-column grid of quick action chips (Add weight, Scan food, ...).
class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionsGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, i) {
        final action = actions[i];
        return StaggerFadeIn(
          index: i,
          baseDelay: const Duration(milliseconds: 30),
          child: TapScale(
            onTap: action.onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonSvgWidget(
                    svgName: action.icon,
                    height: 30,
                    width: 30,
                  ),
                  SBC.sH,
                  // Icon(action.icon,
                  //     color: Theme.of(context).colorScheme.primary),
                  Flexible(
                    child: Text(
                      action.label,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
