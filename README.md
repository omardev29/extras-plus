# extras-plus

A custom [Scoop](https://scoop.sh) bucket for GUI and CLI applications not found in the official buckets.

## Usage

Add the bucket:

```powershell
scoop bucket add extras-plus https://github.com/omardev29/extras-plus
```

Search for apps:

```powershell
scoop search extras-plus
```

Install an app:

```powershell
scoop install extras-plus/<app-name>
```

## Available Apps

| App | Description |
|-----|-------------|
| [simpmusic](https://simpmusic.org) | Cross-platform YouTube Music client with SponsorBlock, synced lyrics, and more |

## Adding New Apps

To add a new app, create a JSON manifest in the `bucket/` directory following the [Scoop App Manifest format](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests).

## License

[MIT License](LICENSE)
