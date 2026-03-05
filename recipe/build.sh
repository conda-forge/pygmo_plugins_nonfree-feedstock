set -euo pipefail

# ---- libm.so sysroot workaround (see earlier message) ----
fix_one_sysroot() {
  local sysroot="$1"
  local libdir="$sysroot/usr/lib"
  [[ -d "$sysroot/usr" ]] || return 0
  [[ -e "$libdir/libm.so" ]] && return 0
  mkdir -p "$libdir"
  local cand=""
  for c in \
    "$sysroot/usr/lib64/libm.so.6" \
    "$sysroot/lib64/libm.so.6" \
    "$sysroot/usr/lib/x86_64-linux-gnu/libm.so.6" \
    "$sysroot/usr/lib/libm.so.6"
  do
    [[ -e "$c" ]] && { cand="$c"; break; }
  done
  [[ -n "$cand" ]] && ln -s "$cand" "$libdir/libm.so"
}

if [[ -n "${CONDA_BUILD_SYSROOT:-}" ]] && [[ -d "${CONDA_BUILD_SYSROOT:-}" ]]; then
  fix_one_sysroot "$CONDA_BUILD_SYSROOT"
fi
for r in "${BUILD_PREFIX:-}" "${PREFIX:-}"; do
  [[ -d "${r:-}" ]] || continue
  while IFS= read -r -d '' s; do
    fix_one_sysroot "$s"
  done < <(find "$r" -type d -name sysroot -print0 2>/dev/null || true)
done

# ---- C++ build ----
cmake -S . -B build_cpp ${CMAKE_ARGS:-} \
  -DPPNF_BUILD_CPP=ON \
  -DPPNF_BUILD_PYTHON=OFF \
  -DPPNF_BUILD_TESTS=OFF

cmake --build build_cpp --parallel "${CPU_COUNT:-1}"
cmake --install build_cpp

# ---- Python build ----
cmake -S . -B build_py ${CMAKE_ARGS:-} \
  -DPPNF_BUILD_CPP=OFF \
  -DPPNF_BUILD_PYTHON=ON \
  -DPPNF_BUILD_TESTS=OFF \
  -DPython3_EXECUTABLE="${PYTHON}"

cmake --build build_py --parallel "${CPU_COUNT:-1}"
cmake --install build_py
