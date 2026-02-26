import 'package:flutter/material.dart';

/// アプリ共通カラー定数
/// ダークテーマ + 黄色アクセントカラー
abstract final class AppColors {
  /// 最背面の背景色（ほぼ黒）
  static const Color background = Color(0xFF1A1A1A);

  /// カード・コンテナの背景色（やや明るいダークグレー）
  static const Color surface = Color(0xFF242424);

  /// 少し明るいサーフェス（入力フィールド等）
  static const Color surfaceLight = Color(0xFF2E2E2E);

  /// AppBar やボトムバー等の背景
  static const Color appBarBackground = Color(0xFF1F1F1F);

  /// アクセントカラー（黄色）
  static const Color accent = Color(0xFFFFD600);

  /// アクセントカラー・暗め（押下状態等）
  static const Color accentDark = Color(0xFFCCAB00);

  /// プライマリテキスト（白）
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// セカンダリテキスト（薄いグレー）
  static const Color textSecondary = Color(0xFF9E9E9E);

  /// 無効・非アクティブ状態のテキスト
  static const Color textDisabled = Color(0xFF5A5A5A);

  /// 区切り線・ボーダー色
  static const Color divider = Color(0xFF333333);

  /// エラーカラー
  static const Color error = Color(0xFFFF5252);

  /// 成功カラー
  static const Color success = Color(0xFF69F0AE);
}
