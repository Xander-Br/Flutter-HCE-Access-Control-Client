import 'package:uuid/uuid.dart';
// import 'dart:convert'; // Not strictly needed for this snippet if not used directly here

class TotpModel {
  final String id;
  final String uri; // The original, validated URI
  final String issuer;
  final String accountName;

  TotpModel({
    required this.id,
    required this.uri,
    required this.issuer,
    required this.accountName,
  });

  factory TotpModel.fromUri(String uriString, {String? existingId}) {
    final Uri parsedUri;
    try {
      // Normalize URI string: some QR codes might have leading/trailing spaces.
      uriString = uriString.trim();
      if (uriString.isEmpty) {
        throw FormatException('QR code is empty.');
      }
      parsedUri = Uri.parse(uriString);
    } catch (e) {
      // This catches genuinely malformed URI strings.
      throw FormatException('Invalid QR code: Not a valid URI structure.', e);
    }

    // 1. Scheme Check (must be 'otpauth')
    if (parsedUri.scheme != 'otpauth') {
      throw FormatException('Invalid QR code: Not an OTP Auth URI (must start with "otpauth://").');
    }

    // 2. Authority Check (must be 'totp' for this application)
    if (parsedUri.authority != 'totp') {
      throw FormatException('Unsupported OTP type: QR code specifies "${parsedUri.authority}", but only "totp" is supported.');
    }

    // 3. Path Check (label for the account, should exist and not be empty)
    // The path segment is usually the label, like "Example:alice@google.com"
    if (parsedUri.pathSegments.isEmpty || parsedUri.pathSegments.first.trim().isEmpty) {
        throw FormatException('Invalid TOTP QR code: Missing account label.');
    }
    // Path is usually one segment for the label, but could be more if slashes are in the label (URL-encoded).
    // We typically use the last segment or join them if needed, then decode.
    String label = Uri.decodeComponent(parsedUri.pathSegments.join('/').trim());
    if (label.isEmpty) {
        throw FormatException('Invalid TOTP QR code: Account label is empty.');
    }


    // 4. Secret Check (essential for TOTP functionality)
    final String? secret = parsedUri.queryParameters['secret'];
    if (secret == null || secret.trim().isEmpty) {
      throw FormatException('Invalid TOTP QR code: Missing "secret" parameter.');
    }
    // Optional: Add more validation for the secret format itself (e.g., Base32 characters) if desired,
    // but presence is the first critical check. Most OTP libraries handle Base32 decoding internally.


    // --- If all checks above pass, then proceed to extract metadata ---
    String issuerFromQuery = parsedUri.queryParameters['issuer']?.trim() ?? '';
    String accountNameFromLabel = label; // Start with the full label
    String finalIssuer = issuerFromQuery;

    // Standard parsing logic for issuer and account name from label and query
    // Example: "IssuerName:AccountName" or "AccountName" with issuer in query.
    if (label.contains(':')) {
      final parts = label.split(':');
      String issuerInLabel = parts.first.trim();
      // Join remaining parts for account name in case account name itself contains ':'
      accountNameFromLabel = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

      if (finalIssuer.isEmpty) { // If issuer not in query, use the one from label
        finalIssuer = issuerInLabel;
      } else if (finalIssuer.toLowerCase() == issuerInLabel.toLowerCase()) {
        // Issuer in query and label match. Account name is what's after the colon.
        // If accountNameFromLabel is empty here, it means label was "Issuer:", so keep it empty for now.
      } else {
        // Issuers conflict or label has an issuer prefix not matching query.
        // Prefer query issuer. The accountNameFromLabel is currently label's suffix.
        // If accountNameFromLabel is empty, it means the label was "SomeIssuer:",
        // but the query has a different `finalIssuer`.
        // In this case, the full label might be the intended account name if `finalIssuer` is the authority.
        // This part can be complex. The original logic might be fine, or you might prioritize.
        // For now, if `finalIssuer` (from query) exists, `accountNameFromLabel` is what we parsed from the label's suffix.
        // If `accountNameFromLabel` is empty, it suggests the label was just "Issuer:", so the full original label might be better.
        if (accountNameFromLabel.isEmpty) accountNameFromLabel = label;
      }
    } else if (finalIssuer.isNotEmpty) {
      // No colon in label, issuer is from query. Label is the account name.
      accountNameFromLabel = label.trim();
    }
    // If finalIssuer is still empty at this point, and label did not contain ':', then there's no issuer.
    // Account name remains the full label.

    // Final cleanup for accountName if it was not properly split and finalIssuer is known
    if (finalIssuer.isNotEmpty && accountNameFromLabel.toLowerCase().startsWith(finalIssuer.toLowerCase() + ":")) {
        accountNameFromLabel = accountNameFromLabel.substring(finalIssuer.length + 1).trim();
    } else if (finalIssuer.isNotEmpty && accountNameFromLabel.toLowerCase().startsWith(finalIssuer.toLowerCase())) {
        // Avoid removing issuer if accountName is identical to issuer
        if (accountNameFromLabel.length > finalIssuer.length) {
            String tempAccountName = accountNameFromLabel.substring(finalIssuer.length).trim();
            if (tempAccountName.startsWith(':')) { //常見 "Issuer:Account" but label might be "IssuerAccount"
                tempAccountName = tempAccountName.substring(1).trim();
            }
            if(tempAccountName.isNotEmpty) accountNameFromLabel = tempAccountName;
        }
    }
    
    // If after all parsing, account name is empty but label wasn't, use label.
    if (accountNameFromLabel.isEmpty && label.isNotEmpty) {
        accountNameFromLabel = label;
    }
    // If issuer is empty and account name contains a colon, assume first part is issuer for display
    if (finalIssuer.isEmpty && accountNameFromLabel.contains(':')) {
        final parts = accountNameFromLabel.split(':');
        finalIssuer = parts.first.trim();
        accountNameFromLabel = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
    }


    return TotpModel(
      id: existingId ?? const Uuid().v4(),
      uri: uriString, // Store the original, validated, and trimmed URI string
      issuer: finalIssuer,
      accountName: accountNameFromLabel.isEmpty ? (finalIssuer.isEmpty ? "No Account Name" : finalIssuer) : accountNameFromLabel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uri': uri,
        'issuer': issuer,
        'accountName': accountName,
      };

  factory TotpModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['uri'] == null) {
      throw const FormatException("Invalid JSON for TotpModel: Missing 'id' or 'uri'.");
    }
    // If issuer or accountName are missing from JSON, try to re-parse from URI.
    // This ensures that stored URIs also undergo validation if loaded partially.
    if (json['issuer'] == null || json['accountName'] == null) {
      try {
        return TotpModel.fromUri(json['uri'] as String, existingId: json['id'] as String);
      } catch (e) {
        // If re-parsing fails, the stored URI was invalid.
        throw FormatException("Failed to reconstruct TotpModel from stored invalid URI (id: ${json['id']}): ${e.toString()}");
      }
    }

    return TotpModel(
      id: json['id'] as String,
      uri: json['uri'] as String,
      issuer: json['issuer'] as String,
      accountName: json['accountName'] as String,
    );
  }

  TotpModel copyWith({
    String? id,
    String? uri,
    String? issuer,
    String? accountName,
  }) =>
      TotpModel(
        id: id ?? this.id,
        uri: uri ?? this.uri,
        issuer: issuer ?? this.issuer,
        accountName: accountName ?? this.accountName,
      );

  @override
  String toString() {
    return 'TotpModel(id: $id, issuer: "$issuer", accountName: "$accountName", uri: "$uri")';
  }
}