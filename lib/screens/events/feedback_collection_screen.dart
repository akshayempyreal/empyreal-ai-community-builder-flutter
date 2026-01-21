import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/feedback_response.dart';
import '../../theme/app_theme.dart';

class FeedbackCollectionScreen extends StatelessWidget {
  final Event event;
  final Function(FeedbackResponse) onSubmitFeedback;
  final VoidCallback onBack;

  static final _mockFeedback = [
    FeedbackResponse(
      id: 'f1',
      attendeeId: '1',
      attendeeName: 'Alex Rivera',
      rating: 5,
      comments:
          'The prompt engineering workshop was a game changer for my workflow. The AI matching was surprisingly accurate.',
      submittedAt: '2h ago',
    ),
     FeedbackResponse(
      id: 'f2',
      attendeeId: '2',
      attendeeName: 'Sarah Chen',
      rating: 4,
      comments:
          'Great event overall! Only feedback is that I wish the keynote was a bit longer to allow for more audience questions.',
      submittedAt: '5h ago',
    ),
     FeedbackResponse(
      id: 'f3',
      attendeeId: '3',
      attendeeName: 'Marcus Thompson',
      rating: 4,
      comments:
          'Solid technical depth. Would love to see more hands-on labs in the next iteration.',
      submittedAt: 'Yesterday',
    ),
  ];

  const FeedbackCollectionScreen({
    super.key,
    required this.event,
    required this.onSubmitFeedback,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final horizontalPadding = isMobile ? 16.0 : 32.0;
    final maxWidth = isMobile ? 520.0 : 960.0;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: onBack,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.indigo100,
              child: const Icon(Icons.person, color: AppTheme.primaryIndigo),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Feedback Hub',
                  style: TextStyle(
                    color: AppTheme.gray900,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Post-Event Insights',
                  style: TextStyle(color: AppTheme.gray500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingCard(),
                  const SizedBox(height: 16),
                  _buildSentimentCard(),
                  const SizedBox(height: 12),
                  _buildImprovementsCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Individual Feedback',
                    style: TextStyle(
                      color: AppTheme.gray900,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._mockFeedback.map(_buildFeedbackTile),
                  const SizedBox(height: 12),
                  _buildViewAllButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRatingCard() {
    return _buildCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        children: [
          const Text(
            'AVERAGE EVENT RATING',
            style: TextStyle(
              color: AppTheme.gray500,
              fontSize: 13,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '4.8',
                style: TextStyle(
                  color: AppTheme.gray900,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ 5',
                  style: TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Stars(),
          const SizedBox(height: 8),
          const Text(
            '↑ 12% from last event',
            style: TextStyle(
              color: AppTheme.green600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppTheme.blue600),
              SizedBox(width: 8),
              Text(
                'Top Positive Sentiment',
                style: TextStyle(
                  color: AppTheme.gray900,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppTheme.gray700,
                  fontSize: 14,
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: '"Attendees highly praised the '),
                  TextSpan(
                    text: 'interactive workshop sessions',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.gray900),
                  ),
                  TextSpan(text: ' and the '),
                  TextSpan(
                    text: 'AI networking algorithm',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.gray900),
                  ),
                  TextSpan(
                      text:
                          ', which resulted in 94% meaningful connection matches."'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Key Areas for Improvement',
            style: TextStyle(
              color: AppTheme.gray900,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          _Bullet(text: 'Increase duration of Q&A sessions'),
          SizedBox(height: 8),
          _Bullet(text: 'Provide more vegan catering options'),
          SizedBox(height: 8),
          _Bullet(text: 'Better Wi-Fi signal in Breakout Room B'),
        ],
      ),
    );
  }

  Widget _buildFeedbackTile(FeedbackResponse feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: _buildCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.indigo100,
                  child: Text(
                    feedback.attendeeName.isNotEmpty
                        ? feedback.attendeeName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.attendeeName,
                        style: const TextStyle(
                          color: AppTheme.gray900,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.submittedAt,
                        style: const TextStyle(
                          color: AppTheme.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const _Stars(compact: true),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${feedback.comments}"',
              style: const TextStyle(
                color: AppTheme.gray700,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryIndigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.gray200),
          ),
        ),
        child: const Text(
          'View All Feedback',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 8, color: AppTheme.blue600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.gray700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final bool compact;
  const _Stars({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 16.0 : 22.0;
    return Row(
      mainAxisAlignment: compact ? MainAxisAlignment.end : MainAxisAlignment.center,
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star,
            size: size,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ),
    );
  }
}
