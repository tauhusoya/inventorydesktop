import 'package:flutter/material.dart';

/// App Colors - Semantic color scheme based on Material Design 3
///
/// This utility provides consistent, theme-aware colors for different states
/// and purposes throughout the app, ensuring proper dark theme support.

/// Status colors - use these for different states

/// Success/Positive states
Color statusSuccess(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Error/Danger states
Color statusError(BuildContext context) => Theme.of(context).colorScheme.error;

/// Warning states
Color statusWarning(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// Info states
Color statusInfo(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

/// Neutral states
Color statusNeutral(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Stock level colors - use these for inventory status

/// In stock - good level
Color stockLevelInStock(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Low stock - warning level
Color stockLevelLowStock(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// Out of stock - critical level
Color stockLevelOutOfStock(BuildContext context) =>
    Theme.of(context).colorScheme.error;

/// Unknown/No data
Color stockLevelUnknown(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Movement type colors - use these for stock movements

/// Stock in - positive movement
Color movementTypeStockIn(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Stock out - negative movement
Color movementTypeStockOut(BuildContext context) =>
    Theme.of(context).colorScheme.error;

/// Transfer - neutral movement
Color movementTypeTransfer(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

/// Priority colors - use these for alerts and notifications

/// High priority - urgent
Color priorityHigh(BuildContext context) => Theme.of(context).colorScheme.error;

/// Medium priority - important
Color priorityMedium(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// Low priority - informational
Color priorityLow(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

/// No priority - neutral
Color priorityNone(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Category colors - use these for different product categories

/// Primary category
Color categoryPrimary(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Secondary category
Color categorySecondary(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

/// Tertiary category
Color categoryTertiary(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// Quaternary category
Color categoryQuaternary(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Quinary category
Color categoryQuinary(BuildContext context) =>
    Theme.of(context).colorScheme.surfaceContainerHighest;

/// User role colors - use these for different user types

/// Admin users
Color userRoleAdmin(BuildContext context) =>
    Theme.of(context).colorScheme.error;

/// Manager users
Color userRoleManager(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// Regular users
Color userRoleUser(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Guest users
Color userRoleGuest(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Activity colors - use these for different activity types

/// Item added
Color activityItemAdded(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Stock updated
Color activityStockUpdated(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

/// Low stock alert
Color activityLowStockAlert(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;

/// User login
Color activityUserLogin(BuildContext context) =>
    Theme.of(context).colorScheme.outline;

/// Category created
Color activityCategoryCreated(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

/// Background colors with proper alpha values

/// Success background
Color backgroundSuccess(BuildContext context, {double alpha = 0.1}) =>
    statusSuccess(context).withValues(alpha: alpha);

/// Error background
Color backgroundError(BuildContext context, {double alpha = 0.1}) =>
    statusError(context).withValues(alpha: alpha);

/// Warning background
Color backgroundWarning(BuildContext context, {double alpha = 0.1}) =>
    statusWarning(context).withValues(alpha: alpha);

/// Info background
Color backgroundInfo(BuildContext context, {double alpha = 0.1}) =>
    statusInfo(context).withValues(alpha: alpha);

/// Neutral background
Color backgroundNeutral(BuildContext context, {double alpha = 0.1}) =>
    statusNeutral(context).withValues(alpha: alpha);

/// Border colors with proper alpha values

/// Success border
Color borderSuccess(BuildContext context, {double alpha = 0.3}) =>
    statusSuccess(context).withValues(alpha: alpha);

/// Error border
Color borderError(BuildContext context, {double alpha = 0.3}) =>
    statusError(context).withValues(alpha: alpha);

/// Warning border
Color borderWarning(BuildContext context, {double alpha = 0.3}) =>
    statusWarning(context).withValues(alpha: alpha);

/// Info border
Color borderInfo(BuildContext context, {double alpha = 0.3}) =>
    statusInfo(context).withValues(alpha: alpha);

/// Neutral border
Color borderNeutral(BuildContext context, {double alpha = 0.3}) =>
    statusNeutral(context).withValues(alpha: alpha);

/// Icon colors

/// Success icon
Color iconSuccess(BuildContext context) => statusSuccess(context);

/// Error icon
Color iconError(BuildContext context) => statusError(context);

/// Warning icon
Color iconWarning(BuildContext context) => statusWarning(context);

/// Info icon
Color iconInfo(BuildContext context) => statusInfo(context);

/// Neutral icon
Color iconNeutral(BuildContext context) => statusNeutral(context);

/// Text colors

/// Success text
Color textSuccess(BuildContext context) => statusSuccess(context);

/// Error text
Color textError(BuildContext context) => statusError(context);

/// Warning text
Color textWarning(BuildContext context) => statusWarning(context);

/// Info text
Color textInfo(BuildContext context) => statusInfo(context);

/// Neutral text
Color textNeutral(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;
