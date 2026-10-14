import 'package:flutter/material.dart';
import 'package:management_debts_app/core/constants/app_constsnt.dart';
import 'package:management_debts_app/core/theme/app_colors.dart';
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
     backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'العملاء',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0, // لمنع تغير لون الـ AppBar عند التمرير
      ),
      body: Column(children: [
               Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو رقم الهاتف...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),

            SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) => _filterChip(f.$1, f.$2)).toList(),
            ),
          ),
        const SizedBox(height: 16),
          Expanded(
            child: customers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // مسافة سفلية لتجنب تداخل الـ FAB
                    itemCount: customers.length,
                    itemBuilder: (context, i) => CustomerTile(customer: customers[i]),
                  ),
          ),
      ],),
          floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddCustomerDialog(context),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'إضافة عميل',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        showCheckmark: false, // إخفاء علامة الصح لمظهر أنظف
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        onSelected: (_) => setState(() => _selectedFilter = value),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.people_alt_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'لا توجد نتائج' : 'قائمة العملاء فارغة',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'لم يتم العثور على عملاء يطابقون "$_searchQuery"' 
                : 'انقر على "إضافة عميل" للبدء بإضافة عملائك.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

