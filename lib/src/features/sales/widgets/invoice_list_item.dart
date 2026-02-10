import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rise_flutter_exercise/src/features/sales/models/sales_invoice_model.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_card.dart';
import 'package:rise_flutter_exercise/src/globals/widgets/rise_status_badge.dart';
import 'package:rise_flutter_exercise/src/globals/theme/rise_theme.dart';

/// A list item widget for displaying sales invoices that matches the Rise design system
class InvoiceListItem extends StatelessWidget {
  final SalesInvoiceListItemModel invoice;
  final String companyId;

  const InvoiceListItem({
    super.key,
    required this.invoice,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riseTheme = theme.extension<RiseAppThemeExtension>();
    final colors = riseTheme?.config.colors;
    final textTheme = theme.textTheme;

    return RiseCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () {
        context.go('/sales-invoices/${invoice.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.description ?? 'Invoice',
                      style: textTheme.titleMedium?.copyWith(
                        color: colors?.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (invoice.recipient?.name != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 16,
                              color: colors?.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                invoice.recipient!.name!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors?.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (invoice.invoiceDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: colors?.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              invoice.invoiceDate!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors?.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (invoice.grossAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '€${invoice.grossAmount}',
                        style: textTheme.titleLarge?.copyWith(
                          color: colors?.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (invoice.status != null)
                    RiseStatusBadge(status: invoice.status!, isCompact: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
