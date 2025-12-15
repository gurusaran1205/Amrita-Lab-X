import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/session_provider.dart';
import '../../models/session.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/admin_header.dart';

class ApproveLogoutScreen extends StatefulWidget {
  const ApproveLogoutScreen({super.key});

  @override
  State<ApproveLogoutScreen> createState() => _ApproveLogoutScreenState();
}

class _ApproveLogoutScreenState extends State<ApproveLogoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().fetchPendingSessions();
    });
  }

  Future<void> _handleApprove(String sessionId) async {
    final provider = context.read<SessionProvider>();
    final success = await provider.approveLogout(sessionId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout approved successfully!'),
            backgroundColor: AppColors.primaryMaroon,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Reject"),
        content: const Text("Are you sure you want to reject this logout request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Reject"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<SessionProvider>();
      final success = await provider.rejectLogout(sessionId);

      if (mounted) {
        if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout request rejected.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Operation failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final sessions = sessionProvider.pendingSessions;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: const AdminHeader(title: 'Approve Logouts'),

      body: _buildContent(sessionProvider, sessions),
    );
  }

  Widget _buildContent(SessionProvider provider, List<Session> sessions) {
    if (provider.isLoading && sessions.isEmpty) {
      return const Center(child: AmritaLoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: ${provider.errorMessage}',
            textAlign: TextAlign.center),
      ));
    }

    if (sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No pending logout requests',
                style: TextStyle(
                    fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPendingSessions(),
      color: AppColors.primaryMaroon,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(context, session);
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    final loginFormat = DateFormat('MMM dd, hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          left: BorderSide(color: AppColors.primaryMaroon, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Pending Logout',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.email_outlined, session.user.email),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.login, "Login: ${loginFormat.format(session.loginTime)}"),
              if (session.logoutTime != null) ...[
                const SizedBox(height: 8),
                 _buildInfoRow(Icons.logout, "Req Logout: ${loginFormat.format(session.logoutTime!)}"),
              ],
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(session.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleApprove(session.id),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
