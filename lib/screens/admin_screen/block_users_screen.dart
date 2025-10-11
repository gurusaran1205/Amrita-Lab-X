import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';

class BlockUsersScreen extends StatefulWidget {
  const BlockUsersScreen({super.key});

  @override
  State<BlockUsersScreen> createState() => _BlockUsersScreenState();
}

class _BlockUsersScreenState extends State<BlockUsersScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAllUsers();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- MODIFIED THIS METHOD TO FIX THE NULL ERROR ---
  Future<void> _handleToggleBlock(BuildContext context, User user) async {
    // 1. Add a null check for the user's ID before proceeding.
    if (user.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot perform action: User ID is missing.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final provider = context.read<UserProvider>();
    final originalStatus = user.isBlocked;

    // Optimistically update the UI for a responsive feel
    setState(() {
      final index = provider.users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        provider.users[index] =
            provider.users[index].copyWith(isBlocked: !originalStatus);
      }
    });

    // 2. Use the non-nullable user.id! with the bang operator.
    final success = await provider.toggleUserBlockStatus(user.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${user.name} has been ${originalStatus ? "unblocked" : "blocked"}.'
                : provider.errorMessage ?? 'Operation failed',
          ),
          backgroundColor: success ? AppColors.primaryMaroon : AppColors.error,
        ),
      );

      // If the API call failed, revert the state change in the UI
      if (!success) {
        setState(() {
          final index = provider.users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            provider.users[index] =
                provider.users[index].copyWith(isBlocked: originalStatus);
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    List<User> filteredUsers = userProvider.users.where((user) {
      final query = _searchQuery.toLowerCase();
      return query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(
                _isSearchVisible ? Icons.close : Icons.search,
                color: AppColors.textSecondary),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 80 : 0,
            color: AppColors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.lightGray,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildContent(userProvider, filteredUsers),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserProvider provider, List<User> users) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: AmritaLoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Text('Error: ${provider.errorMessage}', textAlign: TextAlign.center),
      ));
    }

    if (provider.users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No users found',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No users match your search',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllUsers(),
      color: AppColors.primaryMaroon,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(context, user);
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
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
        border: Border(
          left: BorderSide(
            color: user.isBlocked ? AppColors.error : AppColors.success,
            width: 5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: (user.isBlocked ? AppColors.error : AppColors.primaryMaroon).withOpacity(0.1),
          child: Icon(
            user.isBlocked ? Icons.block : Icons.person_outline,
            color: user.isBlocked ? AppColors.error : AppColors.primaryMaroon,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: ElevatedButton(
          onPressed: () => _handleToggleBlock(context, user),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                user.isBlocked ? AppColors.success : AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(user.isBlocked ? 'Unblock' : 'Block'),
        ),
      ),
    );
  }
}