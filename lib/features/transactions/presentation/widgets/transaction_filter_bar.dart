// lib/features/transactions/presentation/widgets/transaction_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:hce_emv/theme/app_colors.dart';

class TransactionFilterBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onVoiceSearch;
  final ValueChanged<String>? onSearchChanged;

  const TransactionFilterBar({
    super.key,
    required this.controller,
    this.onVoiceSearch,
    this.onSearchChanged,
  });

  @override
  State<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends State<TransactionFilterBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  _isFocused
                      ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: TextField(
              controller: widget.controller,
              onTap: () {
                setState(() => _isFocused = true);
                _animationController.forward();
              },
              onEditingComplete: () {
                setState(() => _isFocused = false);
                _animationController.reverse();
              },
              onTapOutside: (_) {
                setState(() => _isFocused = false);
                _animationController.reverse();
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.search,
                    color:
                        _isFocused
                            ? AppColors.primary
                            : (isDark ? Colors.white54 : Colors.grey.shade500),
                    size: 22,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.controller.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearchChanged?.call('');
                        },
                        tooltip: 'Clear search',
                      ),
                    if (widget.onVoiceSearch != null)
                      IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: widget.onVoiceSearch,
                        tooltip: 'Voice search',
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AppColors.primary,
              textInputAction: TextInputAction.search,
            ),
          ),
        );
      },
    );
  }
}
