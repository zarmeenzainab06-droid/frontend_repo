import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("GymSwift | Reports"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text("Reports & Analytics",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 15),

            /// 🔴 TOP CARDS
            Row(
              children: [
                buildCard("\$111,300", "Total Revenue", Colors.green),
                SizedBox(width: 10),
                buildCard("\$18,550", "Average Monthly", Colors.blue),
                SizedBox(width: 10),
                buildCard("+67", "Member Growth", Colors.red),
              ],
            ),

            SizedBox(height: 25),

            /// 🔴 BAR CHART
            Text("Revenue Overview",
                style: TextStyle(fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Container(
              height: 250,
              padding: EdgeInsets.all(10),
              decoration: boxStyle(),
              child: BarChart(
                BarChartData(
                  maxY: 24000,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan','Feb','Mar','Apr','May','Jun'];
                          return Text(months[value.toInt()]);
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    makeBar(0, 12000),
                    makeBar(1, 15000),
                    makeBar(2, 18000),
                    makeBar(3, 20000),
                    makeBar(4, 18000),
                    makeBar(5, 21000),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            /// 🔴 LINE CHART
            Text("Membership Growth",
                style: TextStyle(fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Container(
              height: 250,
              padding: EdgeInsets.all(10),
              decoration: boxStyle(),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 260,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan','Feb','Mar','Apr','May','Jun'];
                          return Text(months[value.toInt()]);
                        },
                      ),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 190),
                        FlSpot(1, 200),
                        FlSpot(2, 210),
                        FlSpot(3, 220),
                        FlSpot(4, 230),
                        FlSpot(5, 240),
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔴 CARD
  Widget buildCard(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// 🔴 BAR FUNCTION
  BarChartGroupData makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.red,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// 🔴 BOX STYLE
  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 5),
      ],
    );
  }
}