// import 'nfc_data.dart';

// // abstract class NfcService {
// //   Future<bool> isAvailable();
// //   Future<void> startSession({
// //     required Function(NfcTag) onDiscovered,
// //     Set<NfcPollingOption>? pollingOptions,
// //   });
// //   Future<void> stopSession();
// // }

// abstract class NfcService {
//   Stream<NfcScanState> startScan();
//   void stopScan();
//   Future<Stream<NfcWriteState>> startWrite(List<NfcWriteData> dataList);
//   void confirmOverwrite();
//   Future<void> init();

//   /// Stream of tags detected while not in explicit scan/write mode
//   Stream<NfcData> get backgroundTagStream;
// }

// sealed class NfcScanState {}

// class NfcScanLoading extends NfcScanState {}

// class NfcScanSuccess extends NfcScanState {
//   final NfcData data;
//   NfcScanSuccess(this.data);
// }

// class NfcScanError extends NfcScanState {
//   final String message;
//   NfcScanError(this.message);
// }

// // --- Write States ---

// sealed class NfcWriteState {}

// class NfcWriteLoading extends NfcWriteState {}

// class NfcWriteSuccess extends NfcWriteState {}

// class NfcWriteOverwriteRequired extends NfcWriteState {}

// class NfcWriteError extends NfcWriteState {
//   final String message;
//   NfcWriteError(this.message);
// }

// // --- Write Data Types ---

// sealed class NfcWriteData {}

// class NfcWriteDataUri extends NfcWriteData {
//   final Uri uri;
//   NfcWriteDataUri(this.uri);
// }

// class NfcWriteDataText extends NfcWriteData {
//   final String text;
//   NfcWriteDataText(this.text);
// }

// class NfcWriteDataMime extends NfcWriteData {
//   final String type;
//   final List<int> data;
//   NfcWriteDataMime(this.type, this.data);
// }

// class NfcWriteDataExternal extends NfcWriteData {
//   final String domain;
//   final String type;
//   final List<int> data;
//   NfcWriteDataExternal(this.domain, this.type, this.data);
// }

// class NfcWriteDataCustom extends NfcWriteData {
//   final List<int> payload;
//   final int tnf;
//   final List<int> type;
//   final List<int> id;

//   NfcWriteDataCustom({
//     required this.payload,
//     required this.tnf,
//     required this.type,
//     required this.id,
//   });
// }
