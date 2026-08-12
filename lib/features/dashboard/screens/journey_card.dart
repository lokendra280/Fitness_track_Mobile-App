import 'dart:math' as math;

import 'package:flutter/material.dart';

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.startingWeight,
    required this.daysLeft,
    required this.streak,
  });

  final double currentWeight;
  final double targetWeight;
  final double startingWeight;
  final int daysLeft;
  final int streak;

  double get weightLost => math.max(0, startingWeight - currentWeight);

  double get totalWeightToLose => math.max(0, startingWeight - targetWeight);

  double get remainingWeight => math.max(0, currentWeight - targetWeight);

  double get progress {
    if (totalWeightToLose <= 0) return 0;
    return (weightLost / totalWeightToLose).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF006B63),
            Color(0xFF004F4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background circles.
            Positioned(
              right: -90,
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            Positioned(
              right: -50,
              bottom: 80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProgress(),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildWeightInformation(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildProgressBar(),
                  const SizedBox(height: 18),
                  _buildStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD8F7E8),
          ),
          child: const Icon(
            Icons.landscape_rounded,
            color: Color(0xFF006B63),
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Weight Loss',
                style: TextStyle(
                  color: Color(0xFFA7E6D0),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 5),
              Text(
                '${streak}d streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return SizedBox(
      width: 125,
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 125,
            height: 125,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 11,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          SizedBox(
            width: 125,
            height: 125,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 11,
              strokeCap: StrokeCap.round,
              color: const Color(0xFFB8F3D2),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${currentWeight.toStringAsFixed(1)} kg',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Current weight',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 13),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Target: ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: '${targetWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: Color(0xFFB8F3D2),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFFB8F3D2),
              size: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${weightLost.toStringAsFixed(1)} kg lost so far',
                style: const TextStyle(
                  color: Color(0xFFB8F3D2),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${remainingWeight.toStringAsFixed(1)} kg remaining',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$daysLeft days left',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.16),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFB8F3D2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.calendar_month_rounded,
            value: '$daysLeft',
            label: 'Days left',
          ),
        ),
        _divider(),
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department_rounded,
            value: '${streak}d',
            label: 'Current streak',
          ),
        ),
        _divider(),
        Expanded(
          child: _StatItem(
            icon: Icons.track_changes_rounded,
            value: '${targetWeight.toStringAsFixed(1)} kg',
            label: 'Target weight',
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 42,
      color: Colors.white.withOpacity(0.15),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
