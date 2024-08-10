import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';

class GoogleGeminiBloc {
  final String apiKey;

  GoogleGeminiBloc({required this.apiKey});

  Future<String?> analyzeImage(List<int> imageBytes) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt =
        TextPart("""Identifique o medicamento da imagem e dê um resumo prático
             com a menor quantidade de linhas possível, sendo bem objetivo e 
             simples como se estivesse falando com uma pessoa bem idosa, 
             incluindo as informações da bula de como usar e para que serve o medicamento, 
             sem adicionar quaisquer outros pontos que não sejam fatais 
             caso não sejam explicados, caso a pessoa que será medicada não 
             saiba, deixe o aviso de que só pode ser usado sob 
             recomendações médicas.""");
    final imageParts = [
      DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
    ];
    final response = await model.generateContent([
      Content.multi([prompt, ...imageParts])
    ]);

    return response.text;
  }

  Future<String?> refineMedicineName(String explicationMedicine) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final refinePrompt = TextPart(
        "Extrair o nome do remedio da seguinte explicação, apenas o nome: $explicationMedicine");
    final refineResponse = await model.generateContent([
      Content.multi([refinePrompt])
    ]);

    return refineResponse.text;
  }
}
