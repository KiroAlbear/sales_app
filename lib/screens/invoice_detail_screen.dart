import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../utils/currency_formatter.dart';
import 'invoice_form_screen.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  InvoiceDetailScreen(this.invoice);

  @override
  Widget build(BuildContext context) {
    // final args =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    // final Invoice invoice = args['invoice'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePDF(context, invoice),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEdit(context, invoice);
              } else if (value == 'delete') {
                _showDeleteDialog(context, invoice);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            _buildHeaderCard(context, invoice),
            SizedBox(height: 16),

            // Payment Status Card
            _buildPaymentStatusCard(context, invoice),
            SizedBox(height: 16),

            // Client Info Card
            _buildClientInfoCard(context, invoice),
            SizedBox(height: 16),

            // Items Card
            _buildItemsCard(context, invoice),
            SizedBox(height: 16),

            // Totals Card
            _buildTotalsCard(context, invoice),

            // Notes Card (if notes exist)
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildNotesCard(context, invoice),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Invoice invoice) {
    final isOverdue = invoice.isOverdue;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: invoice.type == InvoiceType.sales
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${invoice.typeString} Invoice',
                    style: TextStyle(
                      fontSize: 12,
                      color: invoice.type == InvoiceType.sales
                          ? Colors.blue
                          : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOverdue ? Colors.red : invoice.statusColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverdue ? 'Overdue' : invoice.statusString,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : invoice.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issue Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Text(
                        _formatDate(invoice.issueDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Text(
                        _formatDate(invoice.dueDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isOverdue ? Colors.red : null,
                              fontWeight: isOverdue ? FontWeight.w600 : null,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (invoice.paymentDate != null) ...[
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    _formatDate(invoice.paymentDate!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(BuildContext context, Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Payment Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Consumer<InvoiceProvider>(
                    builder: (context, provider, child) {
                      return DropdownButtonFormField<PaymentStatus>(
                        value: invoice.paymentStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: PaymentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status
                                .toString()
                                .split('.')
                                .last
                                .replaceAll('_', ' ')),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            final updatedInvoice = invoice.copyWith(
                              paymentStatus: newStatus,
                              paymentDate: newStatus == PaymentStatus.paid
                                  ? DateTime.now()
                                  : null,
                            );
                            provider.updateInvoice(updatedInvoice);
                          }
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      CurrencyFormatter.format(invoice.total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(BuildContext context, Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.type == InvoiceType.sales
                  ? 'Customer Information'
                  : 'Supplier Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Text(
              invoice.clientName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              invoice.clientEmail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(height: 8),
            Text(
              invoice.clientAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            ...invoice.items.map((item) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.total),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard(BuildContext context, Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            _buildTotalRow(context, 'Subtotal:',
                CurrencyFormatter.format(invoice.subtotal)),
            _buildTotalRow(
                context,
                'Tax (${invoice.taxRate.toStringAsFixed(1)}%):',
                CurrencyFormatter.format(invoice.taxAmount)),
            Divider(height: 24),
            _buildTotalRow(
              context,
              'Total:',
              CurrencyFormatter.format(invoice.total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, Invoice invoice) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Text(
              invoice.notes!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateToEdit(BuildContext context, Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(),
        settings: RouteSettings(
          arguments: {
            'type': invoice.type,
            'invoice': invoice,
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Invoice'),
        content: Text(
            'Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InvoiceProvider>(context, listen: false)
                  .deleteInvoice(invoice.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(BuildContext context, Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: pw.TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Issue Date: ${_formatDate(invoice.issueDate)}'),
                      pw.Text('Due Date: ${_formatDate(invoice.dueDate)}'),
                      pw.Text('Status: ${invoice.statusString}'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Client Information
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    invoice.type == InvoiceType.sales ? 'Bill To:' : 'From:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(invoice.clientName,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.clientEmail),
                  pw.Text(invoice.clientAddress),
                ],
              ),

              pw.SizedBox(height: 30),

              // Items Table
              pw.Table.fromTextArray(
                headers: ['Description', 'Quantity', 'Unit Price', 'Total'],
                data: invoice.items
                    .map((item) => [
                          item.description,
                          item.quantity.toString(),
                          CurrencyFormatter.format(item.unitPrice),
                          CurrencyFormatter.format(item.total),
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellHeight: 30,
              ),

              pw.SizedBox(height: 20),

              // Totals
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                        'Subtotal: ${CurrencyFormatter.format(invoice.subtotal)}'),
                    pw.Text(
                        'Tax (${invoice.taxRate.toStringAsFixed(1)}%): ${CurrencyFormatter.format(invoice.taxAmount)}'),
                    pw.Divider(),
                    pw.Text(
                      'Total: ${CurrencyFormatter.format(invoice.total)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 30),
                pw.Text('Notes:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(invoice.notes!),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}',
    );
  }
}
