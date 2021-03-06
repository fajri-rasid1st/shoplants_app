import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoplants/data/models/cart.dart';
import 'package:shoplants/data/utils/cart_preferences.dart';
import 'package:shoplants/data/utils/const.dart';
import 'package:shoplants/ui/pages/checkout_page.dart';
import 'package:shoplants/ui/screens/detail_screen.dart';
import 'package:shoplants/ui/styles/button_style.dart';
import 'package:shoplants/ui/styles/color_scheme.dart';
import 'package:shoplants/ui/styles/text_style.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // initialize empty cart
  List<Cart> _carts = [];

  @override
  void initState() {
    updateCart();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: primaryTextColor,
          tooltip: 'Back',
        ),
        title: Text(
          'My Cart',
          style: defaultHeader1,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _carts.isEmpty ? null : () => deleteAllCarts(_carts),
            icon: const Icon(Icons.delete_outline_rounded),
            color: primaryTextColor,
            tooltip: 'Clear Cart',
          )
        ],
        elevation: 0.8,
        titleSpacing: 16,
        toolbarHeight: 64,
        backgroundColor: backGroundColor,
      ),
      body: _carts.isEmpty ? buildEmptyCart() : buildListCart(),
    );
  }

  Center buildEmptyCart() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              "assets/svg/Unboxing-cuate.svg",
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            Text(
              'Oops, your cart is still empty!',
              style: defaultHeader2,
            ),
            Text(
              'Your cart list will appear here.',
              style: TextStyle(color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildListCart() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => buildCartItem(_carts[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: _carts.length,
    );
  }

  InkWell buildCartItem(Cart cart) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              plant: cart.plant,
              previousScreen: runtimeType.toString(),
            ),
          ),
        ).then((_) => updateCart());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: dividerColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: cart.plant.imgUrls[1],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 200),
                    placeholder: (context, url) {
                      return Center(
                        child: SpinKitPulse(color: secondaryColor),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        cart.plant.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: defaultTitle,
                      ),
                      Text(
                        cart.plant.alias,
                        style: TextStyle(color: secondaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: \$${cart.plant.price}',
                        style: primaryHeader2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => deleteSelectedCart(cart),
                    child: const Text('Delete'),
                    style: outlinedButtonStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) {
                          return CheckoutPage(plant: cart.plant, cart: cart);
                        },
                        backgroundColor: backGroundColor,
                      );
                    },
                    child: const Text(
                      "Checkout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: elevatedButtonStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateCart() async {
    // obtain shared preference
    final prefs = await SharedPreferences.getInstance();

    // get all keys except default user
    final cartKeys = prefs.getKeys().where((key) {
      return key != Const.userId;
    }).toList();

    final newCarts = <Cart>[];

    for (var key in cartKeys) {
      newCarts.add(CartPreferences.getCart(key)!);
    }

    setState(() => _carts = newCarts);
  }

  Future<void> deleteSelectedCart(Cart cart) async {
    // obtain shared preference
    final prefs = await SharedPreferences.getInstance();

    prefs.remove(cart.id).then((isSuccess) {
      if (isSuccess) {
        // update cart list
        updateCart();

        // create snackbar
        SnackBar snackBar = SnackBar(
          content: Text(
            'Successfully removed from your cart',
            style: snackBarTitle,
          ),
          duration: const Duration(seconds: 3),
        );

        // show snackbar
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    });
  }

  Future<void> deleteAllCarts(List<Cart> carts) async {
    // obtain shared preference
    final prefs = await SharedPreferences.getInstance();

    for (var cart in carts) {
      prefs.remove(cart.id).then((isSuccess) {
        if (isSuccess) updateCart();
      });
    }

    // create snackbar
    SnackBar snackBar = SnackBar(
      content: Text(
        'Successfully clear your cart',
        style: snackBarTitle,
      ),
      duration: const Duration(seconds: 3),
    );

    // show snackbar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
