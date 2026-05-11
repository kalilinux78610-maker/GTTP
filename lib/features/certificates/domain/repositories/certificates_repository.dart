import 'package:gttp/features/certificates/data/models/certificate_model.dart';

abstract class CertificatesRepository {
  Future<List<CertificateModel>> getCertificates();
  Future<CertificateModel> getCertificateDetail(String id);
}
