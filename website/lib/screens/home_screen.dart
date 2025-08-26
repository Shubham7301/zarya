import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/merchant_provider.dart';
import '../widgets/merchant_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_bar.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantProvider>().fetchMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Zarya',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Icon(
                        Icons.calendar_today,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Book Your Perfect Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomSearchBar(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Consumer<MerchantProvider>(
              builder: (context, provider, child) {
                final categories = ['All', ...provider.getCategories()];
                return CategoryFilter(
                  categories: categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          // Merchants Grid
          Consumer<MerchantProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (provider.error != null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.fetchMerchants();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Filter merchants based on search and category
              var filteredMerchants = provider.merchants;
              
              if (_searchQuery.isNotEmpty) {
                filteredMerchants = provider.searchMerchants(_searchQuery);
              }
              
              if (_selectedCategory != 'All') {
                filteredMerchants = filteredMerchants
                    .where((m) => m.category == _selectedCategory)
                    .toList();
              }

              if (filteredMerchants.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No merchants found',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final merchant = filteredMerchants[index];
                      return MerchantCard(
                        merchant: merchant,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/merchant-detail',
                            arguments: merchant,
                          );
                        },
                      );
                    },
                    childCount: filteredMerchants.length,
                  ),
                ),
              );
            },
          ),

          // Footer
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
