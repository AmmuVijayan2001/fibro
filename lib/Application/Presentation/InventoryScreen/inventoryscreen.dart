import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

class Inventoryscreen extends StatefulWidget {
  const Inventoryscreen({super.key});

  @override
  State<Inventoryscreen> createState() => _InventoryscreenState();
}

class _InventoryscreenState extends State<Inventoryscreen> {
  String selectedCategory = "Splitter";

  final Map<String, dynamic> inventoryData = {
    "Splitter": {
      "title": "Splitter",
      "subtitle": "Distributes optical signals",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.55 AM.jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.56 AM (1).jpeg",
      ],
      "details": [
        {"label": "Splitter Type", "value": "PLC Splitter, FBT Splitter"},
        {"label": "Split Ratios", "value": "1:2, 1:4, 1:8, 1:16, 1:32, 1:64"},
        {"label": "Connector Type", "value": "SC/APC, SC/UPC, LC/APC, LC/UPC"},
        {"label": "Mode Type", "value": "Single-mode (SM), Multi-mode (MM)"},
        {
          "label": "Packaging Type",
          "value": "Bare Fiber, Module, Box, Rack Mount",
        },
        {"label": "Operating Wavelength", "value": "1260 nm to 1650 nm"},
        {
          "label": "Insertion Loss",
          "value":
              "1:2 → ~3.5 dB\n1:4 → ~7.2 dB\n1:8 → ~10.5 dB\n1:16 → ~13.5 dB\n1:32 → ~17 dB\n1:64 → ~20 dB",
        },
        {"label": "Return Loss", "value": "≥ 55 dB (SC/APC type)"},
        {"label": "Fiber Type Supported", "value": "G.657.A1 / G.652.D"},
        {"label": "Temperature Range", "value": "Operating: -40°C to +85°C"},
      ],
    },

    "Coupler": {
      "title": "Coupler",
      "subtitle": "Combines or splits optical signals",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.58 AM (1).jpeg",
        "asset/images/coupler.jpg",
      ],
      "details": [
        {"label": "Type", "value": "FBT Coupler, PLC Coupler"},
        {"label": "Usage", "value": "Signal splitting or merging"},
        {
          "label": "Operating Wavelength",
          "value": "1310 nm / 1550 nm / 1490 nm",
        },
        {"label": "Splitting Ratios", "value": "50/50, 70/30, 80/20, etc."},
        {"label": "Connector Type", "value": "SC/APC, SC/UPC, LC/APC, LC/UPC"},
        {"label": "Return Loss", "value": "≥ 55 dB"},
        {"label": "Fiber Mode", "value": "Single-mode (SM)"},
      ],
    },

    "FiberCable": {
      "title": "Fiber Cables",
      "subtitle": "Carries light signals over distances",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.56 AM (3).jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.56 AM.jpeg",
      ],
      "details": [
        {
          "label": "Cable Types",
          "value": "Indoor, Outdoor, Armored, Unarmored",
        },
        {
          "label": "Fiber Type",
          "value":
              "Single-mode (OS1, OS2), Multi-mode (OM1, OM2, OM3, OM4, OM5)",
        },
        {
          "label": "Core/Cladding Size",
          "value": "9/125 µm (SM), 50/125 µm (MM), 62.5/125 µm (MM)",
        },
        {"label": "Jacket Material", "value": "LSZH, PVC, PE"},
        {"label": "Standards", "value": "ITU-T G.652D, G.657A1"},
        {"label": "Temperature Range", "value": "-20°C to +70°C"},
      ],
    },

    "ODF": {
      "title": "ODF (Optical Distribution Frame)",
      "subtitle": "Manages fiber cable terminations and connections",
      "images": ["asset/images/ODF.jpg", "asset/images/EU4834D-ODF-2.webp"],
      "details": [
        {"label": "Type", "value": "Rack-mounted ODF, Wall-mounted ODF"},
        {"label": "Material", "value": "Cold-rolled Steel, Aluminum"},
        {
          "label": "Capacity",
          "value": "12 Core, 24 Core, 48 Core, 96 Core, 144 Core",
        },
        {"label": "Applications", "value": "FTTH, Data Centers, Telecom Rooms"},
        {
          "label": "Accessories",
          "value": "Splice trays, Patch panels, Cable managers",
        },
      ],
    },

    "PatchCord": {
      "title": "Patch Cords",
      "subtitle": "Connects network devices in fiber systems",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.59 AM.jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.59 AM (1).jpeg",
      ],
      "details": [
        {"label": "Connector Type", "value": "SC, LC, ST, FC"},
        {"label": "Polish Type", "value": "APC, UPC"},
        {"label": "Fiber Type", "value": "Single-mode, Multi-mode"},
        {"label": "Cable Type", "value": "Simplex, Duplex"},
        {"label": "Length Options", "value": "1m, 2m, 3m, 5m, 10m, Custom"},
        {"label": "Insertion Loss", "value": "≤ 0.3 dB"},
      ],
    },

    "Switches": {
      "title": "Network Switches",
      "subtitle": "Manages data traffic within a network",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.03.00 AM.jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.57 AM (2).jpeg",
      ],
      "details": [
        {
          "label": "Switch Type",
          "value": "Managed, Unmanaged, Layer 2, Layer 3",
        },
        {"label": "Ports", "value": "8, 16, 24, 48 ports"},
        {"label": "Port Speed", "value": "1G, 10G, 40G, 100G Ethernet"},
        {"label": "PoE", "value": "Supported / Non-supported"},
        {"label": "Mounting Type", "value": "Rack-mount, Desktop"},
        {"label": "Usage", "value": "Enterprise, Data Center, Access Network"},
      ],
    },

    "OLT": {
      "title": "OLT",
      "subtitle":
          "Optical Line Terminal – Central office device powering the PON network",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.57 AM (1).jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.56 AM (2).jpeg",
      ],
      "details": [
        {"label": "OLT Type", "value": "GPON, EPON, XGS-PON, 10G-EPON"},
        {"label": "Ports", "value": "4, 8, 16, 32 GPON ports"},
        {"label": "Uplink Ports", "value": "GE/10GE/40GE"},
        {"label": "PON Capacity", "value": "2.488 Gbps DS / 1.244 Gbps US"},
        {"label": "Split Ratio", "value": "1:64, 1:128"},
        {"label": "Power Supply", "value": "AC 220V / DC -48V"},
        {"label": "Management", "value": "CLI, Web UI, SNMP, TR-069"},
        {"label": "Max ONTs", "value": "8,000–16,000"},
        {"label": "Operating Temperature", "value": "-10°C to +55°C"},
      ],
    },

    "ONT": {
      "title": "ONT",
      "subtitle": "Customer-end fiber termination device",
      "images": [
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.57 AM.jpeg",
        "asset/images/WhatsApp Image 2025-12-16 at 10.02.58 AM.jpeg",
      ],
      "details": [
        {"label": "ONT Type", "value": "GPON, EPON, WiFi ONT"},
        {"label": "Ports", "value": "1/2/4 LAN, Optional POTS, CATV"},
        {"label": "WiFi", "value": "2.4G / 5G Dual Band"},
        {"label": "Connector Type", "value": "SC/APC"},
        {"label": "Power Supply", "value": "12V DC"},
        {"label": "Features", "value": "WPS, VLAN, QoS, Firewall, NAT"},
        {"label": "Operating Temp", "value": "0°C to +45°C"},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: "Inventory",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedboxwidget(10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AppTextwidget(
              text: "Main Tools",
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: blackClr,
            ),
          ),
          sizedboxwidget(10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: appClr,
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 20,
                children: [
                  buildCategory(Icons.call_split, "Splitter"),
                  buildCategory(Icons.merge, "Coupler"),
                  buildCategory(Icons.cable, "FiberCable"),
                  buildCategory(Icons.dns, "ODF"),
                  buildCategory(Icons.settings_input_component, "PatchCord"),
                  buildCategory(Icons.hub, "Switches"),
                  buildCategory(Icons.dns, "OLT"),
                  buildCategory(Icons.wifi, "ONT"),
                ],
              ),
            ),
          ),
          sizedboxwidget(20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(child: buildCategoryDetails()),
            ),
          ),
          sizedboxwidget(20),
        ],
      ),
    );
  }

  Widget buildCategory(IconData iconData, String label) {
    final isSelected = selectedCategory == label;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 70,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 30, color: isSelected ? appClr : Colors.white),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? appClr : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryDetails() {
    var data = inventoryData[selectedCategory];

    if (data == null) {
      return Center(
        child: Text(
          "No Details Available for $selectedCategory",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      );
    }

    List images = data["images"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["title"],
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appClr,
          ),
        ),
        sizedboxwidget(5),
        Text(
          data["subtitle"],
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        sizedboxwidget(15),

        /// IMAGE ROW
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(images[0], height: 120, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child:
                  images.length > 1
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          images[1],
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
            ),
          ],
        ),

        sizedboxwidget(20),

        /// DETAILS LIST
        ...List.generate(
          data["details"].length,
          (index) => detailText(
            data["details"][index]["label"],
            data["details"][index]["value"],
          ),
        ),
      ],
    );
  }

  Widget detailText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appClr,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
