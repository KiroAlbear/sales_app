import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../utils/currency_formatter.dart';
import 'invoice_form_screen.dart';
import 'invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String _searchTerm = '';
  PaymentStatus? _statusFilter;
  InvoiceType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('All Invoices'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sales') {
                _navigateToInvoiceForm(InvoiceType.sales);
              } else if (value == 'purchase') {
                _navigateToInvoiceForm(InvoiceType.purchase);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sales',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 8),
                    Text('Sales Invoice'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'purchase',
                child: Row(
                  children: [
                    Icon(Icons.add_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Purchase Invoice'),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: null,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          final filteredInvoices =
              _getFilteredInvoices(invoiceProvider.invoices);

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search invoices...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<PaymentStatus?>(
                            value: _statusFilter,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(
                                  value: null, child: Text('All Statuses')),
                              ...PaymentStatus.values.map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status
                                      .toString()
                                      .split('.')
                                      .last
                                      .replaceAll('_', ' ')),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _statusFilter = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<InvoiceType?>(
                            value: _typeFilter,
                            decoration: InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(
                                  value: null, child: Text('All Types')),
                              ...InvoiceType.values.map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toString().split('.').last),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _typeFilter = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Results Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${filteredInvoices.length} of ${invoiceProvider.invoices.length} invoices',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // Invoice List
              Expanded(
                child: filteredInvoices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          return _buildInvoiceCard(
                              context, invoice, invoiceProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Invoice> _getFilteredInvoices(List<Invoice> invoices) {
    return invoices.where((invoice) {
      // Search filter
      final matchesSearch = _searchTerm.isEmpty ||
          invoice.invoiceNumber
              .toLowerCase()
              .contains(_searchTerm.toLowerCase()) ||
          invoice.clientName.toLowerCase().contains(_searchTerm.toLowerCase());

      // Status filter
      final matchesStatus =
          _statusFilter == null || invoice.paymentStatus == _statusFilter;

      // Type filter
      final matchesType = _typeFilter == null || invoice.type == _typeFilter;

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  Widget _buildInvoiceCard(
      BuildContext context, Invoice invoice, InvoiceProvider provider) {
    final isOverdue = invoice.isOverdue;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        color: isOverdue ? Colors.red.withOpacity(0.05) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToInvoiceDetail(invoice),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                invoice.invoiceNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: invoice.type == InvoiceType.sales
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  invoice.typeString,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: invoice.type == InvoiceType.sales
                                        ? Colors.blue
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            invoice.clientName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: invoice.statusColor.withOpacity(0.1),
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

                SizedBox(height: 12),

                // Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due: ${_formatDate(invoice.dueDate)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(invoice.total),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, size: 20),
                          onPressed: () => _navigateToInvoiceDetail(invoice),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          onPressed: () =>
                              _navigateToInvoiceForm(invoice.type, invoice),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () =>
                              _showDeleteDialog(context, invoice, provider),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No invoices found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToInvoiceForm(InvoiceType type, [Invoice? invoice]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(),
        settings: RouteSettings(
          arguments: {
            'type': type,
            if (invoice != null) 'invoice': invoice,
          },
        ),
      ),
    );
  }

  void _navigateToInvoiceDetail(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoice),
        settings: RouteSettings(
          arguments: {'invoice': invoice},
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Invoice invoice, InvoiceProvider provider) {
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
              provider.deleteInvoice(invoice.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
