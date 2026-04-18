import 'package:flutter/material.dart';

import '../utils/password_utils.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: _strengthValue(strength),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_strengthColor(strength)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _strengthText(strength),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _strengthColor(strength),
          ),
        ),
      ],
    );
  }

  static double _strengthValue(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return 0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1;
    }
  }

  static Color _strengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  static String _strengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return 'None';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }
}

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'At least 8 characters',
            isMet: password.length >= 8,
          ),
          _RequirementItem(
            text: 'Contains uppercase letter (A-Z)',
            isMet: PasswordUtils.containsUppercase(password),
          ),
          _RequirementItem(
            text: 'Contains lowercase letter (a-z)',
            isMet: PasswordUtils.containsLowercase(password),
          ),
          _RequirementItem(
            text: 'Contains number (0-9)',
            isMet: PasswordUtils.containsNumber(password),
          ),
          _RequirementItem(
            text: 'Contains special character (!@#\$%^&*)',
            isMet: PasswordUtils.containsSpecialCharacter(password),
          ),
          _RequirementItem(
            text: 'No 4+ repeated characters',
            isMet: !PasswordUtils.hasRepeatedCharacters(password),
          ),
          _RequirementItem(
            text: 'No sequential characters (abc, 123)',
            isMet: !PasswordUtils.hasSequentialCharacters(password),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.text, required this.isMet});

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}
