import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final List<String> sizes;
  final Function(String)? onSizeSelected;
  final String? initalSize;
  const SizeSelector({
    super.key,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.onSizeSelected,
    this.initalSize,
  });

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    //set inital selected index based on initialSize
    if (widget.initalSize != null) {
      final index = widget.sizes.indexOf(widget.initalSize!);
      if (index != -1) {
        _selectedIndex = index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.sizes.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() =>_selectedIndex==index);
              if(widget.onSizeSelected!=null){
                widget.onSizeSelected!(widget.sizes[index]);
              }
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isDark
                      ? Colors.grey[700]!
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  widget.sizes[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
