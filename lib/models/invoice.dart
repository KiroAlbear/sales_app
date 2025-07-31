import 'package:flutter/material.dart';

enum InvoiceType { sales, purchase }

enum PaymentStatus { paid, unpaid, partiallyPaid, overdue }

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      total: json['total'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }

  InvoiceItem copyWith({
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    final newQuantity = quantity ?? this.quantity;
    final newUnitPrice = unitPrice ?? this.unitPrice;
    return InvoiceItem(
      id: id,
      description: description ?? this.description,
      quantity: newQuantity,
      unitPrice: newUnitPrice,
      total: newQuantity * newUnitPrice,
    );
  }
}

class Invoice {
  final String id;
  final InvoiceType type;
  final String invoiceNumber;
  final String clientName;
  final String clientEmail;
  final String clientAddress;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final DateTime dueDate;
  final DateTime issueDate;
  final PaymentStatus paymentStatus;
  final DateTime? paymentDate;
  final String? notes;

  Invoice({
    required this.id,
    required this.type,
    required this.invoiceNumber,
    required this.clientName,
    required this.clientEmail,
    required this.clientAddress,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.dueDate,
    required this.issueDate,
    required this.paymentStatus,
    this.paymentDate,
    this.notes,
  });

  bool get isOverdue {
    if (paymentStatus == PaymentStatus.paid) return false;
    return dueDate.isBefore(DateTime.now());
  }

  String get typeString {
    return type == InvoiceType.sales ? 'Sales' : 'Purchase';
  }

  String get statusString {
    switch (paymentStatus) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }

  Color get statusColor {
    if (isOverdue) return Colors.red;
    switch (paymentStatus) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
        return Colors.orange;
      case PaymentStatus.partiallyPaid:
        return Colors.blue;
      case PaymentStatus.overdue:
        return Colors.red;
    }
  }

  Invoice copyWith({
    InvoiceType? type,
    String? invoiceNumber,
    String? clientName,
    String? clientEmail,
    String? clientAddress,
    List<InvoiceItem>? items,
    double? taxRate,
    DateTime? dueDate,
    DateTime? issueDate,
    PaymentStatus? paymentStatus,
    DateTime? paymentDate,
    String? notes,
  }) {
    final newItems = items ?? this.items;
    final newTaxRate = taxRate ?? this.taxRate;
    final newSubtotal = newItems.fold(0.0, (sum, item) => sum + item.total);
    final newTaxAmount = (newSubtotal * newTaxRate) / 100;
    final newTotal = newSubtotal + newTaxAmount;

    return Invoice(
      id: id,
      type: type ?? this.type,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      items: newItems,
      subtotal: newSubtotal,
      taxRate: newTaxRate,
      taxAmount: newTaxAmount,
      total: newTotal,
      dueDate: dueDate ?? this.dueDate,
      issueDate: issueDate ?? this.issueDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }
}
