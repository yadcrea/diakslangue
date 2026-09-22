import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/languages_data.dart';
import '../services/audio_service.dart';

class _SearchResult {
  final String word;
  final String translation;
  final String? translationEn;
  final String? audioPath;
  final String? imagePath;
  final String languageName;
  final Color languageColor;
  final String courseName;

  const _SearchResult({
    required this.word,
    required this.translation,
    this.translationEn,
    this.audioPath,
    this.imagePath,
    required this.languageName,
    required this.languageColor,
    required this.courseName,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _audio = AudioService();
  final _focus = FocusNode();
  String? _playingAudio;

  late final List<_SearchResult> _allResults;
  List<_SearchResult> _filtered = [];

  @override
  void initState() {
    super.initState();
    _allResults = _buildIndex();
    _controller.addListener(_onQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.removeListener(_onQuery);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<_SearchResult> _buildIndex() {
    final results = <_SearchResult>[];
    final seen = <String>{};

    for (final lang in allLanguages) {
      for (final course in lang.courses) {
        for (final lesson in course.lessons) {
          for (final ex in lesson.exercises) {
            final word = ex.subtitle ?? ex.correctAnswer;
            final translation = ex.translation ?? '';
            final key = '${lang.id}|$word';
            if (seen.contains(key)) continue;
            seen.add(key);

            results.add(_SearchResult(
              word: word,
              translation: translation,
              translationEn: ex.translationEn,
              audioPath: ex.audioFileName,
              imagePath: ex.imagePath,
              languageName: lang.name,
              languageColor: lang.color,
              courseName: course.title,
            ));
          }
        }
      }
    }
    return results;
  }

  void _onQuery() {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = []);
      return;
    }
    setState(() {
      _filtered = _allResults.where((r) {
        return r.word.toLowerCase().contains(q) ||
            r.translation.toLowerCase().contains(q) ||
            (r.translationEn?.toLowerCase().contains(q) ?? false) ||
            r.languageName.toLowerCase().contains(q) ||
            r.courseName.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _play(String? path) async {
    if (path == null) return;
    setState(() => _playingAudio = path);
    await _audio.playAsset(path);
    if (mounted) setState(() => _playingAudio = null);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          margin: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Chercher un mot…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              border: InputBorder.none,
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _focus.requestFocus();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: hasQuery ? _buildResults() : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded,
                size: 40, color: AppColors.navy),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rechercher un mot',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          Text(
            'En Diakhango, Dioula, Sousou…\nou tapez la traduction française',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: AppColors.grey.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied_rounded,
                size: 48, color: AppColors.grey),
            const SizedBox(height: 12),
            const Text('Aucun résultat',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
            const SizedBox(height: 4),
            Text(
              'Essaie un autre mot',
              style: TextStyle(fontSize: 14, color: AppColors.grey.withValues(alpha: 0.8)),
            ),
          ],
        ),
      );
    }

    final query = _controller.text.trim().toLowerCase();

    return Column(
      children: [
        // Result count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '${_filtered.length} résultat${_filtered.length > 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _buildResultCard(_filtered[i], query),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(_SearchResult r, String query) {
    final isPlaying = _playingAudio == r.audioPath;
    final color = r.languageColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Image or color dot
            if (r.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  r.imagePath!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _colorDot(color),
                ),
              )
            else
              _colorDot(color),

            const SizedBox(width: 12),

            // Word + translation + language badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language + course badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          r.languageName,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          r.courseName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Word highlighted
                  _HighlightText(
                    text: r.word,
                    query: query,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: AppColors.navy),
                    highlightStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: color),
                  ),
                  if (r.translation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _HighlightText(
                      text: r.translation,
                      query: query,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.grey),
                      highlightStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                  ],
                  if (r.translationEn != null &&
                      r.translationEn!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    _HighlightText(
                      text: r.translationEn!,
                      query: query,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontStyle: FontStyle.italic),
                      highlightStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: color),
                    ),
                  ],
                ],
              ),
            ),

            // Audio button
            if (r.audioPath != null)
              GestureDetector(
                onTap: () => _play(r.audioPath),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? color
                        : color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.graphic_eq : Icons.volume_up_rounded,
                    color: isPlaying ? Colors.white : color,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.record_voice_over_rounded,
          size: 26, color: color.withValues(alpha: 0.6)),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());
    if (idx == -1) return Text(text, style: style);

    return RichText(
      text: TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx), style: style),
        TextSpan(
            text: text.substring(idx, idx + query.length),
            style: highlightStyle),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length), style: style),
      ]),
    );
  }
}
