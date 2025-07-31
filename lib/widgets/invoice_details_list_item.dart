import 'package:flutter/material.dart';

import '../models/invoice.dart';
import '../utils/currency_formatter.dart';

class InvoiceDetailsListItem extends StatefulWidget {
  final int index;
  final InvoiceItem item;
  final int length;
  final Function(int,InvoiceItem) updateItem;
  final Function(int) removeItem;

  InvoiceDetailsListItem({super.key,required this.length, required this.index, required this.item, required this.updateItem,required this.removeItem});



  @override
  State<InvoiceDetailsListItem> createState() => _InvoiceDetailsListItemState();
}

class _InvoiceDetailsListItemState extends State<InvoiceDetailsListItem> {

  late final descriptionController ;
  late final quantityController ;
  late final unitPriceController;


  @override
  void initState() {
    descriptionController = TextEditingController();
    quantityController = TextEditingController();
    unitPriceController = TextEditingController();


    descriptionController.text = widget.item.description;
    quantityController.text = widget.item.quantity.toString();
    unitPriceController.text = widget.item.unitPrice.toString();

    super.initState();
  }


  @override
  void didUpdateWidget(covariant InvoiceDetailsListItem oldWidget) {
    descriptionController.text = widget.item.description;
    quantityController.text = widget.item.quantity.toString();
    unitPriceController.text = widget.item.unitPrice.toString();
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('item_${widget.index}'),
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
                'Item ${{widget.index + 1} }',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.length > 1)
                IconButton(
                  onPressed: () {
                    widget.removeItem(widget.index);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            key: Key('description_${widget.index}'),
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.updateItem(widget.index, widget.item.copyWith(description: value));
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
                  key: Key('quantity_${widget.index}'),
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final quantity = int.tryParse(value) ?? 0;
                    widget.updateItem(widget.index, widget.item.copyWith(quantity: quantity));
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
                  key: Key('unitPrice_${widget.index}'),
                  controller: unitPriceController,
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final int unitPrice = int.tryParse(value) ?? 0;
                    widget.updateItem(widget.index, widget.item.copyWith(unitPrice: unitPrice));
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
                  child: Text(CurrencyFormatter.format(widget.item.total)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
