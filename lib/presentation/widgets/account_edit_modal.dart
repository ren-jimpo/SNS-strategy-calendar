import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/sns_account.dart';
import '../providers/sns_data_provider.dart';

class AccountEditModal extends StatefulWidget {
  final SnsAccount? account;
  final String? initialPlatform;

  const AccountEditModal({
    super.key,
    this.account,
    this.initialPlatform,
  });

  @override
  State<AccountEditModal> createState() => _AccountEditModalState();
}

class _AccountEditModalState extends State<AccountEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _bioController;
  late TextEditingController _followersController;
  late TextEditingController _followingController;
  late TextEditingController _postsController;
  late String _selectedPlatform;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _platforms = [
    'instagram',
    'twitter',
    'facebook',
    'youtube',
    'tiktok',
    'linkedin',
  ];

  @override
  void initState() {
    super.initState();
    
    _accountNameController = TextEditingController(
      text: widget.account?.accountName ?? '',
    );
    _bioController = TextEditingController(
      text: widget.account?.bio ?? '',
    );
    _followersController = TextEditingController(
      text: widget.account?.followersCount.toString() ?? '0',
    );
    _followingController = TextEditingController(
      text: widget.account?.followingCount.toString() ?? '0',
    );
    _postsController = TextEditingController(
      text: widget.account?.postsCount.toString() ?? '0',
    );
    
    _selectedPlatform = widget.account?.platform ?? widget.initialPlatform ?? 'instagram';
    _isActive = widget.account?.isActive ?? true;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _bioController.dispose();
    _followersController.dispose();
    _followingController.dispose();
    _postsController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.account != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildForm(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPlatformColor(_selectedPlatform),
                  _getPlatformColor(_selectedPlatform).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPlatformIcon(_selectedPlatform),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'アカウント編集' : 'アカウント追加',
                  style: AppTypography.title2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _getPlatformDisplayName(_selectedPlatform),
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.systemGray,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPlatformSelector(),
          const SizedBox(height: 20),
          _buildAccountNameField(),
          const SizedBox(height: 16),
          _buildBioField(),
          const SizedBox(height: 20),
          _buildStatsSection(),
          const SizedBox(height: 20),
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'プラットフォーム',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _platforms.length,
              itemBuilder: (context, index) {
                final platform = _platforms[index];
                final isSelected = platform == _selectedPlatform;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlatform = platform;
                      });
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? _getPlatformColor(platform).withOpacity(0.1)
                          : AppColors.systemGray6,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                            ? _getPlatformColor(platform)
                            : AppColors.separator.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getPlatformIcon(platform),
                            color: isSelected 
                              ? _getPlatformColor(platform)
                              : AppColors.secondaryLabel,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getPlatformDisplayName(platform),
                            style: AppTypography.caption1.copyWith(
                              color: isSelected 
                                ? _getPlatformColor(platform)
                                : AppColors.secondaryLabel,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAccountNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _accountNameController,
        decoration: InputDecoration(
          labelText: 'アカウント名',
          hintText: '@your_account_name',
          prefixIcon: Icon(
            CupertinoIcons.at,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'アカウント名を入力してください';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _bioController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'プロフィール',
          hintText: 'アカウントの説明を入力...',
          prefixIcon: Icon(
            CupertinoIcons.doc_text,
            color: AppColors.secondaryLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '統計情報',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatField(
                    _followersController,
                    'フォロワー数',
                    CupertinoIcons.person_2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatField(
                    _followingController,
                    'フォロー数',
                    CupertinoIcons.person_add,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatField(
                    _postsController,
                    '投稿数',
                    CupertinoIcons.square_grid_2x2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemGray6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 16, color: AppColors.secondaryLabel),
          hintText: '0',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (int.tryParse(value) == null) {
              return '数字を入力してください';
            }
          }
          return null;
        },
        style: AppTypography.caption1.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.checkmark_shield,
              color: _isActive ? AppColors.systemGreen : AppColors.systemGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'アクティブなアカウント',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isActive ? '投稿スケジュールに表示されます' : '非表示にします',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.systemGray4,
                borderRadius: BorderRadius.circular(12),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'キャンセル',
                  style: AppTypography.body.copyWith(
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: _getPlatformColor(_selectedPlatform),
                borderRadius: BorderRadius.circular(12),
                onPressed: _isLoading ? null : _saveAccount,
                child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : Text(
                      _isEditing ? '更新' : '追加',
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // アカウント名のバリデーション
      if (_accountNameController.text.trim().isEmpty) {
        throw Exception('アカウント名を入力してください');
      }

      final accountData = SnsAccount(
        id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        accountName: _accountNameController.text.trim(),
        platform: _selectedPlatform,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        followersCount: int.tryParse(_followersController.text) ?? 0,
        followingCount: int.tryParse(_followingController.text) ?? 0,
        postsCount: int.tryParse(_postsController.text) ?? 0,
        isActive: _isActive,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Providerが利用可能かチェック
      final provider = Provider.of<SnsDataProvider>(context, listen: false);

      bool success = false;
      if (_isEditing) {
        success = await provider.updateAccount(accountData);
      } else {
        success = await provider.createAccount(accountData);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(accountData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'アカウントを更新しました' : 'アカウントを追加しました'),
              backgroundColor: AppColors.systemGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('保存に失敗しました'),
              backgroundColor: AppColors.systemRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.toString()}'),
            backgroundColor: AppColors.systemRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'instagram':
        return CupertinoIcons.camera;
      case 'twitter':
        return CupertinoIcons.chat_bubble;
      case 'facebook':
        return CupertinoIcons.group;
      case 'youtube':
        return CupertinoIcons.play_rectangle;
      case 'tiktok':
        return CupertinoIcons.music_note;
      case 'linkedin':
        return CupertinoIcons.briefcase;
      default:
        return CupertinoIcons.device_phone_portrait;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      default:
        return AppColors.systemBlue;
    }
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform) {
      case 'instagram':
        return 'Instagram';
      case 'twitter':
        return 'Twitter';
      case 'facebook':
        return 'Facebook';
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform.toUpperCase();
    }
  }
} 