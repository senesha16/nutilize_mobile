import 'package:flutter/material.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NUtilizeLogo extends StatelessWidget {
  final double height;
  const NUtilizeLogo({this.height = 56, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'N',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: height * 0.85,
              color: const Color(0xFF233B7A),
              letterSpacing: -2,
              fontFamily: 'Roboto',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.08),
            child: Text(
              'UTILIZE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: height * 0.67,
                color: const Color(0xFFF5BC1D),
                letterSpacing: -2,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showReservationStatusDialog(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
      return _ReservationStatusDialogContent(
        size: size,
        bottomPadding: bottomPadding,
      );
    },
  );
}

class _ReservationStatusDialogContent extends StatefulWidget {
  final Size size;
  final double bottomPadding;
  const _ReservationStatusDialogContent({
    required this.size,
    required this.bottomPadding,
  });

  @override
  State<_ReservationStatusDialogContent> createState() =>
      _ReservationStatusDialogContentState();
}

class _ReservationStatusDialogContentState
    extends State<_ReservationStatusDialogContent> {
  File? _selectedImage;
  final TextEditingController _descController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height - widget.bottomPadding,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // ...existing code...
          // Header
          Container(
            width: double.infinity,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF233B7A),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Center(
                  child: Text(
                    'Reservation Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Progress Bar
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFFF5BC1D),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // Main Card with Timeline
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF233B7A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'NUtilize Status Reservation',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _ReservationTimeline(),
                      ],
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF233B7A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return Container(
                                          width: 340,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF233B7A),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.apartment_rounded,
                                                      color: Colors.white,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'NUtilize ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              'Reporting form',
                                                        ),
                                                      ],
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    'Proof',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '*',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: () async {
                                                  final source = await showModalBottomSheet<ImageSource>(
                                                    context: context,
                                                    builder: (context) {
                                                      return SafeArea(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ListTile(
                                                              leading: const Icon(
                                                                Icons
                                                                    .photo_library,
                                                              ),
                                                              title: const Text(
                                                                'Gallery',
                                                              ),
                                                              onTap: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(
                                                                    ImageSource
                                                                        .gallery,
                                                                  ),
                                                            ),
                                                            ListTile(
                                                              leading: const Icon(
                                                                Icons
                                                                    .camera_alt,
                                                              ),
                                                              title: const Text(
                                                                'Camera',
                                                              ),
                                                              onTap: () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(
                                                                    ImageSource
                                                                        .camera,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  if (source != null) {
                                                    final picker =
                                                        ImagePicker();
                                                    final pickedFile =
                                                        await picker.pickImage(
                                                          source: source,
                                                          maxWidth: 1200,
                                                          maxHeight: 1200,
                                                          imageQuality: 85,
                                                        );
                                                    if (pickedFile != null) {
                                                      setStateDialog(() {});
                                                      setState(() {
                                                        _selectedImage = File(
                                                          pickedFile.path,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFEDEDED),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      _selectedImage != null
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: Image.file(
                                                                _selectedImage!,
                                                                width: 56,
                                                                height: 56,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : const Icon(
                                                              Icons.folder,
                                                              size: 36,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      const SizedBox(width: 12),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: const [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                  top: 20,
                                                                ),
                                                            child: Text(
                                                              'Upload Image',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'JPG, PNG, up to 5mb',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Text(
                                                    'Description',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '*',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF7F7F7),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: TextField(
                                                  controller: _descController,
                                                  maxLines: 3,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText:
                                                            'Input Description',
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 14,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(
                                                      0xFF233B7A,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) => Center(
                                                        child: Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: Container(
                                                            width: 340,
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  24,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        32,
                                                                      ),
                                                                ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                // Logo
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets.only(
                                                                        bottom:
                                                                            16,
                                                                      ),
                                                                  child:
                                                                      NUtilizeLogo(
                                                                        height:
                                                                            56,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                const Text(
                                                                  'Successfully Reported',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        28,
                                                                    color: Color(
                                                                      0xFF233B7A,
                                                                    ),
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                const Text(
                                                                  'Thank you for your feedback!',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                const SizedBox(
                                                                  height: 28,
                                                                ),
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Color(
                                                                            0xFF233B7A,
                                                                          ),
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                    },
                                                                    child: const Text(
                                                                      'Done',
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Submit Report',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Issue report',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF233B7A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Print',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Timeline data (hardcoded for now)
    final steps = [
      (
        'Mar 12 10:10 AM',
        'Reservation confirmed',
        'ML Tournament | Intrams',
        true,
      ),
      (
        'Mar 12 10:07 AM',
        'Reservation approved',
        'Reservation approved by the administrator.',
        false,
      ),
      (
        'Mar 12 4:24 AM',
        'Reservation under review',
        'Your reservation request is under review.',
        false,
      ),
      (
        'Mar 12 4:03 AM',
        'Received by system',
        'Your reservation request has been received by the system.',
        false,
      ),
      (
        'Mar 12 3:44 AM',
        'Received by system',
        'Your reservation request has been received by the system.',
        false,
      ),
      (
        'Mar 12 12:04 AM',
        'Forwarded for approval',
        'Your reservation request has been logged and forwarded for approval.',
        false,
      ),
      (
        'Mar 12 12:01 AM',
        'Submitted',
        'Your reservation request has been submitted.',
        false,
      ),
    ];
    return Column(
      children: List.generate(steps.length, (i) {
        final (time, title, subtitle, isActive) = steps[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFF5BC1D)
                        : const Color(0xFF233B7A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isActive
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 4,
                    height: 38,
                    color: const Color(0xFF233B7A),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF233B7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFFF5BC1D)
                            : const Color(0xFF233B7A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
