import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineMapService {
  static const String _tileBoxName = 'map_tiles';
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_tileBoxName);
  }

  TileProvider get tileProvider => _CachedTileProvider(_box);
}

class _CachedTileProvider extends TileProvider {
  final Box? box;
  final http.Client _client = http.Client();

  _CachedTileProvider(this.box);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return _CachedImageProvider(url, box, _client);
  }

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final z = coordinates.z.round();
    final x = coordinates.x.round();
    final y = coordinates.y.round();
    return options.urlTemplate!
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString());
  }
}

class _CachedImageProvider extends ImageProvider<_CachedImageProvider> {
  final String url;
  final Box? box;
  final http.Client client;

  _CachedImageProvider(this.url, this.box, this.client);

  @override
  Future<_CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      _CachedImageProvider key,
      ImageDecoderCallback decode,
      ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<String>('URL', url),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
      _CachedImageProvider key,
      ImageDecoderCallback decode,
      ) async {
    if (box != null && box!.containsKey(key.url)) {
      final List<int> bytes = List<int>.from(box!.get(key.url));
      if (bytes.isNotEmpty) {
        final buffer = await ui.ImmutableBuffer.fromUint8List(
          Uint8List.fromList(bytes),
        );
        return decode(buffer);
      }
    }

    try {
      final response = await client.get(Uri.parse(key.url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        box?.put(key.url, bytes.toList());
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      } else {
        throw Exception('Failed to load tile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tile and no cache');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _CachedImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}

final offlineMapServiceProvider = Provider<OfflineMapService>((ref) {
  return OfflineMapService()..init();
});