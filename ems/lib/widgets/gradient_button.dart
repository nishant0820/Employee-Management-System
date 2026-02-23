import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
	const GradientButton({
		super.key,
		required this.label,
		required this.onPressed,
		this.icon,
		this.height = 52,
		this.width = double.infinity,
		this.borderRadius = 12,
		this.padding = const EdgeInsets.symmetric(horizontal: 20),
		this.gradient,
	});

	final String label;
	final VoidCallback? onPressed;
	final IconData? icon;
	final double height;
	final double width;
	final double borderRadius;
	final EdgeInsetsGeometry padding;
	final Gradient? gradient;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		final isDisabled = onPressed == null;

		final activeGradient =
				gradient ??
				LinearGradient(
					colors: [colorScheme.primary, colorScheme.tertiary],
					begin: Alignment.centerLeft,
					end: Alignment.centerRight,
				);

		return Opacity(
			opacity: isDisabled ? 0.6 : 1,
			child: SizedBox(
				width: width,
				height: height,
				child: DecoratedBox(
					decoration: BoxDecoration(
						gradient: activeGradient,
						borderRadius: BorderRadius.circular(borderRadius),
					),
					child: Material(
						color: Colors.transparent,
						child: InkWell(
							onTap: onPressed,
							borderRadius: BorderRadius.circular(borderRadius),
							child: Padding(
								padding: padding,
								child: Center(
									child: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											if (icon != null) ...[
												Icon(icon, color: colorScheme.onPrimary),
												const SizedBox(width: 10),
											],
											Text(
												label,
												style: Theme.of(context).textTheme.titleMedium
														?.copyWith(
															color: colorScheme.onPrimary,
															fontWeight: FontWeight.w600,
														),
											),
										],
									),
								),
							),
						),
					),
				),
			),
		);
	}
}
