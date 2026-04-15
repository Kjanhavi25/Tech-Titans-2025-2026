import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/order_model.dart';

class OwnerOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OwnerOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final paymentStatusColor = _getPaymentStatusColor(order.paymentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Info
            _InfoCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER ID',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${order.orderId.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    _StatusBadge(
                      label: order.status.toString().split('.').last.toUpperCase(),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: Colors.blueGrey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Customer Section
            const _SectionTitle(title: 'Customer Information'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF6366F1), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer ID',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Text(
                            order.userId,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionTitle(title: 'Order Items'),
                Text(
                  '${order.items.length} items',
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoCard(
              padding: EdgeInsets.zero,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantity}x',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.weight != null)
                                  Text(
                                    '${item.weight}g',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppUtils.formatCurrency(item.price * item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF9FAFB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        AppUtils.formatCurrency(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 20,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Payment Info
            const _SectionTitle(title: 'Payment Details'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _DetailRow(
                  label: 'Payment Status',
                  value: order.paymentStatus.toString().split('.').last.toUpperCase(),
                  valueColor: paymentStatusColor,
                ),
                const SizedBox(height: 12),
                const _DetailRow(
                  label: 'Payment Method',
                  value: 'UPI / In-App',
                ),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Notes',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.notes!,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Helper text
            Center(
              child: Text(
                'This order belongs to your shop data isolation group.',
                style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed: return Colors.green;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.cancelled: return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid: return Colors.green;
      case PaymentStatus.unpaid: return Colors.orange;
      case PaymentStatus.failed: return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  const _InfoCard({required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
