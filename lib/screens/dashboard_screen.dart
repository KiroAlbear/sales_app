import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:accounting_app_flutter/screens/invoice_detail_screen.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stat_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/recent_invoice_card.dart';
import 'invoice_form_screen.dart';
import 'invoice_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<InvoiceProvider>(
          builder: (context, invoiceProvider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Manager',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your sales and purchase invoices',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          'New Sales Invoice',
                          Icons.add,
                          Colors.black,
                          () => _navigateToInvoiceForm(
                              context, InvoiceType.sales),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          'New Purchase Invoice',
                          Icons.add_outlined,
                          Colors.grey[700]!,
                          () => _navigateToInvoiceForm(
                              context, InvoiceType.purchase),
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Stats Overview
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Sales',
                          value: CurrencyFormatter.format(
                              invoiceProvider.totalSales),
                          subtitle:
                              '${invoiceProvider.salesInvoices.length} invoices',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Total Purchases',
                          value: CurrencyFormatter.format(
                              invoiceProvider.totalPurchases),
                          subtitle:
                              '${invoiceProvider.purchaseInvoices.length} invoices',
                          icon: Icons.attach_money,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Alerts
                  if (invoiceProvider.overdueInvoices.isNotEmpty ||
                      invoiceProvider.unpaidInvoices.isNotEmpty) ...[
                    if (invoiceProvider.overdueInvoices.isNotEmpty)
                      AlertCard(
                        title: 'Overdue Invoices',
                        message:
                            '${invoiceProvider.overdueInvoices.length} invoice(s) are overdue',
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                    if (invoiceProvider.unpaidInvoices.isNotEmpty)
                      AlertCard(
                        title: 'Pending Payments',
                        message:
                            '${invoiceProvider.unpaidInvoices.length} invoice(s) awaiting payment',
                        icon: Icons.schedule,
                        color: Colors.orange[500]!,
                      ),
                    SizedBox(height: 24),
                  ],

                  // Recent Invoices
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Invoices',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InvoiceListScreen(),
                                      ));
                                },
                                icon: Icon(Icons.description, size: 16),
                                label: Text('View All'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          if (invoiceProvider.invoices.isEmpty)
                            _buildEmptyState(context)
                          else
                            ...invoiceProvider.invoices.take(invoiceProvider.invoices.length).map(
                                  (invoice) => RecentInvoiceCard(
                                    invoice: invoice,
                                    onTap: () => _navigateToInvoiceDetail(
                                        context, invoice),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return Container(
      height: 80,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(color: color, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.description,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No invoices yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Create your first invoice to get started',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToInvoiceForm(BuildContext context, InvoiceType type) {
    // Navigator.pushNamed(
    //   context,
    //   '/invoice-form',
    //   arguments: {'type': type},
    // );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceFormScreen(),
        ));
  }

  void _navigateToInvoiceDetail(BuildContext context, Invoice invoice) {
    // Navigator.pushNamed(
    //   context,
    //   '/invoice-detail',
    //   arguments: {'invoice': invoice},
    // );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceDetailScreen(invoice),
        ));
  }
}
