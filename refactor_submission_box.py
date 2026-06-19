import re

with open('lib/features/courses/presentation/screens/course_module_detail_screen.dart', 'r') as f:
    content = f.read()

# 1. Replace the single submission box with the new logic
target_box = '''          if (widget.requirement.studentName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student Submission:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF181C1F),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.requirement.fileUrl != null
                            ? () => openCourseUrl(context, widget.requirement.fileUrl)
                            : null,
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: const Text('View File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF398FDE),
                          side: const BorderSide(color: Color(0xFF398FDE)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Submitted by: \',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  if (widget.requirement.rollNo != null ||
                      widget.requirement.className != null)
                    Text(
                      [
                        if (widget.requirement.rollNo != null)
                          'Roll No: \',
                        if (widget.requirement.className != null)
                          'Class: \',
                      ].join(' | '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  const Text(
                    'Institute: Delhi Public School',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  if (widget.requirement.submittedAt != null)
                    Text(
                      'Submitted: \',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (approved) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1F9254)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Color(0xFF1F9254), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Approved by Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F9254),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Reviewed by: Priya Mehta',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ] else if (pending && widget.requirement.studentName != null)
                    widget.isStudent 
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF5C842)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'View only - Approval pending from coordinator',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB45309),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isSubmitting || widget.requirement.submissionId == null ? null : () => _reviewSubmission('completed'),
                                icon: _isSubmitting 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check_circle_outline, size: 20),
                                label: const Text('Approve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F9254),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isSubmitting || widget.requirement.submissionId == null ? null : () => _reviewSubmission('rejected'),
                                icon: _isSubmitting 
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.cancel_outlined, size: 20),
                                label: const Text('Reject', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],'''

replacement_box = '''          if (widget.requirement.studentName != null) ...[
            _buildAdminSubmissionBox(
              submissionId: widget.requirement.submissionId ?? '',
              studentName: widget.requirement.studentName,
              rollNo: widget.requirement.rollNo,
              className: widget.requirement.className,
              fileUrl: widget.requirement.fileUrl,
              submittedAt: widget.requirement.submittedAt,
              approved: approved,
              pending: pending,
              isStudentView: widget.isStudent,
            ),
          ] else if (!widget.isStudent) ...[
            Consumer(
              builder: (context, ref, _) {
                final cId = GoRouterState.of(context).pathParameters['id'] ?? '';
                final mId = GoRouterState.of(context).pathParameters['moduleId'] ?? '';
                // Use watch to get the future provider
                final pendingAsync = ref.watch(coursePendingSubmissionsProvider(cId));
                
                return pendingAsync.when(
                  data: (submissions) {
                    final reqSubs = submissions.where((s) => s['module_id'] == mId && (s['submoduleId'] == widget.requirement.id || s['submoduleId'] == null)).toList();
                    if (reqSubs.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      children: reqSubs.map((sub) {
                        final isApproved = sub['status']?.toString().toLowerCase() == 'completed' || sub['status']?.toString().toLowerCase() == 'approved';
                        final isPending = sub['status']?.toString().toLowerCase() == 'pending';
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildAdminSubmissionBox(
                            submissionId: sub['id']?.toString() ?? '',
                            studentName: sub['studentName']?.toString() ?? 'Unknown Student',
                            rollNo: sub['studentId']?.toString(), // Use studentId as fallback for rollNo
                            className: null,
                            fileUrl: null, // Depending on the API, maybe add file URL here
                            submittedAt: sub['submittedAt']?.toString(),
                            approved: isApproved,
                            pending: isPending,
                            isStudentView: false,
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],'''

content = content.replace(target_box, replacement_box)

# 2. Update _reviewSubmission method signature to accept submissionId
target_review = '''  Future<void> _reviewSubmission(String status) async {
    if (widget.requirement.submissionId == null) return;
    
    setState(() => _isSubmitting = true);
    try {
      await ref.read(coursesRemoteDataSourceProvider).reviewSubmission(
        widget.requirement.submissionId!, 
        status, 
        status == 'completed' ? 'Approved' : 'Rejected'
      );'''

replacement_review = '''  Future<void> _reviewSubmission(String submissionId, String status) async {
    if (submissionId.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      await ref.read(coursesRemoteDataSourceProvider).reviewSubmission(
        submissionId, 
        status, 
        status == 'completed' ? 'Approved' : 'Rejected'
      );'''

content = content.replace(target_review, replacement_review)

# 3. Add _buildAdminSubmissionBox method to the class
box_method = '''
  Widget _buildAdminSubmissionBox({
    required String submissionId,
    required String? studentName,
    required String? rollNo,
    required String? className,
    required String? fileUrl,
    required String? submittedAt,
    required bool approved,
    required bool pending,
    required bool isStudentView,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student Submission:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181C1F),
                ),
              ),
              OutlinedButton.icon(
                onPressed: fileUrl != null
                    ? () => openCourseUrl(context, fileUrl)
                    : null,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('View File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF398FDE),
                  side: const BorderSide(color: Color(0xFF398FDE)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Submitted by: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          if (rollNo != null || className != null)
            Text(
              [
                if (rollNo != null) 'Roll No: ',
                if (className != null) 'Class: ',
              ].join(' | '),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          const Text(
            'Institute: Delhi Public School',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          if (submittedAt != null)
            Text(
              'Submitted: ',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          const SizedBox(height: 20),
          if (approved) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1F9254)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF1F9254), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Approved by Admin',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F9254),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Reviewed by: Priya Mehta',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ] else if (pending)
            isStudentView
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF5C842)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'View only - Approval pending from coordinator',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB45309),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmitting || submissionId.isEmpty ? null : () => _reviewSubmission(submissionId, 'completed'),
                          icon: _isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text('Approve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1F9254),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmitting || submissionId.isEmpty ? null : () => _reviewSubmission(submissionId, 'rejected'),
                          icon: _isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text('Reject', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }
'''

content = content.replace('  Widget _statusBadge(bool approved, bool pending) {', box_method + '\n  Widget _statusBadge(bool approved, bool pending) {')

with open('lib/features/courses/presentation/screens/course_module_detail_screen.dart', 'w') as f:
    f.write(content)
