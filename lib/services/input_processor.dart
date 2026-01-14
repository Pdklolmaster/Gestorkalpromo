import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class InputProcessor {
  final ImagePicker _imagePicker = ImagePicker();

  /// Captura foto e retorna informação básica (OCR removido para compatibilidade)
  Future<Map<String, dynamic>?> processImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo == null) return null;
      
      // Retorna dados básicos - usuário deve preencher manualmente
      return {
        'title': 'Foto de comprovante',
        'amount': 0.0,
        'category': 'Necessidade',
        'rawText': 'Imagem capturada: ${photo.name}',
      };
    } catch (e) {
      print('Erro ao capturar foto: $e');
      return null;
    }
  }

  /// Seleciona imagem da galeria e retorna informação básica
  Future<Map<String, dynamic>?> processImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) return null;
      
      return {
        'title': 'Comprovante',
        'amount': 0.0,
        'category': 'Necessidade',
        'rawText': 'Imagem selecionada: ${image.name}',
      };
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      return null;
    }
  }

  /// Processa arquivo PDF
  Future<Map<String, dynamic>?> processPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return null;

      String fileName = result.files.single.name;
      
      return {
        'title': fileName.replaceAll('.pdf', ''),
        'amount': 0.0,
        'category': 'Necessidade',
        'rawText': 'PDF: $fileName',
      };
    } catch (e) {
      print('Erro ao selecionar PDF: $e');
      return null;
    }
  }

  /// Processa texto livre digitado pelo usuário
  Map<String, dynamic> processText(String text) {
    Map<String, dynamic> result = {
      'title': '',
      'amount': 0.0,
      'category': 'Necessidade',
      'date': DateTime.now(),
    };

    // Exemplos de entrada:
    // "Conta luz 220 reais"
    // "Mercado 150"
    // "Netflix 39.90"

    // Extrai valores
    RegExp valuePattern = RegExp(r'(\d+[.,]?\d*)\s*(?:reais?|R\$)?');
    var valueMatch = valuePattern.firstMatch(text);
    if (valueMatch != null) {
      String valueStr = valueMatch.group(1)!;
      result['amount'] = double.tryParse(valueStr.replaceAll(',', '.')) ?? 0.0;
    }

    // Extrai dia do mês se mencionado
    RegExp dayPattern = RegExp(r'dia\s*(\d+)');
    var dayMatch = dayPattern.firstMatch(text);
    if (dayMatch != null) {
      int day = int.tryParse(dayMatch.group(1)!) ?? DateTime.now().day;
      result['date'] = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        day.clamp(1, 31),
      );
    }

    // Remove o valor do texto para obter o título
    String title = text.replaceAll(valuePattern, '').trim();
    title = title.replaceAll(dayPattern, '').trim();
    title = title.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove palavras comuns do final
    title = title.replaceAll(RegExp(r'\s+(todo|dia)\s*$', caseSensitive: false), '');
    
    result['title'] = title.isEmpty ? 'Transação' : title;

    // Categoriza automaticamente baseado em palavras-chave
    String lowerText = text.toLowerCase();
    if (lowerText.contains('luz') || lowerText.contains('água') || 
        lowerText.contains('aluguel') || lowerText.contains('mercado') ||
        lowerText.contains('farmácia')) {
      result['category'] = 'Necessidade';
    } else if (lowerText.contains('netflix') || lowerText.contains('cinema') ||
               lowerText.contains('restaurante') || lowerText.contains('viagem')) {
      result['category'] = 'Desejos Lazer';
    } else if (lowerText.contains('investimento') || lowerText.contains('poupança') ||
               lowerText.contains('reserva')) {
      result['category'] = 'Investimento';
    }

    return result;
  }

  void dispose() {
    // Nada a limpar
  }
}
