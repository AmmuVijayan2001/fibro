import 'package:flutter/material.dart';
import 'package:network_mapping_app/Data/Resources/NetworkDesisgnApi/network_repository.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Models/network_design_model.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class CouplerFlowPage extends StatefulWidget {
  final NetworkDesignModel? existingDesign;
  const CouplerFlowPage({super.key, this.existingDesign});

  @override
  State<CouplerFlowPage> createState() => _CouplerFlowPageState();
}

class _CouplerFlowPageState extends State<CouplerFlowPage> {
  final TextEditingController _inputPowerController = TextEditingController(
    text: "",
  );
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CouplerData> couplers = [];
  String? _currentDesignId;

  @override
  void initState() {
    super.initState();
    if (widget.existingDesign != null) {
      _loadExistingDesign(widget.existingDesign!);
    }
  }

  void _loadExistingDesign(NetworkDesignModel design) {
    _currentDesignId = design.id;
    _nameController.text = design.name;
    _inputPowerController.text = design.initialInputPower.toString();
    // Deep copy couplers to avoid mutating the saved list directly until saved again
    couplers = design.couplers.map((c) => c.copy()).toList();
  }

  void _addCoupler() {
    setState(() {
      couplers.add(CouplerData(couplerType: "10/90"));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('New coupler added!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeCoupler(int index) {
    setState(() {
      couplers.removeAt(index);
    });
  }

  Future<void> _saveDesign() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please enter a Design Name"),
        ),
      );
      return;
    }

    setState(() {});

    final repo = NetworkRepository();
    final newDesign = NetworkDesignModel(
      id: _currentDesignId,
      name: _nameController.text.trim(),
      createdAt: DateTime.now(),
      initialInputPower: double.tryParse(_inputPowerController.text) ?? 0.0,
      couplers: couplers.map((c) => c.copy()).toList(),
    );

    try {
      await repo.saveDesign(newDesign);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Design Saved Successfully!"),
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error saving design: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentPower = double.tryParse(_inputPowerController.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: const AppTextwidget(
          text: "Network Design",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        actions: const [],
        backgroundColor: appClr,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton:
          widget.existingDesign == null
              ? FloatingActionButton.extended(
                onPressed: _addCoupler,
                backgroundColor: appClr,
                icon: const Icon(Icons.add, color: whiteClr),
                label: const Text(
                  "Add Coupler",
                  style: TextStyle(color: whiteClr),
                ),
              )
              : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Name Input Logic
            _buildNameInput(),
            const SizedBox(height: 16),
            _buildInputNode(),
            const SizedBox(height: 24),

            if (couplers.isNotEmpty) _buildConnectorLine(),

            ...List.generate(couplers.length, (index) {
              couplers[index].inputPower = currentPower;
              currentPower = couplers[index].outputPower2;

              return Column(
                children: [
                  _buildCouplerCard(index),
                  if (index != couplers.length - 1) _buildConnectorLine(),
                ],
              );
            }),
            if (couplers.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveDesign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appClr,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        "Save Network Design",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      height: 30,
      child: const VerticalDivider(color: Colors.grey, thickness: 2, width: 20),
    );
  }

  Widget _buildNameInput() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: "Design Name",
        hintText: "e.g. Area 51 Expansion",
        prefixIcon: const Icon(Icons.edit, color: Colors.black),

        filled: true,
        fillColor: Colors.white,

        // DEFAULT BORDER
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black, width: 1.2),
        ),

        // ENABLED (NOT FOCUSED)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),

        // FOCUSED BORDER
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: appClr, width: 1.8),
        ),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold, color: blackClr),
    );
  }

  Widget _buildInputNode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appClr.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: appClr.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: appClr.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.router, color: appClr, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                "OLT / Head End",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputPowerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: appClr,
            ),
            decoration: InputDecoration(
              labelText: "Input Power (dBm)",
              labelStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.flash_on, color: Colors.amber),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: appClr, width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCouplerCard(int index) {
    final coupler = couplers[index];
    final selectedCouplerDetails = couplerLossMap[coupler.couplerType];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appClr.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "#${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appClr,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Optical Coupler",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              if (widget.existingDesign == null)
                IconButton(
                  onPressed: () => _removeCoupler(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Remove Coupler",
                ),
            ],
          ),

          const Divider(height: 24),

          // Coupler Selection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: coupler.couplerType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (newValue) {
                  setState(() {
                    coupler.couplerType = newValue!;
                  });
                },
                items:
                    asymmetricCouplers.map((Coupler c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Tap: ${c.loss1}dB / Thru: ${c.loss2}dB",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Outputs Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TAP / DROP Side (Loss 1)
              Expanded(
                child: _buildOutputColumn(
                  title: "Tap (Drop)",
                  pow: coupler.outputPower1,
                  dist: coupler.distance1,
                  loss: selectedCouplerDetails?.loss1 ?? 0,
                  color: Colors.orange,
                  icon: Icons.download_rounded,
                  onDistChanged:
                      (val) => setState(() => coupler.distance1 = val),
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                height: 120,
                color: Colors.grey.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // THROUGH Side (Loss 2)
              Expanded(
                child: _buildOutputColumn(
                  title: "Through (Next)",
                  pow: coupler.outputPower2,
                  dist: coupler.distance2,
                  loss: selectedCouplerDetails?.loss2 ?? 0,
                  color: Colors.green,
                  icon: Icons.arrow_forward_rounded,
                  onDistChanged:
                      (val) => setState(() => coupler.distance2 = val),
                  isThrough: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Input Power Display for this coupler check
          Center(
            child: Text(
              "Input at this stage: ${coupler.inputPower.toStringAsFixed(2)} dBm",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputColumn({
    required String title,
    required double pow,
    required double dist,
    required double loss,
    required Color color,
    required IconData icon,
    required Function(double) onDistChanged,
    bool isThrough = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "Loss: -${loss}dB",
            style: TextStyle(fontSize: 10, color: color),
          ),
        ),
        const SizedBox(height: 12),
        // Distance Input
        SizedBox(
          height: 45,
          child: DistanceInputField(
            initialValue: dist,
            onChanged: onDistChanged,
          ),
        ),
        const SizedBox(height: 12),
        // Power Result
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                "${pow.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color.withRed(
                    color.red > 100 ? 200 : 0,
                  ), // Darken a bit if needed
                ),
              ),
              const Text(
                "dBm",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DistanceInputField extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const DistanceInputField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<DistanceInputField> createState() => _DistanceInputFieldState();
}

class _DistanceInputFieldState extends State<DistanceInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    String text =
        widget.initialValue == 0 ? "" : widget.initialValue.toString();
    _controller = TextEditingController(text: text);
  }

  @override
  void didUpdateWidget(covariant DistanceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't overwrite if actively typing to prevent cursor jumps
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        labelText: "Dist(km)",
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (val) {
        double km = double.tryParse(val) ?? 0;
        widget.onChanged(km);
      },
    );
  }
}
