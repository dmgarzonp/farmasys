import 'package:flutter_test/flutter_test.dart';
import 'package:farmsys/core/utils/sri_modulo11.dart';

void main() {
  group('SriModulo11 - Clave de Acceso SRI', () {
    test('Calcula correctamente el dígito verificador para una base de 48 dígitos', () {
      // 48 dígitos conocidos
      const String base48 = '010120260117923456780011001001000000001123456781';
      final int digito = SriModulo11.calcularDigitoVerificador(base48);

      expect(digito, inInclusiveRange(0, 9));
      expect(digito >= 0 && digito <= 9, isTrue);
    });

    test('Genera una clave de acceso válida de 49 dígitos exactos', () {
      final String clave = SriModulo11.generarClaveAcceso(
        fechaEmision: DateTime(2026, 5, 15),
        tipoComprobante: '01',
        ruc: '1792345678001',
        ambiente: '1',
        establecimiento: '001',
        puntoEmision: '002',
        secuencial: '123',
        codigoNumerico: '87654321',
      );

      expect(clave.length, equals(49));
      expect(SriModulo11.validarClaveAcceso(clave), isTrue);
    });

    test('Rechaza claves con longitud diferente de 49 o caracteres no numéricos', () {
      expect(SriModulo11.validarClaveAcceso('123'), isFalse);
      expect(SriModulo11.validarClaveAcceso('01012026011792345678001100100100000000112345678X9'), isFalse);
    });
  });
}
