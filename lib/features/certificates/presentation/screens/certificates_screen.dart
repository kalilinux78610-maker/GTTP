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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(filteredCertificatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A3A4A), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Certificates',
          style: TextStyle(
            color: Color(0xFF2A3A4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: () => ref.read(certificatesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                ref.read(certificateSearchQueryProvider.notifier).updateQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search certificates...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          ref.read(certificateSearchQueryProvider.notifier).updateQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
                          _searchQuery.isEmpty
                              ? 'No certificates found'
                              : 'No certificates match your search',
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
                    padding: const EdgeInsets.all(16),
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      return _CertificateCard(certificate: certificates[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65C00)),
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
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const _CertificateCard({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to detail screen
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: certificate.isValid
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        certificate.isValid
                            ? Icons.verified
                            : Icons.verified_outlined,
                        color: certificate.isValid
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3A4A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            certificate.studentName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: certificate.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Details Row
                Row(
                  children: [
                    _DetailItem(
                      icon: Icons.school_outlined,
                      label: certificate.schoolName,
                    ),
                    const SizedBox(width: 16),
                    _DetailItem(
                      icon: Icons.book_outlined,
                      label: certificate.courseName,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _DetailItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Issued: ${certificate.issuedDate}',
                    ),
                    if (certificate.expiryDate.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      _DetailItem(
                        icon: Icons.event_outlined,
                        label: 'Expires: ${certificate.expiryDate}',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isValid = status.toLowerCase() == 'valid' || status.toLowerCase() == 'active';
    final isExpired = status.toLowerCase() == 'expired';

    Color bgColor;
    Color textColor;
    if (isValid) {
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF059669);
    } else if (isExpired) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
    } else {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
