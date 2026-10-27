const metaInicial = 100.0;
const pasoMeta = 10.0;
const metaMinima = 10.0;

double ajustarMeta(double actual, double cambio) {
  final resultado = actual + cambio;
  return resultado < metaMinima ? metaMinima : resultado;
}

double avanceDeMeta({required double total, required double meta}) {
  if (meta <= 0) return 0.0;
  final fraccion = total / meta;
  return fraccion.clamp(0.0, 1.0).toDouble();
}
