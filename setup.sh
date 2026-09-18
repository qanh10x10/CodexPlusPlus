#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== Codex++ setup (macOS/Linux) ==="

if ! command -v pnpm >/dev/null 2>&1; then
  if command -v corepack >/dev/null 2>&1; then
    echo "pnpm chua co. Bat corepack..."
    corepack enable
    corepack prepare pnpm@latest --activate
  fi
fi
if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm khong co tren PATH. Cai: npm i -g pnpm  hoac  corepack enable"
  echo "Can Node.js 22: https://nodejs.org/"
  exit 1
fi

pnpm_cur="$(pnpm --version 2>/dev/null | tr -d '[:space:]')"
pnpm_latest=""
if command -v npm >/dev/null 2>&1; then
  pnpm_latest="$(npm view pnpm version 2>/dev/null | tr -d '[:space:]' || true)"
fi
if [[ -n "$pnpm_cur" && -n "$pnpm_latest" ]]; then
  echo "pnpm ${pnpm_cur}  latest ${pnpm_latest}"
  export PNPM_CUR="$pnpm_cur"
  export PNPM_LATEST="$pnpm_latest"
  if node -e "const c=process.env.PNPM_CUR.split('.').map(Number);const l=process.env.PNPM_LATEST.split('.').map(Number);for(let i=0;i<Math.max(c.length,l.length);i++){const a=c[i]||0,b=l[i]||0;if(b>a)process.exit(0);if(b<a)process.exit(1);}process.exit(1);"; then
    echo "Updating pnpm ${pnpm_cur} -> ${pnpm_latest}"
    pnpm self-update \
      || { command -v corepack >/dev/null 2>&1 && corepack prepare pnpm@latest --activate; } \
      || npm i -g pnpm@latest
    echo "pnpm now $(pnpm --version)"
  fi
fi

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

echo "[1/5] pnpm install"
(
  cd apps/codex-plus-manager
  if [ ! -f pnpm-workspace.yaml ]; then
    printf "allowBuilds:\n  esbuild: true\n" > pnpm-workspace.yaml
  fi
  pnpm approve-builds esbuild >/dev/null 2>&1 || true
  pnpm install || { pnpm approve-builds --all >/dev/null 2>&1 || true; pnpm install; }
  echo "[2/5] tsc check"
  pnpm run check
  echo "[3/5] pnpm test"
  export NODE_OPTIONS="--experimental-strip-types"
  pnpm test || echo "WARN: pnpm test fail. Tiep tuc build."
  unset NODE_OPTIONS
  echo "[4/5] vite:build"
  pnpm run vite:build
)

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo khong co tren PATH."
  echo "Cai Rust: https://rustup.rs/"
  echo "macOS can Xcode CLT: xcode-select --install"
  echo "Mo lai terminal sau khi cai, roi chay ./setup.sh lai."
  exit 1
fi

echo "[5/5] cargo test + cargo build --release"
cargo test --workspace || echo "WARN: cargo test fail. Tiep tuc build."
cargo build --release || {
  echo
  echo "===================================================================="
  echo "[LOI] cargo build --release that bai!"
  echo "Neu gap loi quyen han hoac symlink, vui long kiem tra lai quyen truy cap."
  echo "===================================================================="
  exit 1
}

echo
echo "Xong."
echo "Launcher: target/release/codex-plus-plus"
echo "Manager:  target/release/codex-plus-plus-manager"
echo "Chay: ./start.sh"
