import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../widgets/receipt_printer_widget.dart';

class ReceiptScreen extends StatelessWidget {
  final TransactionModel transaction;

  const ReceiptScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161A22) : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Digital Receipt',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // Virtual Printer Experience Widget
              ReceiptPrinterWidget(
                transaction: transaction,
                onDownload: () {
                  _showToast(
                    context,
                    message: 'Receipt saved to Downloads PDF',
                    icon: Icons.file_download_done_rounded,
                  );
                },
                onShare: () {
                  _showShareSheet(context);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context,
      {required String message, required IconData icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFF10B981)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share Receipt',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Send transaction ${transaction.id} to your accounting app or contact.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _shareOption(
                    context,
                    icon: Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFEF4444),
                    label: 'Export PDF',
                    onTap: () {
                      Navigator.pop(context);
                      _showToast(context,
                          message: 'PDF exported successfully',
                          icon: Icons.picture_as_pdf_rounded);
                    },
                  ),
                  _shareOption(
                    context,
                    icon: Icons.email_rounded,
                    color: const Color(0xFF3B82F6),
                    label: 'Email',
                    onTap: () {
                      Navigator.pop(context);
                      _showToast(context,
                          message: 'Receipt sent to email',
                          icon: Icons.mark_email_read_rounded);
                    },
                  ),
                  _shareOption(
                    context,
                    icon: Icons.chat_bubble_rounded,
                    color: const Color(0xFF10B981),
                    label: 'Messages',
                    onTap: () {
                      Navigator.pop(context);
                      _showToast(context,
                          message: 'Link copied for messaging',
                          icon: Icons.link_rounded);
                    },
                  ),
                  _shareOption(
                    context,
                    icon: Icons.more_horiz_rounded,
                    color: const Color(0xFF8B5CF6),
                    label: 'More',
                    onTap: () {
                      Navigator.pop(context);
                      _showToast(context,
                          message: 'System share opened',
                          icon: Icons.ios_share_rounded);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _shareOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
