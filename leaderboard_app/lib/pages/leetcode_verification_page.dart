import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leaderboard_app/services/core/error_utils.dart';
import 'package:leaderboard_app/services/leetcode/leetcode_service.dart';
import 'package:provider/provider.dart';

class LeetCodeVerificationPage extends StatefulWidget {
	const LeetCodeVerificationPage({super.key});

	@override
	State<LeetCodeVerificationPage> createState() => _LeetCodeVerificationPageState();
}

class _LeetCodeVerificationPageState extends State<LeetCodeVerificationPage> {
	final _usernameCtrl = TextEditingController();
	bool _loading = false;
	String? _error;
	String? _verificationCode;
	String? _instructions;
	Timer? _pollTimer;
	int _secondsLeft = 0;

	@override
	void dispose() {
		_pollTimer?.cancel();
		_usernameCtrl.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.of(context).size.height;
		return GestureDetector(
			onTap: () => FocusScope.of(context).unfocus(),
			child: Scaffold(
				backgroundColor: const Color(0xFF141316),
				body: Column(
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						Padding(
							padding: const EdgeInsets.only(bottom: 20),
							child: Container(
								child: const Center(
									child: Text(
										'Verify LeetCode',
										style: TextStyle(
											fontSize: 36,
											color: Colors.white,
											fontWeight: FontWeight.bold,
										),
									),
								),
							),
						),
						Align(
							alignment: Alignment.bottomCenter,
							child: Container(
								height: screenHeight * 0.80,
								padding: const EdgeInsets.all(35),
								decoration: const BoxDecoration(
									color: Color(0xff11b1a1d),
									borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
								),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										const SizedBox(height: 5),
										TextField(
											controller: _usernameCtrl,
											style: const TextStyle(color: Colors.white),
											decoration: InputDecoration(
												filled: true,
												fillColor: const Color(0xFF141316),
												hintText: 'LeetCode username',
												hintStyle: TextStyle(color: Colors.grey.withOpacity(0.28)),
												border: OutlineInputBorder(
													borderRadius: BorderRadius.circular(8),
													borderSide: BorderSide.none,
												),
											),
										),
										const SizedBox(height: 12),
										if (_error != null)
											Padding(
												padding: const EdgeInsets.only(bottom: 8.0),
												child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
											),
										SizedBox(
											width: double.infinity,
											height: 45,
											child: ElevatedButton(
												style: ElevatedButton.styleFrom(
													backgroundColor: const Color(0xFFF6C156),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(8),
													),
												),
												onPressed: _loading ? null : _startVerification,
												child: _loading
														? const SizedBox(
																width: 18,
																height: 18,
																child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
															)
														: const Text(
																'Start Verification',
																style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
															),
											),
										),
										const SizedBox(height: 16),
										if (_verificationCode != null) ...[
											Container(
												padding: const EdgeInsets.all(12),
												decoration: BoxDecoration(
													color: const Color(0xFF141316),
													borderRadius: BorderRadius.circular(8),
												),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(
															'Verification Code',
															style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold),
														),
														const SizedBox(height: 6),
														SelectableText(
															_verificationCode!,
															style: const TextStyle(color: Colors.white, fontSize: 18),
														),
														const SizedBox(height: 12),
														Text(
															_instructions ?? 'Set this as your LeetCode Real Name, then wait for verification.',
															style: TextStyle(color: Colors.grey[400]),
														),
														const SizedBox(height: 8),
														if (_secondsLeft > 0)
															Text(
																'Auto-checking... $_secondsLeft s left',
																style: const TextStyle(color: Color(0xFFF6C156)),
															),
													],
												),
											),
										],
										const Spacer(),
										TextButton(
											onPressed: () => context.go('/'),
											child: const Text('Skip for now', style: TextStyle(color: Color(0xFFF6C156))),
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}

	Future<void> _startVerification() async {
		final username = _usernameCtrl.text.trim();
		if (username.isEmpty) {
			setState(() => _error = 'Enter your LeetCode username');
			return;
		}
		setState(() {
			_loading = true;
			_error = null;
		});
		try {
			final service = context.read<LeetCodeService>();
			final resp = await service.startVerification(username);
			final status = await service.getStatus();
			if (status.isVerified) {
				if (!mounted) return;
				context.go('/');
				return;
			}
			setState(() {
				_verificationCode = resp.verificationCode;
				_instructions = resp.instructions;
				_secondsLeft = (resp.timeoutInSeconds ?? 120);
			});
			_startPolling();
		} on DioException catch (e) {
			setState(() => _error = ErrorUtils.fromDio(e));
		} catch (_) {
			setState(() => _error = 'Something went wrong');
		} finally {
			if (mounted) setState(() => _loading = false);
		}
	}

	void _startPolling() {
		_pollTimer?.cancel();
		// Poll every 5s until verified or timeout
		_pollTimer = Timer.periodic(const Duration(seconds: 5), (t) async {
			setState(() {
				_secondsLeft = (_secondsLeft - 5).clamp(0, 9999);
			});
			try {
				final status = await context.read<LeetCodeService>().getStatus();
				if (status.isVerified) {
					t.cancel();
					if (!mounted) return;
					context.go('/');
				} else if (_secondsLeft <= 0) {
					t.cancel();
					if (mounted) {
						setState(() => _error = 'Verification timed out. Try again.');
					}
				}
			} catch (e) {
				// Ignore transient errors and keep polling until timeout
			}
		});
	}
}

