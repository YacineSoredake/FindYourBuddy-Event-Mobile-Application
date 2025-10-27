import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';// ensure this path is correct

class StepInterests extends StatelessWidget {
  const StepInterests({super.key});

  final List<String> availableFields = const [
    "Music",
    "Sports",
    "Tech",
    "Movies",
    "Travel",
    "Art",
    "Gaming",
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final selectedFields = auth.user?.fields ?? auth.fields;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What are your interests?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Interests chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableFields.map((field) {
                        final isSelected = selectedFields.contains(field);
                        return ChoiceChip(
                          label: Text(
                            field,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor:
                              AppColors.accent.withOpacity(0.2),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary.withOpacity(0.2),
                          ),
                          onSelected: (_) => auth.toggleField(field),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.loading
                            ? null
                            : () async {
                                await auth.submitRegistration(context);
                                if (auth.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(auth.errorMessage!),
                                      backgroundColor: AppColors.secondary,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.3),
                        ),
                        child: auth.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Finish Registration",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
