import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../utils/currency_formatter.dart';

class InvoiceFormScreen extends StatefulWidget {
  @override
  _InvoiceFormScreenState createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  late InvoiceType _invoiceType;
  Invoice? _editingInvoice;
  
  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(Duration(days: 30));
  double _taxRate = 10.0;
  PaymentStatus _paymentStatus = PaymentStatus.unpaid;
  
  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _invoiceType = args?['type'] ?? InvoiceType.sales;
      _editingInvoice = args?['invoice'];
      
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (_editingInvoice != null) {
      // Editing existing invoice
      _invoiceNumberController.text = _editingInvoice!.invoiceNumber;
      _clientNameController.text = _editingInvoice!.clientName;
      _clientEmailController.text = _editingInvoice!.clientEmail;
      _clientAddressController.text = _editingInvoice!.clientAddress;
      _notesController.text = _editingInvoice!.notes ?? '';
      _issueDate = _editingInvoice!.issueDate;
      _dueDate = _editingInvoice!.dueDate;
      _taxRate = _editingInvoice!.taxRate;
      _paymentStatus = _editingInvoice!.paymentStatus;
      _items = List.from(_editingInvoice!.items);
    } else {
      // Creating new invoice
      _generateInvoiceNumber();
      _addNewItem();
    }
    setState(() {});
  }

  void _generateInvoiceNumber() {
    final prefix = _invoiceType == InvoiceType.sales ? 'INV' : 'PO';
    final number = DateTime.now().millisecondsSinceEpoch.toString().substring(10);
    _invoiceNumberController.text = '$prefix-$number';
  }

  void _addNewItem() {
    setState(() {
      _items.add(InvoiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: '',
        quantity: 1,
        unitPrice: 0.0,
        total: 0.0,
      ));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  void _updateItem(int index, InvoiceItem updatedItem) {
    setState(() {
      _items[index] = updatedItem;
    });
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  double get _taxAmount => (_subtotal * _taxRate) / 100;
  double get _total => _subtotal + _taxAmount;

  void _saveInvoice() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final invoice = Invoice(
        id: _editingInvoice?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _invoiceType,
        invoiceNumber: _invoiceNumberController.text,
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        clientAddress: _clientAddressController.text,
        items: _items,
        subtotal: _subtotal,
        taxRate: _taxRate,
        taxAmount: _taxAmount,
        total: _total,
        dueDate: _dueDate,
        issueDate: _issueDate,
        paymentStatus: _paymentStatus,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final provider = Provider.of<InvoiceProvider>(context, listen: false);
      if (_editingInvoice != null) {
        provider.updateInvoice(invoice);
      } else {
        provider.addInvoice(invoice);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${_editingInvoice != null ? 'Edit' : 'Create'} ${_invoiceType == InvoiceType.sales ? 'Sales' : 'Purchase'} Invoice',
        ),
        actions: [
          TextButton(
            onPressed: _saveInvoice,
            child: Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInvoiceInfoCard(),
              SizedBox(height: 16),
              _buildClientInfoCard(),
              SizedBox(height: 16),
              _buildItemsCard(),
              SizedBox(height: 16),
              _buildTotalsCard(),
              SizedBox(height: 16),
              _buildAdditionalInfoCard(),
              SizedBox(height: 80), // Bottom padding for save button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceNumberController,
                    decoration: InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter invoice number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Issue Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_issueDate.day}/${_issueDate.month}/${_issueDate.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_invoiceType == InvoiceType.sales ? 'Customer' : 'Supplier'} Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: '${_invoiceType == InvoiceType.sales ? 'Customer' : 'Supplier'} Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _clientEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _clientAddressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                OutlinedButton.icon(
                  onPressed: _addNewItem,
                  icon: Icon(Icons.add),
                  label: Text('Add Item'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemWidget(index, item);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(int index, InvoiceItem item) {
    final descriptionController = TextEditingController(text: item.description);
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitPriceController = TextEditingController(text: item.unitPrice.toString());

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_items.length > 1)
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _updateItem(index, item.copyWith(description: value));
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 0;
                    _updateItem(index, item.copyWith(quantity: quantity));
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Enter valid quantity';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: unitPriceController,
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final unitPrice = double.tryParse(value) ?? 0.0;
                    _updateItem(index, item.copyWith(unitPrice: unitPrice));
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Total',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(CurrencyFormatter.format(item.total)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Totals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _taxRate.toString(),
              decoration: InputDecoration(
                labelText: 'Tax Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  _taxRate = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal:', CurrencyFormatter.format(_subtotal)),
                  _buildTotalRow('Tax (${_taxRate.toStringAsFixed(1)}%):', CurrencyFormatter.format(_taxAmount)),
                  Divider(),
                  _buildTotalRow('Total:', CurrencyFormatter.format(_total), isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<PaymentStatus>(
              value: _paymentStatus,
              decoration: InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
              ),
              items: PaymentStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paymentStatus = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'Additional notes or terms...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientAddressController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}