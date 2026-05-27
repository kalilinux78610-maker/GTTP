import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/certificates/data/models/certificate_model.dart';
import 'package:gttp/features/certificates/presentation/providers/certificates_provider.dart';

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> {
  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(filteredCertificatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Green Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF209E5A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'My Certificates',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  certificatesAsync.when(
                    data: (certs) => Text(
                      "You've earned ${certs.length} certificates",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, _) => const SizedBox(),
                  ),
                ],
              ),
            ),
            
            // Certificates List
            Expanded(
              child: certificatesAsync.when(
                data: (certificates) {
                  if (certificates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No certificates found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(certificatesNotifierProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        24, 24, 24,
                        MediaQuery.of(context).padding.bottom + 24,
                      ),
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        return _CertificateCard(certificate: certificates[index]);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF209E5A)),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load certificates',
                        style: TextStyle(fontSize: 16, color: Colors.red.shade400),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.read(certificatesNotifierProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const _CertificateCard({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Orange Ribbon Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech_outlined,
              color: Color(0xFFE65C00),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title and Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  certificate.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3A4A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Details
          _buildDetailRow('Course:', certificate.courseName),
          const SizedBox(height: 6),
          _buildDetailRow('Provider:', certificate.schoolName), // using schoolName as provider
          const SizedBox(height: 6),
          _buildDetailRow('Issued:', certificate.issuedDate),
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF357AB6),
                    side: const BorderSide(color: Color(0xFF357AB6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2A3A4A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
