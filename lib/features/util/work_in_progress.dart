import 'package:flutter/material.dart';


void showCustomMessage(BuildContext context, {required String title, required String description}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WipDialog(title: title, description: description);
    },
  );
}
void showWipPopup(BuildContext context, {required String title, required String description}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WipDialog(title: title, description: description);
    },
  );
}

class WipDialog extends StatelessWidget {
  final String title;
  final String description;

  const WipDialog({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: const Color(0xffFF8A00), // Orange matching your theme
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          right: 16.0,
          left: 24.0,
          bottom: 60.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}