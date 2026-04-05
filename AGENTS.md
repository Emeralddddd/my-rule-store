# Repository Instructions

## Surge 配置生成

- 生成并上传规则时，默认使用 `npx surgio generate --cache-snippet --skip-lint && npx surgio upload`。
- `--cache-snippet` 用于缓存远程片段，避免重复下载。
- `--skip-lint` 用于跳过 JS lint 检查，避免 `dns.js` 中的 Surge 全局变量触发无关报错。
- 任何对 Surge 配置模板、生成逻辑或托管配置产物的修改，在生成配置文件后都必须执行 `surge-cli --check` 校验。
- 默认校验命令为 `/Applications/Surge.app/Contents/Applications/surge-cli --check dist/Full.conf`。
- 在 `surge-cli` 校验通过前，不应上传托管配置，也不应将相关改动视为完成。
