import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для работы с In-App Purchase
class InAppPurchaseService {
  static const String _productId = 'com.inqrypt.supporter.badge';
  static const String _supporterKey = 'is_supporter';
  
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _available = false;
  ProductDetails? _product;
  
  // Публичный поток для уведомления об изменении статуса Supporter
  final StreamController<bool> _supporterController = StreamController<bool>.broadcast();
  Stream<bool> get supporterStream => _supporterController.stream;
  
  // Поток ошибок покупок
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;
  
  /// Инициализация сервиса
  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    
    if (_available) {
      // Запрашиваем информацию о продукте
      final response = await _iap.queryProductDetails({_productId});
      if (response.error == null && response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
      }
      
      // Подписываемся на обновления покупок
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onError: (_) {
          if (!_errorController.isClosed) {
            _errorController.add('purchase_stream_error');
          }
        },
      );
    }
  }
  
  /// Получить статус Supporter
  Future<bool> isSupporter() async {
    try {
      final value = await _storage.read(key: _supporterKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
  
  /// Получить информацию о продукте
  ProductDetails? get product => _product;
  
  /// Доступны ли покупки
  bool get isAvailable => _available;
  
  /// Совершить покупку
  Future<void> buySupporter() async {
    if (_product == null) return;
    
    final purchaseParam = PurchaseParam(productDetails: _product!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  /// Восстановить покупки
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
  
  /// Обработка обновлений покупок
  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _finishTransaction(purchase);
          _markAsSupporter();
          break;
        case PurchaseStatus.pending:
          // ничего не делаем — UI показывает индикатор
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          // Завершаем при необходимости, но не помечаем Supporter
          _finishTransaction(purchase);
          if (!_errorController.isClosed) {
            _errorController.add(purchase.status.name);
          }
          break;
      }
    }
  }
  
  /// Завершить транзакцию
  Future<void> _finishTransaction(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }
  
  /// Отметить как Supporter
  Future<void> _markAsSupporter() async {
    await _storage.write(key: _supporterKey, value: 'true');
    if (!_supporterController.isClosed) {
      _supporterController.add(true);
    }
  }
  
  /// Освободить ресурсы
  void dispose() {
    _subscription?.cancel();
    _supporterController.close();
    _errorController.close();
  }
} 