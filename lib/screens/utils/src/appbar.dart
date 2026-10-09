import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppbarCustom extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onChanged;
  final List<Widget>? actions;
  final Widget? nonSearchTitle;
  final String searchHintText;
  final Color? backgroundColor;

  const AppbarCustom({
    super.key,
    this.onChanged,
    this.actions,
    this.nonSearchTitle,
    this.searchHintText = "Search here",
    this.backgroundColor,
  });

  @override
  State<AppbarCustom> createState() => _AppbarCustomState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // ✅ Moved here
}

class _AppbarCustomState extends State<AppbarCustom> {
  bool searchApplied = false;
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: child.key == const ValueKey("searchAppBar")
              ? const Offset(-1.0, 0.0)
              : const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      child: searchApplied
          ? AppBar(
              key: const ValueKey("searchAppBar"),
              backgroundColor:
                  widget.backgroundColor ?? Theme.of(context).primaryColor,
              shadowColor: Theme.of(context).shadowColor,
              leading: IconButton(
                tooltip: "Back",
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () {
                  setState(() {
                    searchApplied = false;
                    search.clear();
                  });
                },
              ),
              title: TextFormField(
                controller: search,
                autofocus: true,
                cursorColor: Colors.white,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: widget.searchHintText,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(color: Colors.white),
                autocorrect: false,
                enableSuggestions: false,
              ),
            )
          : AppBar(
              leading: IconButton(
                tooltip: "Back",
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              key: const ValueKey("mainAppBar"),
              backgroundColor:
                  widget.backgroundColor ?? Theme.of(context).primaryColor,
              title: widget.nonSearchTitle ?? const SizedBox.shrink(),
              actions: [
                ...?widget.actions,
                IconButton(
                  icon: const Icon(Iconsax.search_normal, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      searchApplied = true;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
