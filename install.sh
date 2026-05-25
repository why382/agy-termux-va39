#!/data/data/com.termux/files/usr/bin/bash
set -e
pkg install -y curl python proot ca-certificates file proot-distro >/dev/null
mkdir -p "$HOME/.local/bin"
if [ ! -x "$HOME/.local/bin/agy" ]; then curl -fsSL https://antigravity.google/cli/install.sh | bash || true; fi
curl -fsSL https://raw.githubusercontent.com/why382/agy-termux-va39/main/patch_agy_va39.py -o "$HOME/patch_agy_va39.py"
chmod +x "$HOME/patch_agy_va39.py"
python3 "$HOME/patch_agy_va39.py" "$HOME/.local/bin/agy"
L=$(find "$PREFIX" -name ld-linux-aarch64.so.1 2>/dev/null | head -n1)
if [ -z "$L" ]; then proot-distro install ubuntu; L=$(find "$PREFIX" -name ld-linux-aarch64.so.1 2>/dev/null | head -n1); fi
G=$(dirname "$L")
ROOT=$(echo "$L" | sed "s|/usr/lib.*||")
A="$ROOT/usr/lib/aarch64-linux-gnu"
mkdir -p "$HOME/.local/lib/agy-glibc"
ln -sfn "$A/libc.so.6" "$HOME/.local/lib/agy-glibc/libc.so"
ln -sfn "$A/libc.so.6" "$HOME/.local/lib/agy-glibc/libc.so.6"
cp "$HOME/.local/bin/agy-va39" "$HOME/.local/bin/agy-va39.bak" 2>/dev/null || true
cat > "$HOME/.local/bin/agy-va39" <<WRAPEOF
#!/data/data/com.termux/files/usr/bin/sh
ROOT='$ROOT'
G='$G'
A='$A'
S=/data/data/com.termux/files/home/.local/lib/agy-glibc
unset LD_PRELOAD
unset LD_LIBRARY_PATH
export GODEBUG=netdns=go
export SSL_CERT_FILE=/data/data/com.termux/files/usr/etc/tls/cert.pem
exec /data/data/com.termux/files/usr/bin/proot \
  -b /data/data/com.termux/files/usr/etc/resolv.conf:/etc/resolv.conf \
  "$G/ld-linux-aarch64.so.1" --library-path "$S:$G:$A" \
  /data/data/com.termux/files/home/.local/bin/agy.va39 "$@"
WRAPEOF
chmod +x "$HOME/.local/bin/agy-va39"
grep -q "agy-va39" ~/.bashrc 2>/dev/null || cat >> ~/.bashrc <<BASHRC

export PATH="$HOME/.local/bin:$PATH"

agy() {
  hash -r
  agy-va39 "$@"
}

a() {
  hash -r
  agy-va39 "$@"
}
BASHRC
echo "Done. Run: source ~/.bashrc && agy --version"
