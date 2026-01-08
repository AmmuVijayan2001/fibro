import 'package:flutter/material.dart';
import 'package:network_mapping_app/Application/Presentation/NetworkDesignScreen/networkdesign.dart';
import 'package:network_mapping_app/Data/Resources/NetworkDesisgnApi/network_repository.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

import 'package:network_mapping_app/Domine/Models/network_design_model.dart';
import 'package:intl/intl.dart';

class Networkdesignsavedscreen extends StatefulWidget {
  const Networkdesignsavedscreen({super.key});

  @override
  State<Networkdesignsavedscreen> createState() =>
      _NetworkdesignsavedscreenState();
}

class _NetworkdesignsavedscreenState extends State<Networkdesignsavedscreen> {
  final NetworkRepository _repository = NetworkRepository();
  List<NetworkDesignModel> _designs = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final designs = await _repository.getDesigns();

      designs.sort((a, b) {
        int idA = int.tryParse(a.id ?? "0") ?? 0;
        int idB = int.tryParse(b.id ?? "0") ?? 0;
        return idB.compareTo(idA);
      });

      setState(() {
        _designs = designs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading designs: $e')));
    }
  }

  Future<void> _deleteDesign(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Design"),
            content: const Text(
              "Are you sure you want to delete this network design?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _designs.removeWhere((d) => d.id == id);
      });

      try {
        await _repository.deleteDesign(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Design deleted successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error deleting design: $e")));
          _loadDesigns();
        }
      }
    }
  }

  void _navigateToDesign([NetworkDesignModel? design]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouplerFlowPage(existingDesign: design),
      ),
    );

    _loadDesigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined, color: whiteClr),
        ),
        title: const AppTextwidget(
          text: "Saved Network Designs",
          color: whiteClr,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: appClr,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddNewDesignCard(),
            const SizedBox(height: 24),
            const AppTextwidget(
              text: "Your Designs",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackClr,
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Error: $_errorMessage"),
                            TextButton(
                              onPressed: _loadDesigns,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                      : _designs.isEmpty
                      ? const Center(
                        child: Text(
                          "No designs saved yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _designs.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildSavedDesignCard(_designs[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewDesignCard() {
    return GestureDetector(
      onTap: () => _navigateToDesign(null),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appClr, appClr.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: appClr.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTextwidget(
                  text: "Create New Design",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: whiteClr,
                ),
                const SizedBox(height: 6),
                const AppTextwidget(
                  text: "Start a new optical network project",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: whiteClr, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDesignCard(NetworkDesignModel design) {
    String formattedDate =
        design.createdAt != null
            ? DateFormat('MMM d, y').format(design.createdAt!)
            : "N/A";

    return GestureDetector(
      onTap: () => _navigateToDesign(design),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteClr,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(3, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEFT ICON
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: appClr.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grid_on_rounded, color: appClr),
            ),

            const SizedBox(width: 16),

            /// CENTER CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextwidget(
                    text: design.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blackClr,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppTextwidget(
                          text: formattedDate,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.cable, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      AppTextwidget(
                        text: "${design.couplers.length} Couplers",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (design.id != null) {
                      _deleteDesign(design.id!);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
