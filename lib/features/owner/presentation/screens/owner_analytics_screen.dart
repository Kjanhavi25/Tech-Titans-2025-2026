import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/owner_provider.dart';

class OwnerAnalyticsScreen extends StatefulWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  State<OwnerAnalyticsScreen> createState() => _OwnerAnalyticsScreenState();
}

class _OwnerAnalyticsScreenState extends State<OwnerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerProvider>().loadWeeklySummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text(
          'Business Intelligence',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              context.read<OwnerProvider>().loadWeeklySummary();
              context.read<OwnerProvider>().refreshSalesData();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<OwnerProvider>(
        builder: (context, ownerProvider, _) {
          if (ownerProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF6366F1),
            onRefresh: () async {
              await ownerProvider.loadWeeklySummary();
              await ownerProvider.refreshSalesData();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // ── PERFORMANCE SUMMARY ──────────────────────────────
                  const Text(
                    'Real-time Performance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernStatCard(
                          label: "Today's Revenue",
                          value: AppUtils.formatCurrency(ownerProvider.dailySalesTotal),
                          sub: '${ownerProvider.dailyOrdersCount} transactions',
                          icon: Icons.auto_graph_rounded,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModernStatCard(
                          label: 'Total Value',
                          value: AppUtils.formatCurrencyShort(ownerProvider.totalRevenue),
                          sub: '${ownerProvider.totalOrdersCount} total orders',
                          icon: Icons.account_balance_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernStatCard(
                          label: 'Customer Base',
                          value: ownerProvider.totalCustomersCount.toString(),
                          sub: 'Total registered',
                          icon: Icons.groups_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModernStatCard(
                          label: 'Live Traffic',
                          value: ownerProvider.activeTrolleyCount.toString(),
                          sub: 'Active sessions',
                          icon: Icons.radar_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── WEEKLY TREND ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weekly Sales Trend',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      Text(
                        'Last 7 Days',
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SophisticatedBarChart(summary: ownerProvider.weeklySummary),
                  const SizedBox(height: 32),

                  // ── DETAILED BREAKDOWN ─────────────────────────────────
                  const Text(
                    'Daily Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  if (ownerProvider.weeklySummary.isEmpty)
                    const _EmptyState(message: 'No activities recorded in the last 7 days')
                  else
                    _AnalyticalTable(summary: ownerProvider.weeklySummary),
                  const SizedBox(height: 32),

                  // ── CORE METRICS ──────────────────────────────────────
                  const Text(
                    'Precision Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  _MetricalAssessment(ownerProvider: ownerProvider),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151), 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _SophisticatedBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> summary;
  const _SophisticatedBarChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: const _EmptyState(message: 'Awaiting sales data arrival'),
      );
    }

    final maxTotal = summary
        .map((e) => (e['total'] as double))
        .fold<double>(0, (prev, e) => e > prev ? e : prev);
    final effectiveMax = maxTotal == 0 ? 1.0 : maxTotal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: summary.map((day) {
              final total = (day['total'] as double);
              final date = day['date'] as DateTime;
              final heightFraction = total / effectiveMax;
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (total > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '₹${(total / 1000).toStringAsFixed(1)}k',
                            style: TextStyle(
                              fontSize: 9,
                              color: isToday ? const Color(0xFF6366F1) : Colors.blueGrey.shade400,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        height: (heightFraction * 140).clamp(6.0, 140.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday
                                ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
                                : [Colors.blueGrey.shade100, Colors.blueGrey.shade200],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isToday ? [
                            BoxShadow(color: const Color(0xFF6366F1).withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))
                          ] : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DateFormat('E').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isToday ? const Color(0xFF6366F1) : Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(label: 'Today', color: const Color(0xFF6366F1), isGradient: true),
              const SizedBox(width: 24),
              _ChartLegend(label: 'Historical', color: Colors.blueGrey.shade200, isGradient: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  final bool isGradient;
  const _ChartLegend({required this.label, required this.color, required this.isGradient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isGradient ? null : color,
            gradient: isGradient ? LinearGradient(colors: [color, color.withAlpha(150)]) : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade500),
        ),
      ],
    );
  }
}

class _AnalyticalTable extends StatelessWidget {
  final List<Map<String, dynamic>> summary;
  const _AnalyticalTable({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.blueGrey.shade50,
              child: Row(
                children: const [
                  Expanded(flex: 3, child: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Color(0xFF6366F1)))),
                  Expanded(flex: 2, child: Text('VOL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Color(0xFF6366F1)))),
                  Expanded(flex: 3, child: Text('REVENUE', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Color(0xFF6366F1)))),
                ],
              ),
            ),
            ...summary.asMap().entries.map((entry) {
              final day = entry.value;
              final isToday = DateUtils.isSameDay(day['date'] as DateTime, DateTime.now());
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF6366F1).withAlpha(10) : Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.blueGrey.shade50)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${DateFormat('MMM d, yyyy').format(day['date'] as DateTime)}${isToday ? ' • Today' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${day['count']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isToday ? const Color(0xFF6366F1) : const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        AppUtils.formatCurrency(day['total'] as double),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: const Color(0xFF1F2937),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('7-DAY AGGREGATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2, color: Colors.white70))),
                  Expanded(
                    flex: 2, 
                    child: Text(
                      '${summary.fold<int>(0, (sum, d) => sum + (d['count'] as int))}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      AppUtils.formatCurrencyShort(summary.fold<double>(0, (sum, d) => sum + (d['total'] as double))),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricalAssessment extends StatelessWidget {
  final OwnerProvider ownerProvider;
  const _MetricalAssessment({required this.ownerProvider});

  @override
  Widget build(BuildContext context) {
    final avg = ownerProvider.totalOrdersCount > 0
        ? ownerProvider.totalRevenue / ownerProvider.totalOrdersCount
        : 0.0;

    final weeklyTotal = ownerProvider.weeklySummary.fold<double>(0, (sum, d) => sum + (d['total'] as double));
    final weeklyOrders = ownerProvider.weeklySummary.fold<int>(0, (sum, d) => sum + (d['count'] as int));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _MetricExecutionRow(
            label: 'Avg. Order Ticket',
            value: AppUtils.formatCurrency(avg),
            icon: Icons.payments_rounded,
            color: const Color(0xFF6366F1),
          ),
          const Divider(height: 32, thickness: 0.5),
          _MetricExecutionRow(
            label: 'Rolling 7-Day Rev',
            value: AppUtils.formatCurrencyShort(weeklyTotal),
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF10B981),
          ),
          const Divider(height: 32, thickness: 0.5),
          _MetricExecutionRow(
            label: 'Rolling 7-Day Vol',
            value: weeklyOrders.toString(),
            icon: Icons.inventory_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const Divider(height: 32, thickness: 0.5),
          _MetricExecutionRow(
            label: 'Engagement Factor',
            value: ownerProvider.totalCustomersCount > 0
                ? '${((ownerProvider.totalOrdersCount / ownerProvider.totalCustomersCount) * 1).toStringAsFixed(2)}x'
                : '0.00x',
            icon: Icons.bolt_rounded,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class _MetricExecutionRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricExecutionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.query_stats_rounded, size: 48, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
