/// 雪花 ID 生成工具
///
/// 基于时间戳 + 序列号生成唯一字符串 ID，适用于同一进程内的文件标识。
/// 结构：41位时间戳（毫秒级） + 22位序列号，保证同一毫秒内最多生成 400万+ 个不重复 ID。
class SnowflakeId {
  static int _lastTimestamp = -1;
  static int _sequence = 0;

  /// 起始时间戳（2024-01-01 00:00:00 UTC）
  static const int _epoch = 1704067200000;

  /// 序列号位数
  static const int _sequenceBits = 22;

  /// 序列号最大值（2^22 - 1 = 4194303）
  static const int _maxSequence = (1 << _sequenceBits) - 1;

  /// 生成唯一 ID 字符串
  static String generate() {
    var timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;

    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) & _maxSequence;
      if (_sequence == 0) {
        // 当前毫秒内序列号溢出，等待下一毫秒
        while (timestamp <= _lastTimestamp) {
          timestamp = DateTime.now().millisecondsSinceEpoch - _epoch;
        }
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    // 组合为字符串：时间戳 + 序列号
    return '$timestamp${_sequence.toRadixString(36)}';
  }
}
