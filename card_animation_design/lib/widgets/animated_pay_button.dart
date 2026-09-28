import 'package:flutter/material.dart';

enum PayButtonState { idle, pressed, loading, success }

class AnimatedPayButton extends StatefulWidget {
  final double amount;
  final VoidCallback onPressed;
  final PayButtonState currentState;

  const AnimatedPayButton({
    super.key,
    required this.amount,
    required this.onPressed,
    this.currentState = PayButtonState.idle,
  });

  @override
  State<AnimatedPayButton> createState() => _AnimatedPayButtonState();
}

class _AnimatedPayButtonState extends State<AnimatedPayButton>
    with SingleTickerProviderStateMixin {
  bool _isTapDown = false;

  @override
  Widget build(BuildContext context) {
    final isIdle = widget.currentState == PayButtonState.idle;
    final isLoading = widget.currentState == PayButtonState.loading;
    final isSuccess = widget.currentState == PayButtonState.success;

    // Dynamic width & shape morphing: Full width idle -> Compact 64px pill loading/success
    final targetWidth = (isLoading || isSuccess) ? 64.0 : double.infinity;
    final targetHeight = 58.0;

    return GestureDetector(
      onTapDown: isIdle ? (_) => setState(() => _isTapDown = true) : null,
      onTapUp: isIdle ? (_) => setState(() => _isTapDown = false) : null,
      onTapCancel: isIdle ? () => setState(() => _isTapDown = false) : null,
      onTap: isIdle ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isTapDown ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          width: targetWidth,
          height: targetHeight,
          decoration: BoxDecoration(
            color: isSuccess
                ? const Color(0xFF10B981)
                : const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(
                (isLoading || isSuccess) ? 32 : 18),
            boxShadow: [
              BoxShadow(
                color: (isSuccess
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6366F1))
                    .withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildButtonContent(isIdle, isLoading, isSuccess),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isIdle, bool isLoading, bool isSuccess) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isSuccess) {
      return const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 28,
        key: ValueKey('success_icon'),
      );
    }

    return Row(
      key: const ValueKey('idle_content'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 18, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          'Pay Now \$${widget.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
      ],
    );
  }
}
