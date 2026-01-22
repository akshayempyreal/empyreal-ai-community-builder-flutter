import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    // On web, automatically open in new tab
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          try {
            final uri = Uri.parse(widget.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } else {
              // Fallback: try to open in same window
              await launchUrl(uri, mode: LaunchMode.platformDefault);
            }
            // Navigate back after opening
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) widget.onBack();
            });
          } catch (e) {
            debugPrint('Error launching URL: $e');
            // Still navigate back even if launch fails
            if (mounted) widget.onBack();
          }
        }
      });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(widget.title),
      ),
      body: kIsWeb 
        ? _buildWebFallback()
        : _controller != null
          ? Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWebFallback() {
    // Show loading while opening in new tab
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Opening in new tab...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
