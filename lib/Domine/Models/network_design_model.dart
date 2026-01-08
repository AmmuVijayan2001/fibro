// import 'package:network_mapping_app/Application/Presentation/NetworkDesignScreen/networkdesign.dart'; // Removed unused import
class NetworkDesignModel {
  String? id;
  String name;
  double initialInputPower;
  List<CouplerData> couplers;
  DateTime? createdAt;
  String status;

  NetworkDesignModel({
    this.id,
    required this.name,
    required this.initialInputPower,
    required this.couplers,
    this.createdAt,
    this.status = "Draft",
  });

  factory NetworkDesignModel.fromJson(Map<String, dynamic> json) {
    var couplerList = json['couplers'] as List? ?? [];
    List<CouplerData> couplerObjs =
        couplerList.map((i) => CouplerData.fromJson(i)).toList();

    return NetworkDesignModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      initialInputPower: (json['input_power'] as num?)?.toDouble() ?? 0.0,
      couplers: couplerObjs,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now(),
      status: json['status'] ?? "Active",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'input_power': initialInputPower,
      'couplers': couplers.map((v) => v.toJson()).toList(),
      'status': status,
    };
  }
}

class Coupler {
  final String name;
  final double loss1;
  final double loss2;

  Coupler({required this.name, required this.loss1, required this.loss2});
}

final List<Coupler> asymmetricCouplers = [
  Coupler(name: "50/50", loss1: 3.2, loss2: 3.2),
  Coupler(name: "45/55", loss1: 3.7, loss2: 2.8),
  Coupler(name: "40/60", loss1: 4.2, loss2: 2.4),
  Coupler(name: "35/65", loss1: 4.8, loss2: 2.1),
  Coupler(name: "30/70", loss1: 5.4, loss2: 1.8),
  Coupler(name: "25/75", loss1: 6.2, loss2: 1.5),
  Coupler(name: "20/80", loss1: 7.7, loss2: 1.3),
  Coupler(name: "15/85", loss1: 8.4, loss2: 0.91),
  Coupler(name: "10/90", loss1: 10.0, loss2: 0.66),
  Coupler(name: "05/95", loss1: 13.0, loss2: 0.42),
];

final Map<String, Coupler> couplerLossMap = {
  for (var c in asymmetricCouplers) c.name: c,
};

class PlcSplitter {
  final String name;
  final double loss;

  PlcSplitter({required this.name, required this.loss});
}

final List<PlcSplitter> plcSplitters = [
  PlcSplitter(name: "1×4", loss: 6.5),
  PlcSplitter(name: "1×8", loss: 9.5),
  PlcSplitter(name: "1×16", loss: 12.5),
  PlcSplitter(name: "1×32", loss: 15.5),
  PlcSplitter(name: "1×64", loss: 18.5),
  PlcSplitter(name: "1×128", loss: 21.5),
];

class CouplerData {
  int? id;
  double inputPower;
  String couplerType;
  double lossPerKm;
  double distance1;
  double distance2;

  CouplerData({
    this.id,
    this.inputPower = 0,
    this.couplerType = "10/90",
    this.lossPerKm = 0.01,
    this.distance1 = 0,
    this.distance2 = 0,
  });

  CouplerData copy() {
    return CouplerData(
      id: id,
      inputPower: inputPower,
      couplerType: couplerType,
      lossPerKm: lossPerKm,
      distance1: distance1,
      distance2: distance2,
    );
  }

  double get outputPower1 {
    final loss = couplerLossMap[couplerType];
    if (loss == null) return inputPower;
    return inputPower - loss.loss1 - (distance1 * lossPerKm);
  }

  double get outputPower2 {
    final loss = couplerLossMap[couplerType];
    if (loss == null) return inputPower;
    return inputPower - loss.loss2 - (distance2 * lossPerKm);
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'coupler_ratio': couplerType,
      'tap_km': distance1,
      'tap_output_dbm': outputPower1,
      'throughput_km': distance2,
      'through_output_dbm': outputPower2,
    };
  }

  static CouplerData fromJson(Map<String, dynamic> json) {
    String rawType = json['coupler_ratio']?.toString() ?? "10/90";

    String normalized = rawType.replaceAll(':', '/');

    if (!couplerLossMap.containsKey(normalized)) {
      final parts = normalized.split('/');
      if (parts.length == 2) {
        final reversed = "${parts[1]}/${parts[0]}";
        if (couplerLossMap.containsKey(reversed)) {
          normalized = reversed;
        } else {
          normalized = "10/90";
        }
      } else {
        normalized = "10/90";
      }
    }

    return CouplerData(
      id: json['id'],
      couplerType: normalized,
      distance1: (json['tap_km'] as num?)?.toDouble() ?? 0.0,
      distance2: (json['throughput_km'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
