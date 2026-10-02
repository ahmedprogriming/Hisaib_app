
import 'package:flutter/material.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:provider/provider.dart';

Future<String?> showAddCustomerDialog(BuildContext context) async
{
    final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final confirmed=await showDialog(context: context,
   builder: (context)=>AlertDialog(

          title: const Text('زبون جديد'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم الزبون'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
            ),
          ],
        ),
      ),
       actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(context, true);
          },
          child: const Text('إضافة'),
        ),
      ],

   ));

    if (confirmed != true || !context.mounted) return null;

  final provider =context.read<CustomersProvider>();
  return provider.addCustomer(
    name: nameController.text.trim(),
    phone: phoneController.text.trim(),
  );

}