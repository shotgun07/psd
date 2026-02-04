import 'dart:io';

void main() async {
  final file = File('assets/images/high_res_placeholder.bin');
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  // Target size: ~1.5 GB to add to the existing 600MB
  // Writing in chunks to avoid memory issues
  final targetSize = 1.5 * 1024 * 1024 * 1024;
  final chunkSize = 10 * 1024 * 1024; // 10MB chunks
  final chunks = (targetSize / chunkSize).ceil();

  print('Generating large asset file for performance testing...');
  final buffer = List.filled(chunkSize, 0);

  final sink = file.openWrite();
  for (int i = 0; i < chunks; i++) {
    // Fill with random byte to prevent compression from nullifying size
    // Just using a consistent byte is faster and sufficient for "weight"
    sink.add(buffer);
    if (i % 10 == 0) {
      print('Progress: ${(i / chunks * 100).toStringAsFixed(1)}%');
    }
  }

  await sink.close();
  print(
    'Done! Created ${file.path} with size ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
  );
}
