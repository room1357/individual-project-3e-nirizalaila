import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../managers/expense_manager.dart';
import '../model/expense.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseManager.expenses;
    final totalByCategory = ExpenseManager.getTotalByCategory(expenses);
    final highestExpense = ExpenseManager.getHighestExpense(expenses);
    final averageDaily = ExpenseManager.getAverageDaily(expenses);

    final totalAll = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Pengeluaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildSummaryCard(
                'Total Semua Pengeluaran',
                'Rp ${totalAll.toStringAsFixed(0)}',
                Icons.summarize,
                Colors.indigo,
              ),
              _buildSummaryCard(
                'Rata-rata Harian',
                'Rp ${averageDaily.toStringAsFixed(0)}',
                Icons.calendar_today,
                Colors.teal,
              ),
              _buildSummaryCard(
                'Pengeluaran Tertinggi',
                highestExpense != null
                    ? '${highestExpense.title} - Rp ${highestExpense.amount.toStringAsFixed(0)}'
                    : 'Tidak ada data',
                Icons.trending_up,
                Colors.orange,
              ),

              const SizedBox(height: 24),

              const Text(
                'Grafik Pengeluaran per Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              AspectRatio(
                aspectRatio: 1.4,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 24,
                    top: 8,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 36, bottom: 30),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  interval: _getInterval(totalByCategory),
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= totalByCategory.keys.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        totalByCategory.keys.elementAt(index),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups:
                                totalByCategory.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final e = entry.value;
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value,
                                            color: Colors.indigo,
                                            width: 22,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                      ),

                      // Label sumbu Y
                      const Positioned(
                        left: 0,
                        top: 100,
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(
                            'Jumlah Pengeluaran (Rp)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      // Label sumbu X
                      const Positioned(
                        bottom: 0,
                        left: 80,
                        right: 80,
                        child: Center(
                          child: Text(
                            'Kategori Pengeluaran',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _getInterval(Map<String, double> data) {
    if (data.isEmpty) return 100;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return (maxValue / 5).ceilToDouble();
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
