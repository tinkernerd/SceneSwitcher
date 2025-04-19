# 🔢 SceneSwitcher Versioning Guide

SceneSwitcher follows [Semantic Versioning (SemVer)](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

---

## 🎯 Rules

| Level   | Meaning                                 | When to Bump                                 |
|---------|------------------------------------------|----------------------------------------------|
| MAJOR   | Breaking changes, big redesigns         | API or config behavior changes               |
| MINOR   | New features, backwards-compatible      | Additions to app functionality               |
| PATCH   | Bug fixes, small tweaks or improvements | Layout fixes, logic patches, UI polish       |

---

## 🧪 Current Versions

| Version | Status       | Notes                              |
|---------|--------------|------------------------------------|
| 0.1.0   | ✅ Released   | Local folder-based wallpapers only |
| 0.2.0   | 🚧 In Dev     | Adds Flickr album support          |

---

## 🛠 Tagging a Release

```bash
git tag v0.1.0
git push origin v0.1.0
```

Patch update:
```bash
git tag v0.1.1
git push origin v0.1.1
```

---

## 📝 Changelog Convention

Use this format in `CHANGELOG.md` or GitHub Releases:

```markdown
## 0.2.0 - Flickr Integration

### ✨ New
- Add support for Flickr albums
- Album preview and downloading

### 🐛 Fixes
- Reset layout spacing
- Default folder validation
```

---

## 🔮 Future Tags (Examples)

| Tag        | Description                         |
|------------|-------------------------------------|
| `v0.2.1`   | Patch to Flickr layout or bug        |
| `v0.3.0`   | Add GitHub theme sync                |
| `v1.0.0`   | Public release, stable and polished  |
| `v2.0.0`   | Breaking change (e.g. theme system)  |

---

## 📌 Notes

- Versions before `1.0.0` are considered **unstable**
- Breaking changes are OK in `0.x.x` but should be limited
- Once at `1.0.0`, SemVer must be strictly followed

