double lerp(double from, double to, double extent, {double after = 0}) {
  // only start lerping when extent > after
  if (extent < after) return from;
  return from + (to - from) * (extent - after) / (1 - after);
}
