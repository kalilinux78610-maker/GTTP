import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/certificates/data/models/certificate_model.dart';
import 'package:gttp/features/certificates/presentation/providers/certificates_provider.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:gttp/features/courses/presentation/screens/material_viewer_screen.dart';
import 'package:gttp/features/courses/presentation/screens/offline_pdf_viewer_screen.dart';

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> {
  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(filteredCertificatesProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          // Blue Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16, 
              left: 24, 
              right: 24, 
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF3286C9),
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
                loading: () => Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      24, 24, 24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(height: 100, color: Colors.grey),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(height: 20, width: 150, color: Colors.grey),
                                        Container(height: 20, width: 60, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(height: 14, width: 100, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Container(height: 14, width: 200, color: Colors.grey),
                                    const SizedBox(height: 6),
                                    Container(height: 14, width: 250, color: Colors.grey),
                                    const SizedBox(height: 6),
                                    Container(height: 14, width: 120, color: Colors.grey),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(child: Container(height: 40, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)))),
                                        const SizedBox(width: 12),
                                        Expanded(child: Container(height: 40, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
      floatingActionButton: roleAsync.whenOrNull(
        data: (role) {
          if (role.canAccessSchoolNetwork) {
            return FloatingActionButton.extended(
              onPressed: () => context.push('/dashboard/certificates/builder'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimaryContainer),
              label: Text(
                'Builder',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const _CertificateCard({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section with Ribbon
            Container(
              height: 100,
              color: colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Icon(
                Icons.military_tech_outlined,
                color: colorScheme.primary,
                size: 40,
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          certificate.title.isNotEmpty 
                            ? (certificate.title == certificate.type ? 'Certificate of ${certificate.type}' : certificate.title) 
                            : 'Certificate of ${certificate.type ?? 'Completion'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: certificate.type?.toLowerCase() == 'participation'
                              ? const Color(0xFF3B82F6) // Blue for Participation
                              : const Color(0xFF10B981), // Green for Completion
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          certificate.type ?? 'Completion',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Subtitle
                  Text(
                    certificate.schoolName,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details
                  _buildDetailRow(context, 'Course:', certificate.courseName),
                  const SizedBox(height: 6),
                  _buildDetailRow(context, 'Module:', certificate.description ?? 'Module 1: Introduction to Tourism'),
                  const SizedBox(height: 6),
                  _buildDetailRow(context, 'Issued:', certificate.issuedDate),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _viewCertificate(context, certificate);
                          },
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                          label: const Text('View'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
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
                          onPressed: () {
                            _handleCertificate(context, certificate);
                          },
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0F172A),
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
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _viewCertificate(BuildContext context, CertificateModel certificate) async {
    if (certificate.base64Pdf != null && certificate.base64Pdf!.isNotEmpty) {
      try {
        final bytes = base64Decode(certificate.base64Pdf!);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/certificate_${certificate.id}.pdf');
        await file.writeAsBytes(bytes);
        
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OfflinePdfViewerScreen(
                title: certificate.title,
                localPath: file.path,
              ),
            ),
          );
        }
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open certificate: $e')),
          );
        }
      }
    }

    final urlString = certificate.certificateUrl;
    if (urlString != null && urlString.isNotEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MaterialViewerScreen(
              title: certificate.title,
              url: urlString,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No certificate available to view')),
        );
      }
    }
  }
  
  Future<void> _handleCertificate(BuildContext context, CertificateModel certificate) async {
    if (certificate.base64Pdf != null && certificate.base64Pdf!.isNotEmpty) {
      try {
        final bytes = base64Decode(certificate.base64Pdf!);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/certificate_${certificate.id}.pdf');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)],
          text: 'My Certificate for ${certificate.courseName}',
        ));
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open certificate: $e')),
          );
        }
      }
    }

    final urlString = certificate.certificateUrl;
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.tryParse(urlString);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the certificate link')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No certificate available')),
        );
      }
    }
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
