# -----------------------------------------------------------------------------
# Workaround: some dependencies' exported targets reference ${_CMAKE_SYSROOT}/usr/lib/libm.so
# In conda(-forge) sysroot, we usually have libm.so.6 but not the linker script libm.so.
# Make will then fail with "No rule to make target .../sysroot/usr/lib/libm.so".
# Create libm.so in every sysroot we can find (build + host + any nested bld/rattler sysroots).
# -----------------------------------------------------------------------------
set -euo pipefail

fix_one_sysroot() {
  local sysroot="$1"
  local libdir="$sysroot/usr/lib"

  # Only touch plausible sysroots
  [[ -d "$sysroot/usr" ]] || return 0

  # If already exists, leave it
  if [[ -e "$libdir/libm.so" ]]; then
    return 0
  fi

  mkdir -p "$libdir"

  # Prefer libm.so.6 if present anywhere typical in the sysroot
  local cand=""
  for c in \
    "$sysroot/usr/lib64/libm.so.6" \
    "$sysroot/lib64/libm.so.6" \
    "$sysroot/usr/lib/x86_64-linux-gnu/libm.so.6" \
    "$sysroot/usr/lib/libm.so.6"
  do
    if [[ -e "$c" ]]; then
      cand="$c"
      break
    fi
  done

  if [[ -n "$cand" ]]; then
    ln -s "$cand" "$libdir/libm.so"
    echo "Created: $libdir/libm.so -> $cand"
  else
    echo "WARNING: could not find libm.so.6 under $sysroot; skipping" >&2
  fi
}

# 1) Fix the current build sysroot (fast path)
if [[ -n "${CONDA_BUILD_SYSROOT:-}" ]] && [[ -d "${CONDA_BUILD_SYSROOT:-}" ]]; then
  fix_one_sysroot "$CONDA_BUILD_SYSROOT"
fi

# 2) Fix the sysroot under the current build prefix, and *any* nested sysroots
#    (covers the rattler-build/nlopt/... sysroot path seen in the failure)
roots=()
[[ -n "${BUILD_PREFIX:-}" ]] && roots+=("$BUILD_PREFIX")
[[ -n "${PREFIX:-}" ]] && roots+=("$PREFIX")

for r in "${roots[@]}"; do
  [[ -d "$r" ]] || continue
  while IFS= read -r -d '' s; do
    fix_one_sysroot "$s"
  done < <(find "$r" -type d -name sysroot -print0 2>/dev/null || true)
done
