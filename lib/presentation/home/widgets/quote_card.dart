import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

class EnhancedQuoteCard extends StatelessWidget {
  const EnhancedQuoteCard({
    Key? key,
    this.author,
    this.quote,
    this.articleType,
    this.title, // Add title parameter for articles
  }) : super(key: key);

  final String? author;
  final String? quote;
  final String? articleType;
  final String? title; // New parameter for article titles

  @override
  Widget build(BuildContext context) {
    // Calculate responsive width and height based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final cardHeight = cardWidth * 1.4;

    // Check if this is an article
    final isArticle = articleType == 'Article';

    return Container(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom layer (deepest shadow)
          Positioned(
            bottom: 0,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateX(0.05)
                ..rotateZ(0.03),
              alignment: Alignment.center,
              child: Container(
                width: cardWidth - 20,
                height: cardHeight - 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Middle layer
          Positioned(
            bottom: 10,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateX(0.03)
                ..rotateZ(0.02),
              alignment: Alignment.center,
              child: Container(
                width: cardWidth - 10,
                height: cardHeight - 20,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Main card layer
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.indigo.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),

                  // Content with scrolling support
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quote mark at the top
                        Row(
                          children: [
                            Text(
                              '❞',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                height: 0.8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Scrollable content area
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Article title (if it's an article)
                                if (isArticle && title != null && title!.isNotEmpty) ...[
                                  Text(
                                    title!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: cardWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Divider line
                                  Container(
                                    height: 2,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Quote/Content text
                                if (quote != null && quote!.isNotEmpty)
                                  Text(
                                    quote!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: cardWidth * 0.045,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                // Attribution (if not an article or if author is not empty)
                                if (!isArticle || (author != null && author!.isNotEmpty && author != 'Unknown'))
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '— ${author ?? 'Unknown'}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: cardWidth * 0.04,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bottom section with hashtag/article type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (articleType != null && articleType!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '#${articleType!}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: cardWidth * 0.035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            // Scroll indicator (only show if content is scrollable)
                            Icon(
                              Icons.swipe_vertical,
                              color: Colors.white.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}