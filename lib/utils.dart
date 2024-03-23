import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path;
import 'package:html/parser.dart' as parser;
import 'utils/cache_util.dart';

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

  /// 清除输入焦点
  static unFocus(BuildContext context) {
    var f = FocusScope.of(context);
    if (f != null && f.hasFocus)
      f.unfocus(disposition: UnfocusDisposition.scope);
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

  /// 开始一个页面，并等待结束
  static Future<Object> startPageWait(BuildContext context, Widget page,
      {bool replace}) async {
    if (page == null) return null;
    var rote = Platform.isIOS
        ? CupertinoPageRoute(builder: (context) => page)
        : MaterialPageRoute(builder: (_) => page);
    if (replace == true) return await Navigator.pushReplacement(context, rote);
    return await Navigator.push(context, rote);
  }

  static bool empty(String value) {
    return value == null || value.isEmpty;
  }

  static const join = path.join;

  static Future<String> pickFile(
    BuildContext context,
    List<String> allowedExtensions,
    String defaultFile, {
    String title,
  }) async {
    final iconColor = Theme.of(context).iconTheme.color;
    final x = await FilesystemPicker.openDialog(
      title: title ?? '选择文件',
      rootName: defaultFile,
      context: context,
      pickText: "选取文件",
      permissionText: "没有权限读取该文件夹",
      rootDirectory: Directory(Utils.dirname(defaultFile)),
      fsType: FilesystemType.file,
      folderIconColor: iconColor,
      allowedExtensions: allowedExtensions,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      requestPermission: CacheUtil.requestPermission,
      contextActions: <FilesystemPickerContextAction>[
        FilesystemPickerContextAction(
          action: (context, path) async {
            final TextEditingController controller = TextEditingController();
            var onPressed = () async {
              final fileName = controller.text.trim();
              try {
                final r =
                    await Directory(Utils.join(path.path, fileName)).create();
                if (r != null) {
                  Navigator.of(context).pop(true);
                  Future.delayed(Duration(seconds: 1), controller.dispose);
                } else {
                  toast("新建文件夹失败");
                }
              } catch (e) {
                toast("新建文件夹失败 $e");
              }
            };
            return showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                content: TextField(
                  controller: controller,
                  onSubmitted: (value) => onPressed(),
                ),
                title: Text("新建文件夹"),
                actions: [
                  TextButton(
                    child: Text("确定"),
                    onPressed: onPressed,
                  ),
                ],
              ),
            );
          },
          text: "新建文件夹",
          icon: Icon(Icons.create_new_folder_outlined, color: iconColor),
        ),
        FilesystemPickerContextAction(
          action: (context, path) async {
            final r = await FilePicker.platform.pickFiles(
              dialogTitle: title ?? '选择文件',
              initialDirectory: path.path,
              type: FileType.custom,
              allowedExtensions: allowedExtensions
                  .map((e) => e.startsWith(".") ? e.substring(1) : e)
                  .toList(),
            );
            if (r != null) {
              // c.complete(r.files.first.path);
              Navigator.of(context).pop(r.files.first.path);
              return false;
            } else {
              toast("未选择文件");
              return false;
            }
          },
          text: "系统管理器",
          icon: Icon(Icons.open_in_new, color: iconColor),
        ),
      ],
    );
    if (x == null) {
      toast("未选择文件");
    } else {
      toast("选择文件 " + x);
    }
    return x;
  }

  static String getHtmlString(String outerHtml) {
    /// 内部处理文字规则，图文混排
    /// 去掉script和style节点;img标签单独成段，块级元素换行 其他标签直接移除
    /// 块级元素 https://developer.mozilla.org/zh-CN/docs/Web/HTML/Block-level_elements
    /// <article> <dd> <div> <dl> <h1>, <h2>, <h3>, <h4>, <h5>, <h6> <hr> <p> <br>
    /// 网页编码转文本
    /*
         *北方酱保佑代码能用**********************************
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣤⠤⢤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⠖⠚⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠈⠉⠑⠲⠤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠲⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⢶⣒⡒⠒⠒⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⣠⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⢛⡖⠀⠀⠀⠀⠀⠀⣆⡤⠚⢩⠏⠀⣠⠞⠁⠹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⡀⠀⠀⠀⠈⠳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⣠⠞⠙⠋⠀⠀⢸⠖⠚⠁⠀⠀⠀⠈⠳⣄⡞⠳⡄⠀⠀⠀⠀⠀⢿⣍⠛⠲⣄⡀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠏⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀⠘⣧⠀⠀⠀⣙⣶⡀⢳⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⡞⢡⠇⠀⠀⠀⢐⡟⠁⠀⠀⠀⠀⠀⣀⣠⠴⠀⠀⠀⠀⠤⣄⠀⠀⠀⠀⠀⢹⡀⣆⠀⠀⠀⢿⡀⣠⣾⣿⣿⠁⠈⣇⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠳⡿⢸⡆⠀⠀⡏⠀⠀⠀⠀⠀⠙⠉⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⠓⠲⠀⠀⠀⠓⢾⠀⠀⠀⢸⣿⣿⣿⡟⠁⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢸⠃⠀⢸⠀⠀⠀⣀⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⢸⠀⠀⠀⠈⣿⠟⠋⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⣸⠀⢀⡞⡭⣤⡤⣌⠻⣆⠀⠀⠀⠀⠀⠀⠀⢠⠟⢩⣬⣭⣙⠳⣄⣽⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⢹⠀⡜⣼⣿⣿⣿⡿⡆⠙⠀⠀⠀⠀⠀⠀⠀⠋⣼⣾⣿⣿⣿⣧⠈⣿⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⢷⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⢸⠀⠃⣿⣿⣿⣯⣷⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⢻⣿⣺⠄⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢸⠀⠀⢻⡿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⠀⣿⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⡼⠉⠀⠀⠀⠙⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠽⠞⠁⠀⡟⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢀⡤⠤⣄⣠⡇⠀⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢀⣀⠠⣸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢸⣄⠀⠀⠈⠑⢻⣷⡞⣆⡀⢀⣠⣶⢖⣄⠀⠀⢀⣀⣤⣤⠀⠀⢀⣀⣤⡦⣄⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⢸⠀⣠⣶⡔⠋⠁⠀⠀⣠⣇⠀⠀⠀⠀
        ⠀⡠⠚⠉⠉⠉⠁⠀⠀⠀⢸⣿⣿⣴⣿⣿⣿⣿⣯⣮⣷⣮⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣧⣷⢦⢔⢋⣹⠀⠀⠀⠀⠀⣿⣐⣿⣿⡷⠀⠀⠀⠈⠉⠉⠑⠢⡀⠀
        ⠀⣇⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡟⢿⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣆⣀⡀⠀⠀⠀⠀⠀⢸⠀
        ⠀⠈⠑⠒⠒⠒⠚⣿⡿⣿⠟⠋⠃⠀⠻⣿⣟⡿⣿⣿⣿⣿⣿⣿⣿⣟⣿⢟⡟⣿⣿⣿⠿⢿⠋⣸⣻⠃⠀⠀⠀⠀⢸⡿⠛⠁⠛⠛⠿⢿⣿⠉⠛⠒⠛⢻⡁⠀
        ⠀⠀⠀⠀⠀⠀⠀⢸⡇⠙⣆⠀⠀⠀⠀⢸⡟⠉⠁⠀⠈⠛⠛⠉⠀⠀⠈⠑⠊⠊⠁⠀⠀⠀⠙⢡⠃⠀⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⣠⠃⠀⠁⠀⠀⠀⠈⢷⠀
        ⠀⠀⠀⠀⠀⠀⠀⠘⡇⠀⠘⣆⠀⠀⠀⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⡰⠃⠀⠀⠀⠀⠀⠀⠀⢸⡆
        ⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠘⣆⠀⠀⡾⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⡴⠁⡇⠀⠀⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⣸⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠓⠦⡄⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠛⠻⠻⠛⠁⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⢀⡼⠁⠀⢹⡀⠀⠚⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠃⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⢀⡠⠊⠀⠀⠀⠀⠳⠀⠀⠀⠀⠀⠀⠀⠀⠐⠊⠁⠀⠀⠀
         */
    final imgReg = RegExp(r"<img[^>]*>");
    final html = outerHtml
        .replaceAllMapped(imgReg, (match) => "\n" + match.group(0) + "\n")
        .replaceAll(
            RegExp(r"</?(?:div|p|br|hr|h\d|article|dd|dl)[^>]*>"), "\n");
    //  .replaceAll(RegExp(r"^\s*|</?(?!img)\w+[^>]*>"), "");
    return html.splitMapJoin(
      imgReg,
      onMatch: (match) => match.group(0) + "\n",
      onNonMatch: (noMatch) => noMatch.trim().isEmpty
          ? ""
          : parser.parse("$noMatch").documentElement.text + "\n",
    );
  }
}
