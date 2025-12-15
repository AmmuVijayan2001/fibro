import 'dart:math';
import 'package:flutter/material.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class CouplerFlowPage extends StatefulWidget {
  const CouplerFlowPage({super.key});

  @override
  State<CouplerFlowPage> createState() => _CouplerFlowPageState();
}

class _CouplerFlowPageState extends State<CouplerFlowPage> {
  final TextEditingController _inputPowerController = TextEditingController(
    text: "8",
  );
  final ScrollController _scrollController = ScrollController();
  List<CouplerData> couplers = [];

  void _addCoupler() {
    setState(() {
      couplers.add(CouplerData());
    });

    // Scroll to the last added coupler
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('New coupler added!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeCoupler(int index) {
    setState(() {
      couplers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentPower = double.tryParse(_inputPowerController.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Network Design",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCoupler,
        backgroundColor: appClr,
        child: const Icon(Icons.add, color: whiteClr),
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Attach the controller here
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputNode(),
            const SizedBox(height: 24),
            ...List.generate(couplers.length, (index) {
              couplers[index].inputPower = currentPower;
              currentPower = couplers[index].outputPower1;
              return Column(
                children: [
                  _buildCouplerCard(index),
                  if (index != couplers.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.arrow_downward,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInputNode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appClr.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appClr, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            "Input Node",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputPowerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Input Power (dBm)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _removeCoupler(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Coupler is Removed Successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(Icons.close, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Coupler ${index + 1}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.device_hub, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: coupler.couplerType,
                  underline: const SizedBox(),
                  onChanged: (newValue) {
                    setState(() {
                      coupler.couplerType = newValue!;
                    });
                  },
                  items:
                      <String>["Coupler 95/05", "Coupler 50/50"]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOutputDisplay(
                  coupler.outputPower1,
                  coupler.distance1,
                  isLeft: true,
                  onDistanceChanged: (val) {
                    setState(() {
                      coupler.distance1 = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOutputDisplay(
                  coupler.outputPower2,
                  coupler.distance2,
                  isLeft: false,
                  onDistanceChanged: (val) {
                    setState(() {
                      coupler.distance2 = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputDisplay(
    double power,
    double distance, {
    bool isLeft = true,
    required Function(double) onDistanceChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isLeft
                ? Colors.blueAccent.withOpacity(0.15)
                : Colors.greenAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Distance (Km)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              double km = double.tryParse(val) ?? 0;
              onDistanceChanged(km);
            },
          ),
          const SizedBox(height: 8),
          Text(
            "Power: ${power.toStringAsFixed(2)} dBm",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CouplerData {
  double inputPower;
  String couplerType;
  double lossPerKm;
  double distance1;
  double distance2;

  CouplerData({
    this.inputPower = 0,
    this.couplerType = "Coupler 95/05",
    this.lossPerKm = 0.2,
    this.distance1 = 0,
    this.distance2 = 0,
  });

  double get outputPower1 {
    List<double> ratio = _getSplitRatio(couplerType);
    return inputPower + 10 * log(ratio[0]) / ln10 - (distance1 * lossPerKm);
  }

  double get outputPower2 {
    List<double> ratio = _getSplitRatio(couplerType);
    return inputPower + 10 * log(ratio[1]) / ln10 - (distance2 * lossPerKm);
  }

  List<double> _getSplitRatio(String type) {
    if (type == "Coupler 95/05") {
      return [0.95, 0.05];
    } else if (type == "Coupler 50/50") {
      return [0.5, 0.5];
    }
    return [0.5, 0.5]; // Default safety fallback
  }
}
