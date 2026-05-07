import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/offer_model.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OrderOfferListWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  final String orderId;
  final bool compact;
  const OrderOfferListWidget({
    super.key,
    required this.checkoutController,
    required this.orderId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (checkoutController.isOfferLoading &&
        checkoutController.offerList == null) {
      return SizedBox(
        height: compact ? 110 : 150,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (checkoutController.offerList == null ||
        checkoutController.offerList!.isEmpty) {
      return const SizedBox.shrink();
    }

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: compact
          ? double.infinity
          : isDesktop
              ? 720
              : double.infinity,
      margin: EdgeInsets.only(
          top: compact
              ? Dimensions.paddingSizeDefault
              : Dimensions.paddingSizeLarge),
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 0 : Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? Dimensions.paddingSizeDefault : 0),
          child: Row(children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.local_offer_rounded,
                  color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exclusive offers unlocked',
                      style: robotoBold.copyWith(
                          fontSize: compact
                              ? Dimensions.fontSizeDefault
                              : Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Save one now and use it on your next order.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        SizedBox(
          height: compact
              ? 215
              : isDesktop
                  ? 248
                  : 258,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: compact ? Dimensions.paddingSizeDefault : 0),
            itemCount: checkoutController.offerList!.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              OfferModel offer = checkoutController.offerList![index];
              return _OfferCard(
                offer: offer,
                width: compact
                    ? 300
                    : isDesktop
                        ? 340
                        : context.width * 0.82,
                compact: compact,
                isLoading: checkoutController.selectedOfferId == offer.id,
                onTap: () async {
                  if (offer.id == null) {
                    return;
                  }
                  bool saved = await checkoutController.saveOfferClick(
                      offerId: offer.id!, orderId: orderId);
                  if (saved) {
                    await HomeScreen.loadData(true);
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  }
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  final double width;
  final bool compact;
  final bool isLoading;
  final Function() onTap;
  const _OfferCard({
    required this.offer,
    required this.width,
    required this.compact,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color darkText = Theme.of(context).textTheme.bodyLarge!.color!;
    String discountText = offer.offerType == 'percent'
        ? '${_formatAmount(offer.offerValue)}% OFF'
        : '${PriceConverter.convertPrice(offer.calculatedDiscount ?? offer.offerValue ?? 0)} OFF';
    String minOrderText = offer.minOrderAmount != null
        ? 'Min order ${PriceConverter.convertPrice(offer.minOrderAmount!)}'
        : '';
    String validText = offer.endDate != null
        ? 'Valid till ${DateConverter.stringToReadableString(offer.endDate!)}'
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: compact ? 88 : 112,
                width: double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  offer.bannerImageFullUrl != null &&
                          offer.bannerImageFullUrl!.isNotEmpty
                      ? CustomImageWidget(
                          image: offer.bannerImageFullUrl!, fit: BoxFit.cover)
                      : Container(
                          color: primaryColor.withValues(alpha: 0.12),
                          alignment: Alignment.center,
                          child: Icon(Icons.local_offer_rounded,
                              color: primaryColor, size: compact ? 34 : 42),
                        ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.48),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: Dimensions.paddingSizeSmall,
                    bottom: Dimensions.paddingSizeSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.bolt_rounded, color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(discountText,
                            style: robotoBold.copyWith(
                                color: primaryColor,
                                fontSize: Dimensions.fontSizeSmall)),
                      ]),
                    ),
                  ),
                  Positioned(
                    right: Dimensions.paddingSizeSmall,
                    top: Dimensions.paddingSizeSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.offerType == 'percent' ? 'Percentage' : 'Flat',
                        style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title ?? discountText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                              color: darkText,
                              fontSize: compact
                                  ? Dimensions.fontSizeSmall
                                  : Dimensions.fontSizeDefault),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.description ?? offer.termsConditions ?? '',
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (minOrderText.isNotEmpty)
                              _InfoChip(
                                  icon: Icons.shopping_bag_outlined,
                                  text: minOrderText),
                            if (validText.isNotEmpty)
                              _InfoChip(
                                  icon: Icons.event_available_outlined,
                                  text: validText),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: isLoading
                                ? Theme.of(context).disabledColor
                                : primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Icon(Icons.bookmark_add_rounded,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text('Save offer',
                                          style: robotoBold.copyWith(
                                              color: Colors.white,
                                              fontSize:
                                                  Dimensions.fontSizeSmall)),
                                    ]),
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 155),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.14)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeExtraSmall),
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
