import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/services/product_service.dart';
import 'package:grocery_app/data/models/product_model.dart';
import 'package:grocery_app/core/widgets/product_card.dart';
import 'package:grocery_app/features/product_detail/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _ctrl;
  Future<List<ProductModel>>? _resultsFuture;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    _loadRecentSearches();
    if (widget.initialQuery.trim().isNotEmpty) {
      _resultsFuture = _search(widget.initialQuery);
      _saveSearchQuery(widget.initialQuery);
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    
    searches.remove(trimmed);
    searches.insert(0, trimmed);
    if (searches.length > 10) searches.removeLast(); // Keep top 10
    
    await prefs.setStringList('recent_searches', searches);
    if (mounted) {
      setState(() => _recentSearches = searches);
    }
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _search(String q) =>
      ProductService.instance.searchProducts(q.trim());

  void _submit(String q) {
    if (q.trim().isEmpty) return;
    _saveSearchQuery(q);
    setState(() => _resultsFuture = _search(q));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
          decoration: const InputDecoration(
            hintText: 'Search products…',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.greyText),
          ),
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primaryGreen),
            onPressed: () => _submit(_ctrl.text),
          ),
        ],
      ),
      body: _resultsFuture == null ? _buildRecentSearches() : FutureBuilder<List<ProductModel>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 72,
                      color: AppColors.greyText.withValues(alpha: 0.35)),
                  const SizedBox(height: 16),
                  const Text('No products found',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText)),
                  const SizedBox(height: 6),
                  Text('Try a different keyword',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.greyText.withValues(alpha: 0.7))),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: results.length,
            itemBuilder: (_, i) => ProductCard(product: results[i]),
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text(
          'Type to start searching',
          style: TextStyle(fontSize: 16, color: AppColors.greyText.withOpacity(0.7)),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, i) {
              final query = _recentSearches[i];
              return ListTile(
                leading: const Icon(Icons.history, color: AppColors.greyText),
                title: Text(query, style: const TextStyle(color: AppColors.darkText)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyText),
                onTap: () {
                  _ctrl.text = query;
                  _submit(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Inline search bar widget with suggestions overlay.
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<ProductModel> _suggestions = [];
  bool _showSuggestions = false;
  List<ProductModel> _allProducts = [];

  @override
  void initState() {
    super.initState();
    // Pre-fetch all products for instant suggestions
    ProductService.instance.getAllProductsOnce().then((list) {
      if (mounted) _allProducts = list;
    });
    _focus.addListener(() {
      if (!_focus.hasFocus) setState(() => _showSuggestions = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    final trimmed = q.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    final matches = _allProducts
        .where((p) => p.name.toLowerCase().contains(trimmed))
        .take(3)
        .toList();
    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _goToResults(String query) {
    _focus.unfocus();
    setState(() => _showSuggestions = false);
    if (query.trim().isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SearchResultsScreen(initialQuery: query.trim()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: AppColors.darkText, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.search,
                  onChanged: _onChanged,
                  onSubmitted: _goToResults,
                  decoration: const InputDecoration(
                    hintText: 'Search Store',
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    setState(() => _showSuggestions = false);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.close, size: 18, color: AppColors.greyText),
                  ),
                ),
            ],
          ),
        ),
        // Suggestions dropdown
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: _suggestions.map((p) {
                return InkWell(
                  onTap: () => _goToResults(p.name),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 16, color: AppColors.greyText),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(p.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const Icon(Icons.north_west,
                            size: 14, color: AppColors.greyText),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
