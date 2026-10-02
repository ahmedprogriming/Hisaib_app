import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
import 'package:management_debts_app/models/customer_model.dart';
import 'package:management_debts_app/providers/customers_provider.dart';
import 'package:management_debts_app/widgets/customer_tile.dart';
import 'package:management_debts_app/widgets/showAddCustomerDilog.dart';
import 'package:provider/provider.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
    String _selectedFilter = 'all';
  String _searchQuery = '';

  static const _filters = [
    ('متأخر', AppConstants.statusOverdue),
    ('مسدد', AppConstants.statusPaid),
    ('عليه دين', AppConstants.statusOwing),
    ('الكل', 'all'),
  ];


  @override
  Widget build(BuildContext context) {

        final provider = context.watch<CustomersProvider>();

    var customers = provider.filterByStatus(_selectedFilter);
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim();
      customers = customers
          .where((c) => c.name.contains(query) || c.phone.contains(query))
          .toList();
    }
    

    return Scaffold(
      appBar: AppBar(
       title: const Text('الزبائن'),
      ),
      body: Column(children: [
               Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'ابحث عن زبون...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            
          ),

            SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _filters.map((f) => _filterChip(f.$1, f.$2)).toList(),
            ),
          ),
        const SizedBox(height: 8),
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'لا توجد نتائج مطابقة'
                          : 'لا يوجد زبائن في هذا التصنيف',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: customers.length,
                    itemBuilder: (context, i) => CustomerTile(customer: customers[i]),
                  ),
          ),
      ],),
          floatingActionButton: FloatingActionButton(
        onPressed: () => showAddCustomerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
   Widget _filterChip(String label, String value) {
    final selected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedFilter = value),
      ),
    );
  }
}