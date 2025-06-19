import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmotionSummaryChart extends StatelessWidget {
  final Map<String, int> emotionData;
  final Map<String, String> emotionImageUrls;

  const EmotionSummaryChart({
    super.key,
    required this.emotionData,
    required this.emotionImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries = emotionData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < sortedEntries.length) {
                  final emotion = sortedEntries[index].key;
                  final imagePath = emotionImageUrls[emotion] ?? 'assets/images/emotions/neutral.png';

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Image.asset(
                      imagePath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: sortedEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value.toDouble(),
                width: 16,
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
