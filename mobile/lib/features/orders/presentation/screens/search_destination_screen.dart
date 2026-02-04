import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:oblns/core/services/geocoding_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class SearchDestinationScreen extends ConsumerStatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  ConsumerState<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState
    extends ConsumerState<SearchDestinationScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final FocusNode _destFocus = FocusNode();
  final GeocodingService _geocoder = GeocodingService();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'موقعي الحالي';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _destFocus.requestFocus();
    });

    _destController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_destController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await _geocoder.searchPlaces(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchInputs(),
          const SizedBox(height: 24),
          Expanded(child: _buildSuggestions()),
        ],
      ),
    );
  }

  Widget _buildSearchInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInputField(
            controller: _pickupController,
            icon: Icons.my_location,
            iconColor: Colors.green,
            hint: 'نقطة الانطلاق',
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _destController,
            focusNode: _destFocus,
            icon: Icons.location_on,
            iconColor: const Color(0xFFe94560),
            hint: 'إلى أين تريد الذهاب؟',
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required IconData icon,
    required Color iconColor,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round())),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.cairo(
                  color: Colors.white.withAlpha((0.4 * 255).round()),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white30, size: 18),
              onPressed: () {
                controller.clear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    // Show loading spinner
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFe94560)),
      );
    }

    // Show no results message
    if (_searchResults.isEmpty && _destController.text.isNotEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: GoogleFonts.cairo(color: Colors.white60),
        ),
      );
    }

    // Use search results or defaults
    final suggestions = _searchResults.isNotEmpty
        ? _searchResults
        : [
            {
              'title': 'ميدان الشهداء',
              'subtitle': 'وسط البلد، طرابلس',
              'lat': 32.8872,
              'lon': 13.1913,
            },
            {
              'title': 'مطار معيتيقة',
              'subtitle': 'طريق المطار',
              'lat': 32.8945,
              'lon': 13.2760,
            },
            {
              'title': 'جامعة طرابلس',
              'subtitle': 'الفرناج',
              'lat': 32.8609,
              'lon': 13.1796,
            },
          ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        final title = (item['name'] ?? item['title']) as String;
        final subtitle = (item['displayName'] ?? item['subtitle']) as String;
        final lat = item['lat'] as double;
        final lon = item['lon'] as double;

        return _buildSuggestionItem(
              title: title,
              subtitle: subtitle,
              lat: lat,
              lon: lon,
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn()
            .slideX(begin: 0.1);
      },
    );
  }

  Widget _buildSuggestionItem({
    required String title,
    required String subtitle,
    required double lat,
    required double lon,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/trip-confirm',
          arguments: {
            'pickupLatLng': const LatLng(32.8872, 13.1913),
            'pickupAddress': _pickupController.text,
            'destLatLng': LatLng(lat, lon),
            'destAddress': title,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFe94560).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFe94560),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    _destFocus.dispose();
    super.dispose();
  }
}
