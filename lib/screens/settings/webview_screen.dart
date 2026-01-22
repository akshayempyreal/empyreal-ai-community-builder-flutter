import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:url_launcher/url_launcher.dart';
import '../../project_helpers.dart';

class AppWebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final VoidCallback onBack;

  const AppWebViewScreen({
    super.key,
    required this.title,
    required this.url,
    required this.onBack,
  });

  @override
  State<AppWebViewScreen> createState() => _AppWebViewScreenState();
}

class _AppWebViewScreenState extends State<AppWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    final String cleanUrl = widget.url.trim();
    debugPrint("WebView: Loading URL: $cleanUrl");
    
    // On web, automatically open in new tab instead of using WebView
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          launchUrl(
            Uri.parse(cleanUrl),
            mode: LaunchMode.externalApplication,
          );
          // Navigate back after opening
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) widget.onBack();
          });
        }
      });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint("WebView: Progress: $progress%");
              if (mounted) {
                setState(() {
                  _progress = progress / 100.0;
                });
              }
            },
            onPageStarted: (String url) {
              debugPrint("WebView: Page started: $url");
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              debugPrint("WebView: Page finished: $url");
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("WebView: Error: ${error.description}");
              debugPrint("WebView: Error Type: ${error.errorType}");
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                // Show toast or snackbar if it's not a minor error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading page: ${error.description}')),
                );
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(cleanUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)
                        .paddingAll(context, 8)
                        .onClick(widget.onBack),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!kIsWeb && _controller != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: () => _controller?.reload(),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: 16.radius,
                  ),
                  child: kIsWeb
                      ? _buildWebFallback()
                      : Stack(
                          children: [
                            if (_controller != null)
                              WebViewWidget(controller: _controller!),
                            if (_isLoading) ...[
                              LinearProgressIndicator(
                                value: _progress > 0 ? _progress : null,
                                backgroundColor: Colors.transparent,
                                color: AppColors.primaryIndigo,
                                minHeight: 3,
                              ),
                              // Keep a very subtle center loader if progress isn't moving
                              if (_progress < 0.1)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryIndigo,
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebFallback() {
    // Show loading while opening in new tab
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryIndigo,
          ),
          SizedBox(height: 24),
          Text(
            'Opening in new tab...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
