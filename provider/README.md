# Provider

## 自定义 Provider

- [文档](https://surgio.royli.dev/guide/custom-provider.html)

## 更新

你可以在 [这里](https://github.com/geekdada/create-surgio-store/tree/master/template/provider) 查看该目录的更新版本。

## 环境变量

Provider 中的订阅地址属于敏感信息，不再写死在仓库里。请将以下环境变量写入 `.env`（仅本地使用，已被 `.gitignore` 忽略），或在 GitHub/GitLab 的仓库 Secrets 中配置，并在 CI/CD 工作流中通过 `env:` 注入。

| Provider | ENV 变量 |
| --- | --- |
| kuromis | `PROVIDER_KUROMIS_URL` |
| ytoo | `PROVIDER_YTOO_URL` |
| flowerCloud | `PROVIDER_FLOWER_CLOUD_URL` |

GitHub Actions 示例：

```yaml
env:
  PROVIDER_KUROMIS_URL: ${{ secrets.PROVIDER_KUROMIS_URL }}
  PROVIDER_YTOO_URL: ${{ secrets.PROVIDER_YTOO_URL }}
  PROVIDER_FLOWER_CLOUD_URL: ${{ secrets.PROVIDER_FLOWER_CLOUD_URL }}
```

GitLab CI/CD 在项目 Settings → CI/CD → Variables 中添加同名变量即可。
