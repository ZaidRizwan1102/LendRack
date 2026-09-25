import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/services/currency_service.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';

class LendedVSBorrowed extends StatefulWidget {
  const LendedVSBorrowed({super.key});

  @override
  State<LendedVSBorrowed> createState() => _LendedVSBorrowedState();
}

class _LendedVSBorrowedState extends State<LendedVSBorrowed>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _chartAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool _isCurrentMonth(DateTime? dt) {
    final recordDate = dt ?? DateTime.now();
    final now = DateTime.now();
    return recordDate.year == now.year && recordDate.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.widthPerc(7.5)),
          child: Text(
            "Lended vs Borrowed",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),

        SizedBox(height: size.heightPerc(1.2)),

        StreamBuilder<List<RecordModel>>(
          stream: DatabaseService().getRecords(),
          initialData: DatabaseService().currentRecords,
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];
            double lendedAmount = 0.0;
            double borrowedAmount = 0.0;

            for (var record in records) {
              if (!_isCurrentMonth(record.date)) continue;

              final type = record.type.trim().toLowerCase();
              final bool isLended = type == 'lending' || type == 'lend';

              if (isLended) {
                lendedAmount += record.amount;
              } else {
                borrowedAmount += record.amount;
              }
            }

            final total = lendedAmount + borrowedAmount;

            return ValueListenableBuilder<String>(
              valueListenable: CurrencyService.selectedCurrency,
              builder: (context, currentCurrency, _) {
                return Center(
                  child: Container(
                    width: size.widthPerc(85),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.widthPerc(4),
                      vertical: size.heightPerc(2),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(size.widthPerc(3)),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: size.widthPerc(0.2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: size.widthPerc(33),
                          height: size.widthPerc(33),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: Size(
                                      size.widthPerc(33),
                                      size.widthPerc(33),
                                    ),
                                    painter: _DonutChartPainter(
                                      lendedAmount: lendedAmount,
                                      borrowedAmount: borrowedAmount,
                                      lendedColor: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      borrowedColor: Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                                      emptyColor: Theme.of(
                                        context,
                                      ).dividerColor.withValues(alpha: 0.2),
                                      strokeWidth: size.widthPerc(3.2),
                                      progress: _chartAnimation.value,
                                    ),
                                  );
                                },
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "TOTAL",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      CurrencyService.formatAmount(
                                        total,
                                        targetCurrency: currentCurrency,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: size.widthPerc(4)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendRow(
                                context: context,
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiaryContainer,
                                title: "Borrowed",
                                amount: borrowedAmount,
                                total: total,
                                size: size,
                                currentCurrency: currentCurrency,
                              ),
                              SizedBox(height: size.heightPerc(1.2)),
                              _buildLegendRow(
                                context: context,
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                title: "Lended",
                                amount: lendedAmount,
                                total: total,
                                size: size,
                                currentCurrency: currentCurrency,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendRow({
    required BuildContext context,
    required Color color,
    required String title,
    required double amount,
    required double total,
    required Responsive size,
    required String currentCurrency,
  }) {
    final percentage = total > 0
        ? ((amount / total) * 100).toStringAsFixed(0)
        : "0";

    return Row(
      children: [
        Container(
          width: size.widthPerc(3.5),
          height: size.widthPerc(3.5),
          decoration: BoxDecoration(
            color: total > 0
                ? color
                : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: size.widthPerc(2.5)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title ($percentage%)",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: size.heightPerc(0.2)),
              Text(
                CurrencyService.formatAmount(
                  amount,
                  targetCurrency: currentCurrency,
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: total > 0
                      ? color
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double lendedAmount;
  final double borrowedAmount;
  final Color lendedColor;
  final Color borrowedColor;
  final Color emptyColor;
  final double strokeWidth;
  final double progress;

  _DonutChartPainter({
    required this.lendedAmount,
    required this.borrowedAmount,
    required this.lendedColor,
    required this.borrowedColor,
    required this.emptyColor,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = lendedAmount + borrowedAmount;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    if (total == 0) {
      paint.color = emptyColor;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
      return;
    }

    final lendedAngle = (lendedAmount / total) * 2 * math.pi * progress;
    final borrowedAngle = (borrowedAmount / total) * 2 * math.pi * progress;

    if (lendedAngle > 0) {
      paint.color = lendedColor;
      canvas.drawArc(rect, -math.pi / 2, lendedAngle, false, paint);
    }

    if (borrowedAngle > 0) {
      paint.color = borrowedColor;
      canvas.drawArc(
        rect,
        -math.pi / 2 + lendedAngle,
        borrowedAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lendedAmount != lendedAmount ||
        oldDelegate.borrowedAmount != borrowedAmount;
  }
}