import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offer_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OfferDetailsScreen extends StatelessWidget {
  final OfferModel offer;
  final String orderId;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    String discountText = offer.offerType == 'percent'
        ? '${_formatAmount(offer.offerValue)}% OFF'
        : '${PriceConverter.convertPrice(offer.calculatedDiscount ?? offer.offerValue ?? 0)} OFF';

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'Offer Details'),
      bottomNavigationBar:
          GetBuilder<CheckoutController>(builder: (checkoutController) {
        bool isLoading = checkoutController.selectedOfferId == offer.id;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: CustomButtonWidget(
              buttonText: 'Claim Offer',
              icon: Icons.open_in_browser_rounded,
              isLoading: isLoading,
              onPressed: offer.id == null
                  ? null
                  : () => _claimOffer(checkoutController),
            ),
          ),
        );
      }),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: isDesktop ? 0 : Dimensions.paddingSizeDefault,
          right: isDesktop ? 0 : Dimensions.paddingSizeDefault,
          top: Dimensions.paddingSizeDefault,
          bottom: 100,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: isDesktop ? 2.6 : 1.8,
                    child: offer.bannerImageFullUrl != null &&
                            offer.bannerImageFullUrl!.isNotEmpty
                        ? CustomImageWidget(
                            image: offer.bannerImageFullUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.12),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 64,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text(
                  offer.title ?? discountText,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.local_offer_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      discountText,
                      style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Wrap(
                  spacing: Dimensions.paddingSizeSmall,
                  runSpacing: Dimensions.paddingSizeSmall,
                  children: [
                    _DetailChip(
                      icon: Icons.local_offer_outlined,
                      title: 'Type',
                      value:
                          offer.offerType == 'percent' ? 'Percentage' : 'Flat',
                    ),
                    _DetailChip(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Minimum order',
                      value: offer.minOrderAmount != null
                          ? PriceConverter.convertPrice(offer.minOrderAmount!)
                          : 'No minimum',
                    ),
                    _DetailChip(
                      icon: Icons.savings_outlined,
                      title: 'Max discount',
                      value: offer.maxDiscountAmount != null
                          ? PriceConverter.convertPrice(
                              offer.maxDiscountAmount!)
                          : 'No limit',
                    ),
                    _DetailChip(
                      icon: Icons.event_available_outlined,
                      title: 'Valid till',
                      value: offer.endDate != null
                          ? DateConverter.stringToReadableString(offer.endDate!)
                          : 'No expiry',
                    ),
                  ],
                ),
                _Section(
                  title: 'Description',
                  body: offer.description?.trim().isNotEmpty == true
                      ? offer.description!.trim()
                      : 'No description available.',
                ),
                _Section(
                  title: 'Terms & Conditions',
                  body: offer.termsConditions?.trim().isNotEmpty == true
                      ? offer.termsConditions!.trim()
                      : 'No terms available.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _claimOffer(CheckoutController checkoutController) async {
    bool saved = await checkoutController.saveOfferClick(
        offerId: offer.id!, orderId: orderId);
    if (!saved) {
      return;
    }

    String? url = offer.websiteUrl?.trim();
    if (url == null || url.isEmpty) {
      showCustomSnackBar('Offer website is not available');
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    await launchUrlString(url, mode: LaunchMode.externalApplication);
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          ResponsiveHelper.isDesktop(context) ? 178 : (context.width - 48) / 2,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeExtraSmall,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          body,
          style: robotoRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            height: 1.45,
          ),
        ),
      ]),
    );
  }
}

String _formatAmount(double? value) {
  if (value == null) {
    return '0';
  }
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}
