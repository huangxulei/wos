import 'dart:io';

import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Utils {
  /// 提取文件名（不包含路径和扩展名）
  static String getFileName(final String file) {
    return path.basenameWithoutExtension(file);
  }

  static String dirname(final String file) {
    return path.dirname(file);
  }

  /// 提取文件名（包扩展名）
  static String getFileNameAndExt(final String file) {
    return path.basename(file);
  }

  /// 检测路径是否存在
  static bool existPath(final String _path) {
    return Directory(_path).existsSync();
  }

  static toast(msg,
      {Duration duration,
      ToastPosition position = ToastPosition.bottom,
      bool dismissOtherToast}) {
    if (msg == null) return;
    showToast('$msg',
        position: position,
        duration: duration,
        dismissOtherToast: dismissOtherToast);
  }
}
