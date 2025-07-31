import 'package:flutter/foundation.dart';
import '../models/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  
  List<Invoice> get invoices => _invoices;
  
  List<Invoice> get salesInvoices => 
      _invoices.where((invoice) => invoice.type == InvoiceType.sales).toList();
  
  List<Invoice> get purchaseInvoices => 
      _invoices.where((invoice) => invoice.type == InvoiceType.purchase).toList();
  
  double get totalSales => 
      salesInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  
  double get totalPurchases => 
      purchaseInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  
  List<Invoice> get unpaidInvoices => 
      _invoices.where((invoice) => invoice.paymentStatus == PaymentStatus.unpaid).toList();
  
  List<Invoice> get overdueInvoices => 
      _invoices.where((invoice) => invoice.isOverdue).toList();

  InvoiceProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _invoices = [
      Invoice(
        id: '1',
        type: InvoiceType.sales,
        invoiceNumber: 'INV-001',
        clientName: 'Acme Corporation',
        clientEmail: 'billing@acme.com',
        clientAddress: '123 Business St, City, State 12345',
        items: [
          InvoiceItem(
            id: '1',
            description: 'Web Development Services',
            quantity: 1,
            unitPrice: 2500,
            total: 2500.0,
          ),
        ],
        subtotal: 2500.0,
        taxRate: 10.0,
        taxAmount: 250.0,
        total: 2750.0,
        dueDate: DateTime(2025, 8, 15),
        issueDate: DateTime(2025, 7, 30),
        paymentStatus: PaymentStatus.unpaid,
      ),
      Invoice(
        id: '2',
        type: InvoiceType.purchase,
        invoiceNumber: 'PO-001',
        clientName: 'Tech Supplies Ltd',
        clientEmail: 'orders@techsupplies.com',
        clientAddress: '456 Supplier Ave, City, State 54321',
        items: [
          InvoiceItem(
            id: '1',
            description: 'Office Equipment',
            quantity: 5,
            unitPrice: 150,
            total: 750.0,
          ),
        ],
        subtotal: 750.0,
        taxRate: 8.0,
        taxAmount: 60.0,
        total: 810.0,
        dueDate: DateTime(2025, 8, 10),
        issueDate: DateTime(2025, 7, 25),
        paymentStatus: PaymentStatus.paid,
        paymentDate: DateTime(2025, 7, 28),
      ),
    ];
    notifyListeners();
  }

  void addInvoice(Invoice invoice) {
    final newInvoice = invoice.copyWith();
    _invoices.add(newInvoice);
    notifyListeners();
  }

  void updateInvoice(Invoice updatedInvoice) {
    final index = _invoices.indexWhere((invoice) => invoice.id == updatedInvoice.id);
    if (index != -1) {
      _invoices[index] = updatedInvoice;
      notifyListeners();
    }
  }

  void deleteInvoice(String id) {
    _invoices.removeWhere((invoice) => invoice.id == id);
    notifyListeners();
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
             invoice.clientName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Invoice> filterInvoices({
    PaymentStatus? status,
    InvoiceType? type,
  }) {
    return _invoices.where((invoice) {
      bool matchesStatus = status == null || invoice.paymentStatus == status;
      bool matchesType = type == null || invoice.type == type;
      return matchesStatus && matchesType;
    }).toList();
  }
}