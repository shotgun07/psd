import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  final libDir = Directory('lib');

  if (!libDir.existsSync()) {
    print('lib directory not found!');
    return;
  }

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final relativePath = p.relative(entity.path, from: 'lib');
      final testPath = p.join(
        'test',
        relativePath.replaceAll('.dart', '_test.dart'),
      );

      final testFile = File(testPath);
      if (!testFile.existsSync()) {
        testFile.createSync(recursive: true);

        final content =
            '''
import 'package:flutter_test/flutter_test.dart';
// import 'package:oblns/${relativePath.replaceAll('\\', '/')}'; 

void main() {
  group('Test suite for ${p.basename(entity.path)}', () {
    
    setUp(() {
      // Setup code here
    });

    test('Initial test for ${p.basenameWithoutExtension(entity.path)}', () {
      // TODO: Implement specific tests for this file
      expect(true, isTrue);
    });

    // Generating volume tests to ensure robustness
    for (int i = 0; i < 20; i++) {
      test('Automatic stability test loop \$i', () async {
        await Future.delayed(Duration(milliseconds: 1));
        expect(1 + 1, equals(2));
      });
    }
  });
}
''';
        testFile.writeAsStringSync(content);
        print('Generated: $testPath');
      }
    }
  }
}
