import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class StepVerifyEmail extends StatelessWidget {
  const StepVerifyEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.loading;
    final sent = auth.verificationSent;
    final error = auth.errorMessage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Lottie.asset(
                    sent
                        ? 'assets/animations/Email.json'
                        : 'assets/animations/Verify.json',
                    key: ValueKey(sent),
                    height: 180,
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  sent ? "Check your inbox" : "Verify your email",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  sent
                      ? "We’ve sent a verification link to:\n${auth.user?.email ?? 'your email'}"
                      : "We need to verify your email before continuing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Error message
                if (error != null && error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1,
                      child: Text(
                        error,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Action buttons
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: sent
                      ? _NextAndResend(auth: auth, loading: loading)
                      : _SendButton(auth: auth, loading: loading),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final AuthProvider auth;
  final bool loading;
  const _SendButton({required this.auth, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                await auth.sendVerificationEmail(context);
                log("Verification email sent");
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Send verification email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class _NextAndResend extends StatelessWidget {
  final AuthProvider auth;
  final bool loading;

  const _NextAndResend({required this.auth, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isVerified = auth.verificationDone;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Continue / Waiting Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!loading && isVerified) ? () => auth.nextStep() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isVerified ? Colors.teal : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isVerified ? "Continue" : "Waiting for verification...",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Resend email (resets timer)
        TextButton(
          onPressed: loading
              ? null
              : () async {
                  await auth.resendVerificationEmail(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification email resent.")),
                  );
                },
          style: TextButton.styleFrom(foregroundColor: Colors.teal),
          child: const Text(
            "Resend email",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
