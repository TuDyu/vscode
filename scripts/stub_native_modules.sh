#!/bin/bash
# IC-dev: Stub native modules for development without MSVC C++ toolchain
# Run from project root: bash scripts/stub_native_modules.sh

set -e

stub_module() {
  local dir="node_modules/$1"
  local file="${2:-index.js}"
  local code="$3"
  local target="$dir/$file"
  
  if [ ! -f "$target" ]; then
    echo "SKIP: $target (not found)"
    return
  fi
  
  # Backup original
  if [ ! -f "$target.orig" ]; then
    cp "$target" "$target.orig"
  fi
  
  echo "$code" > "$target"
  echo "STUB: $target"
}

echo "=== Stubbing native modules for IC-dev dev mode ==="

stub_module "@vscode/policy-watcher" "index.js" '
module.exports = {
  createWatcher: function(productName, definitions, callback) {
    callback({});
    return { dispose: function() {} };
  }
};'

stub_module "@vscode/spdlog" "index.js" '
let flushLevel = 0;
module.exports.createAsyncRotatingLogger = function(name, filepath, filesize, filecount) {
  const prefix = "[" + name + "]";
  return {
    critical: function(m) { console.error(prefix, m); },
    error: function(m) { console.error(prefix, m); },
    warn: function(m) { console.warn(prefix, m); },
    info: function(m) { console.info(prefix, m); },
    debug: function(m) { console.debug(prefix, m); },
    trace: function(m) { console.debug(prefix, m); },
    setLevel: function(l) {},
    setPattern: function(p) {},
    clearPattern: function() {},
    flush: function() {},
    drop: function() {},
  };
};
module.exports.setFlushOn = function(level) { flushLevel = level; };
module.exports.setLevel = function(level) {};
module.exports.version = 99999;
module.exports.EOL = "\n";
module.exports.LOGLEVEL = { TRACE: 0, DEBUG: 1, INFO: 2, WARN: 3, ERROR: 4, CRITICAL: 5, OFF: 6 };
'

stub_module "@vscode/deviceid" "index.js" '
module.exports.getMachineId = function() {
  return Promise.resolve("icdev-machine-" + require("os").hostname());
};'

stub_module "@vscode/windows-registry" "dist/index.js" '
module.exports.GetStringRegKey = function(hive, key, value) { return null; };
'

stub_module "@vscode/windows-ca-certs" "index.js" '
module.exports = function() { return []; };
'

stub_module "@vscode/native-watchdog" "index.js" '
module.exports = { start: function() { return { dispose: function() {} }; } };
'

stub_module "@vscode/sqlite3" "index.js" '
module.exports = {
  verbose: function() {
    return { Database: function() { this.close = function(){}; this.run = function(){}; this.exec = function(){}; } };
  }
};
'

stub_module "@vscode/windows-process-tree" "index.js" '
module.exports = {
  getProcessTree: function(pid, cb) { cb(null, { pid: pid, name: "unknown", children: [] }); },
  getProcessList: function(pid, cb) { cb(null, [{ pid: pid, name: "unknown" }]); },
};
'

stub_module "@vscode/fs-copyfile" "index.js" '
const fs = require("fs");
module.exports = async function(src, dest) { await fs.promises.copyFile(src, dest); };
'

echo "=== Done. $(ls node_modules/@vscode/*/index.js.orig 2>/dev/null | wc -l) modules stubbed ==="
