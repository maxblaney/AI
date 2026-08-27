import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/models.dart';
import '../../state/game_controller.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final org = controller.organization;
    final currency = NumberFormat.simpleCurrency();
    final completed = controller.completedEvents.reversed.toList();

    final totalRevenue = completed.fold<int>(0, (sum, e) => sum + e.revenue);
    final totalExpenses = completed.fold<int>(0, (sum, e) => sum + e.expenses);

    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cash Balance', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    currency.format(org?.cashBalance ?? 0),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Revenue',
                  value: currency.format(totalRevenue),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Expenses',
                  value: currency.format(totalExpenses),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Per-Event Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            const Text('No completed events yet.')
          else
            for (final event in completed) _EventFinanceRow(event: event, currency: currency),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventFinanceRow extends StatelessWidget {
  final MmaEvent event;
  final NumberFormat currency;

  const _EventFinanceRow({required this.event, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.name),
        subtitle: Text(
          'Revenue ${currency.format(event.revenue)} · '
          'Expenses ${currency.format(event.expenses)}',
        ),
        trailing: Text(
          '${event.netProfit >= 0 ? '+' : ''}${currency.format(event.netProfit)}',
          style: TextStyle(
            color: event.netProfit >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
