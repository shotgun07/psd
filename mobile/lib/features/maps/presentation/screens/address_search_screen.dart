import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/widgets/glass_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
 
import 'package:google_fonts/google_fonts.dart';

class AddressSearchScreen extends ConsumerStatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = []; // Real results from geocoding

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 12,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'أدخل وجهتك...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Color(0xFFe94560)),
                ),
                onChanged: (value) async {
                  if (value.length > 2) {
                    final results = await _searchAddresses(value);
                    setState(() {
                      _searchResults = results;
                    });
                  } else {
                    setState(() => _searchResults = []);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'ابحث عن عنوان',
          style: GoogleFonts.cairo(color: Colors.white54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFe94560),
              size: 20,
            ),
          ),
          title: Text(
            _searchResults[index]['display_name'] ?? '',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          subtitle: Text(
            '${_searchResults[index]['address'] ?? ''}',
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
          ),
          onTap: () {
            // Return selected address details
            Navigator.pop(context, {
              'display_name': _searchResults[index]['display_name'],
              'lat': double.tryParse(_searchResults[index]['lat'] ?? ''),
              'lon': double.tryParse(_searchResults[index]['lon'] ?? ''),
            });
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _searchAddresses(String query) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '6',
      });

      final resp = await http.get(uri, headers: {'User-Agent': 'oblns-app/1.0'});
      if (resp.statusCode != 200) return [];
      final List data = json.decode(resp.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
