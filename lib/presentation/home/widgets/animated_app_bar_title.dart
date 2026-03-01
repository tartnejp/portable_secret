import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedAppBarTitle extends StatefulWidget {
  const AnimatedAppBarTitle({super.key});

  @override
  State<AnimatedAppBarTitle> createState() => _AnimatedAppBarTitleState();
}

class _AnimatedAppBarTitleState extends State<AnimatedAppBarTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _phase1;
  late final Animation<double> _phase2;

  final String _titleText = 'PORTABLE SECRET';

  bool _isFontLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7), // 5s delay + 2s animation
    );

    // Phase 1: 5s to 6s (Text slides to the right and gets clipped)
    _phase1 = CurveTween(
      curve: const Interval(5.0 / 7.0, 6.0 / 7.0, curve: Curves.easeIn),
    ).animate(_controller);

    // Phase 2: 6s to 7s (Container shrinks & Image morphs)
    _phase2 = CurveTween(
      curve: const Interval(6.0 / 7.0, 1.0, curve: Curves.easeInOut),
    ).animate(_controller);

    // フォントのロードを待ってから計算・アニメーションを開始
    _initFontsAndAnimation();
  }

  Future<void> _initFontsAndAnimation() async {
    // Genosフォントがダウンロード・用意されるのを待機
    await GoogleFonts.pendingFonts([GoogleFonts.genos().fontFamily!]);
    if (mounted) {
      setState(() {
        _isFontLoaded = true;
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFontLoaded) {
      // フォント未ロード時はAppBarタイトルの位置に何も表示せず待機する
      return const SizedBox(width: 36, height: 36);
    }

    final baseStyle = GoogleFonts.genos(
      color: Colors.yellow,
      fontSize: 20,
      fontWeight: FontWeight.normal,
      letterSpacing: 2.0,
    );
    //iOSのフォントサイズを考慮したStyle
    final textStyle = baseStyle.copyWith(
      fontSize: MediaQuery.textScalerOf(context).scale(baseStyle.fontSize!),
    );
    // テキストの描画サイズを計算
    // final textPainter = TextPainter(
    //   text: TextSpan(text: _titleText, style: textStyle),
    //   textAlign: TextAlign.start,
    //   textDirection: TextDirection.ltr,
    //   textWidthBasis: TextWidthBasis.parent, //iOSでは重要らしい
    // )..layout();

    final textWidth = TextPainter.computeWidth(
      text: TextSpan(text: _titleText, style: baseStyle),
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.parent, //iOSでは重要らしい
    );
    const spacing = 12.0; // テキストと画像の間のスペース
    final totalTextContainerWidth = textWidth + spacing;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text Area
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  // Phase 2でコンテナの表示幅を縮小
                  widthFactor: 1.0 - _phase2.value,
                  child: SizedBox(
                    width: totalTextContainerWidth,
                    height: 36,
                    child: Transform.translate(
                      // Phase 1でテキストを右方向へ移動
                      offset: Offset(
                        totalTextContainerWidth * _phase1.value,
                        0,
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(right: spacing),
                        child: Text(
                          _titleText,
                          style: textStyle,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Image Area
              SizedBox(
                width: 36, // AppBarの高さに合わせて調整
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 最初はstamp.pngが表示されている
                    Opacity(
                      opacity: 1.0 - _phase2.value,
                      child: Image.asset(
                        'assets/stamp.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Phase 2でstamp_p.pngがフェードイン
                    Opacity(
                      opacity: _phase2.value,
                      child: Image.asset(
                        'assets/stamp_p.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
