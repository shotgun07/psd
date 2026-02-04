# الإصلاحات المطبقة - OBLNS

## ملخص التغييرات

### 1. إصلاح شاشات AR (ملاحة الواقع المعزز)

**المشكلة:** استخدام `arcore_flutter_plugin` غير المتوافق مع null-safety والغير مضاف في pubspec.

**الحل:**
- استبدال شاشات AR بشاشات خرائط تعتمد على `flutter_map` و `latlong2` (موجودة بالفعل في المشروع)
- `ar_navigation_screen.dart`: شاشة ملاحة تعرض خريطة OSM مع نقطة الوجهة
- `ar_navigation_order_screen.dart`: شاشة ملاحة الطلبات تعرض قائمة تعليمات أو خريطة
- إزالة `ar_flutter_plugin` من pubspec لتقليل التبعيات

### 2. إصلاح Chat Repository

**المشكلة:** عدم توافق المعاملات (`sendMessage` يستخدم `text` بدلاً من `message`) وخطأ مقارنة الأنواع في `watchMessages`.

**الحل:**
- توحيد معامل `sendMessage` ليستخدم `message` كما في الواجهة
- إصلاح مقارنة `chat_id` باستخدام `.toString()` لمنع أخطاء المقارنة
- تحويل `payload` إلى `Map<String, dynamic>` بشكل آمن

### 3. إصلاح اختبارات AppWrite

**المشكلة:** استخدام `Document.fromMap` و `DocumentList.fromMap` و `Execution.fromMap` غير المتوافقة مع Appwrite SDK 20.

**الحل:**
- استبدالها بفئات وهمية محلية: `_FakeDocument`, `_FakeDocumentList`, `_FakeExecution`
- تحديث اختبار `addFunds` ليتوافق مع التنفيذ الفعلي:
  - `functionId: 'walletSync'` بدلاً من `'paymentCallback'`
  - `body:` بدلاً من `data:`
- تحديث بيانات الاختبار لتتوافق مع `TransactionModel` (id, user_id, status, created_at)

### 4. إصلاح ArNavigationService

**المشكلة:** احتمال ظهور أخطاء عند تحويل JSON للـ `ArInstruction`.

**الحل:**
- استخدام تحويل آمن: `i['step'] as String? ?? ''` و `i['imageOverlay'] as String? ?? ''`

### 5. تنظيف pubspec

- إزالة `ar_flutter_plugin` لتقليل حجم المشروع والاعتماد على `flutter_map` للملاحة

---

## خطوات ما بعد التطبيق

1. **توليد Mocks للاختبارات:**
   ```bash
   cd mobile
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **تشغيل الاختبارات:**
   ```bash
   flutter test
   ```

3. **تشغيل التطبيق للتأكد:**
   ```bash
   flutter run
   ```

4. **(اختياري) تطبيق إصلاحات Dart التلقائية:**
   ```bash
   dart fix --apply
   ```

---

## الملفات المعدلة

| الملف | التغيير |
|-------|---------|
| `mobile/lib/features/maps/presentation/screens/ar_navigation_screen.dart` | إعادة كتابة بالكامل باستخدام flutter_map |
| `mobile/lib/features/maps/presentation/screens/ar_navigation_order_screen.dart` | إعادة كتابة بالكامل |
| `mobile/lib/features/chat/infrastructure/appwrite_chat_repository.dart` | إصلاح sendMessage و watchMessages |
| `mobile/lib/modules/logistics/ar_navigation/ar_navigation_service.dart` | تحويل آمن لـ JSON |
| `mobile/pubspec.yaml` | إزالة ar_flutter_plugin |
| `mobile/test/features/wallet/infrastructure/appwrite_wallet_repository_test.dart` | استخدام فئات وهمية بدلاً من Appwrite models |
