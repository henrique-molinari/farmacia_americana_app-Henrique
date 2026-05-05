import 'dart:typed_data';

import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_stock_product_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/attendant_products_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/repositories/product_ai_repository.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_profile_data_store.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum AttendantStockControlMode { list, form }

class AttendantProductRegistrationViewModel extends ChangeNotifier {
  AttendantProductRegistrationViewModel({
    AttendantProductsRepository? repository,
    ProductAiRepository? productAiRepository,
    AttendantProfileDataStore? profileStore,
    ImagePicker? imagePicker,
  })  : _repository = repository ?? AttendantProductsRepository.instance,
        _productAiRepository = productAiRepository ?? ProductAiRepository(),
        _profileStore = profileStore ?? AttendantProfileDataStore.instance,
        _imagePicker = imagePicker ?? ImagePicker() {
    dateController.text = _formatDate(_registrationDate);
    searchController.addListener(_applyProductFilters);
    refreshProducts();
  }

  final AttendantProductsRepository _repository;
  final ProductAiRepository _productAiRepository;
  final AttendantProfileDataStore _profileStore;
  final ImagePicker _imagePicker;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = const [
    'Analgésicos',
    'Antibióticos',
    'Beleza',
    'Higiene',
    'Medicamentos',
    'Suplementos',
    'Vitaminas',
  ];

  String? _editingProductId;
  String? _selectedCategory;
  String? _existingImageUrl;
  String? _imageExtension;
  Uint8List? _selectedImageBytes;
  DateTime _registrationDate = DateTime.now();
  bool _isControlled = false;
  bool _isSaving = false;
  bool _isLoadingProducts = false;
  bool _isGeneratingDescription = false;
  bool _loadedProduct = false;
  String? _productsErrorMessage;
  AttendantStockControlMode _mode = AttendantStockControlMode.list;
  List<AttendantStockProduct> _products = [];
  List<AttendantStockProduct> _filteredProducts = [];

  String? get editingProductId => _editingProductId;
  String? get selectedCategory => _selectedCategory;
  String? get existingImageUrl => _existingImageUrl;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  DateTime get registrationDate => _registrationDate;
  bool get isControlled => _isControlled;
  bool get isSaving => _isSaving;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isGeneratingDescription => _isGeneratingDescription;
  String? get productsErrorMessage => _productsErrorMessage;
  AttendantStockControlMode get mode => _mode;
  List<AttendantStockProduct> get products => _filteredProducts;
  AttendantProfileData get profile => _profileStore.data;
  bool get isEditing => _editingProductId != null && _editingProductId!.isNotEmpty;

  void loadEditingProduct(Product? product) {
    if (_loadedProduct || product == null) return;
    _loadedProduct = true;

    _editingProductId = product.id;
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toStringAsFixed(2).replaceAll('.', ',');
    stockController.text = '0';
    _selectedCategory = _normalizeCategory(product.category);
    _existingImageUrl = product.imageUrl.isEmpty ? null : product.imageUrl;
    _mode = AttendantStockControlMode.form;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _isLoadingProducts = true;
    _productsErrorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProducts();
      _applyProductFilters(notify: false);
    } on Object catch (error) {
      _products = [];
      _filteredProducts = [];
      _productsErrorMessage = 'Não foi possível carregar o estoque: $error';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  void startNewProduct() {
    _clearForm();
    _mode = AttendantStockControlMode.form;
    notifyListeners();
  }

  void editProduct(AttendantStockProduct product) {
    _editingProductId = product.id;
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price.toStringAsFixed(2).replaceAll('.', ',');
    stockController.text = product.stockQuantity.toString();
    _selectedCategory = _normalizeCategory(product.category) ?? product.category;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
    _existingImageUrl = product.imageUrl.isEmpty ? null : product.imageUrl;
    _selectedImageBytes = null;
    _imageExtension = null;
    _registrationDate = product.registrationDate ?? DateTime.now();
    dateController.text = _formatDate(_registrationDate);
    _isControlled = product.isControlled;
    _mode = AttendantStockControlMode.form;
    notifyListeners();
  }

  void showProductList() {
    _mode = AttendantStockControlMode.list;
    _clearForm();
    notifyListeners();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setControlled(bool value) {
    _isControlled = value;
    notifyListeners();
  }

  void setRegistrationDate(DateTime date) {
    _registrationDate = date;
    dateController.text = _formatDate(date);
    notifyListeners();
  }

  Future<ProductImagePickResult> pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) {
      return const ProductImagePickResult(
        success: false,
        message: 'Permissão negada para acessar a imagem.',
      );
    }

    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (pickedFile == null) {
      return const ProductImagePickResult(success: false);
    }

    final bytes = await pickedFile.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      return const ProductImagePickResult(
        success: false,
        message: 'Selecione uma imagem de até 5MB.',
      );
    }

    _selectedImageBytes = bytes;
    _imageExtension = pickedFile.name.split('.').last;
    notifyListeners();

    return const ProductImagePickResult(success: true);
  }

  Future<ProductSaveResult> saveProduct() async {
    if (_selectedCategory == null) {
      return const ProductSaveResult(
        success: false,
        message: 'Selecione uma categoria.',
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _repository.saveProduct(
        payload: AttendantProductPayload(
          id: _editingProductId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: _selectedCategory!,
          price: parsePrice(priceController.text),
          stockQuantity: int.parse(stockController.text.trim()),
          registrationDate: _registrationDate,
          isControlled: _isControlled,
        ),
        imageBytes: _selectedImageBytes,
        imageExtension: _imageExtension,
      );

      final wasEditing = isEditing;
      await refreshProducts();
      _clearForm();
      _mode = AttendantStockControlMode.list;

      return ProductSaveResult(
        success: true,
        message: wasEditing
            ? 'Produto atualizado com sucesso.'
            : 'Produto cadastrado com sucesso.',
      );
    } on Object catch (error) {
      return ProductSaveResult(
        success: false,
        message: 'Não foi possível salvar o produto: $error',
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ProductSaveResult> deleteCurrentProduct() async {
    final productId = _editingProductId;
    if (productId == null || productId.isEmpty) {
      return const ProductSaveResult(
        success: false,
        message: 'Selecione um produto para deletar.',
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _repository.deleteProduct(productId);
      await refreshProducts();
      _clearForm();
      _mode = AttendantStockControlMode.list;
      return const ProductSaveResult(
        success: true,
        message: 'Produto deletado com sucesso.',
      );
    } on Object catch (error) {
      return ProductSaveResult(
        success: false,
        message: 'Não foi possível deletar o produto: $error',
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ProductDescriptionGenerationResult> generateProductDescription() async {
    final productName = nameController.text.trim();
    if (productName.isEmpty) {
      return const ProductDescriptionGenerationResult(
        success: false,
        message: 'Informe o nome do produto antes de gerar a descrição.',
      );
    }

    _isGeneratingDescription = true;
    notifyListeners();

    try {
      final description =
          await _productAiRepository.generateDescription(productName);

      if (description.trim().isEmpty) {
        return const ProductDescriptionGenerationResult(
          success: false,
          message: 'A IA não retornou uma descrição válida.',
        );
      }

      descriptionController.text = description;

      return const ProductDescriptionGenerationResult(
        success: true,
        message: 'Descrição gerada com sucesso.',
      );
    } on Object {
      return const ProductDescriptionGenerationResult(
        success: false,
        message: 'Não foi possível gerar a descrição. Tente novamente.',
      );
    } finally {
      _isGeneratingDescription = false;
      notifyListeners();
    }
  }

  String? requiredField(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? validatePrice(String? value) {
    final requiredError = requiredField(value, 'Informe o preço.');
    if (requiredError != null) return requiredError;

    final price = parsePrice(value!);
    if (price <= 0) return 'Informe um preço válido.';
    return null;
  }

  String? validateStock(String? value) {
    final requiredError = requiredField(value, 'Informe o estoque.');
    if (requiredError != null) return requiredError;

    final stock = int.tryParse(value!.trim());
    if (stock == null || stock < 0) return 'Informe um estoque válido.';
    return null;
  }

  double parsePrice(String value) {
    final normalized = value
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalized) ?? 0;
  }

  void _applyProductFilters({bool notify = true}) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredProducts = List<AttendantStockProduct>.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList(growable: false);
    }

    if (notify) notifyListeners();
  }

  void _clearForm() {
    _editingProductId = null;
    _selectedCategory = null;
    _existingImageUrl = null;
    _imageExtension = null;
    _selectedImageBytes = null;
    _registrationDate = DateTime.now();
    _isControlled = false;
    _loadedProduct = false;
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();
    dateController.text = _formatDate(_registrationDate);
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted || status.isLimited;
    }

    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return true;

    final storage = await Permission.storage.request();
    return storage.isGranted || storage.isLimited;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String? _normalizeCategory(String category) {
    final lowerCategory = category.toLowerCase();
    for (final option in categories) {
      if (option.toLowerCase() == lowerCategory) return option;
    }
    return null;
  }

  @override
  void dispose() {
    searchController.removeListener(_applyProductFilters);
    searchController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    dateController.dispose();
    _productAiRepository.dispose();
    super.dispose();
  }
}

class ProductImagePickResult {
  final bool success;
  final String? message;

  const ProductImagePickResult({
    required this.success,
    this.message,
  });
}

class ProductSaveResult {
  final bool success;
  final String message;

  const ProductSaveResult({
    required this.success,
    required this.message,
  });
}

class ProductDescriptionGenerationResult {
  final bool success;
  final String message;

  const ProductDescriptionGenerationResult({
    required this.success,
    required this.message,
  });
}
