# Release Process

This document explains **how we cut internal releases** (beta/rc/prod) and **how we publish them to the public SDK repos** with artifacts and changelogs.

---

## Overview

**Internal Release Process:**
1. **Cut Release** workflow versions, tags, and creates internal releases per SDK (Core/Camera)
2. Updates `Info.plist` and generates `Version.swift` with proper versioning
3. Creates GitHub releases with changelogs

**Public Release Process:**
1. **Public Release** workflow watches internal tags and automatically:
   - Builds XCFramework artifacts
   - Computes SwiftPM checksums  
   - Publishes to public repositories (beta/rc as prerelease)
   - Updates changelogs for production releases

**Key Points:**
- **Independent SDK versioning** - Each framework has separate release cycles
- **Multiple framework support** - Supports any number of frameworks (currently Camera and Core)
- **Automated workflows** - Triggered by PR labels or manual dispatch
- **Conventional commits** - Auto-versioning based on commit messages

---

## Repo Layout & Local Tooling

- The repository uses a layered, modular structure.
- Project generation & builds are driven by **XcodeGen** and a **Makefile**.
- Common local commands:
  - `make genbuild` → generate the Xcode project and build.
  - `make framework SCHEME=TruvideoSdk` → build device+sim and create an XCFramework for the scheme.

---

## Versioning Overview

We follow **SemVer** for the base version (e.g., `78.1.2`). Pre-release tags append a channel suffix:

- **Beta:** `78.1.2-BETA.N`
- **RC:** `78.1.2-RC.N`
- **Prod:** `78.1.2`

### Build Number Rules (per base version, per SDK)

- **BETA build number** = its `N` (e.g., `BETA.5` → `CFBundleVersion = 5`).
- **RC build number** is **monotonic across BETA+RC** for the same base:
  - `RC build = max(last BETA N, last RC N) + 1`
- **PROD build number** = **latest (max) pre-release N** for that base, or `1` if none exist.

This guarantees no collisions between BETA and RC builds and makes PROD reflect the latest pre-release lineage.

---

## Internal Workflow — "Cut Release"

**When it runs**
- On **merged PRs into `release/*`** branches (for beta/rc only if labeled correctly).
- Manually via **workflow_dispatch** (beta/rc/prod).

**How the cut type is chosen**
- **Manual (dispatch)**: choose `beta` / `rc` / `prod`.
- **Auto via labels on the PR**:
  - `cut-beta` → **beta**
  - `cut-rc` → **rc**
  - (`prod` is **manual only**)
- **Multiple labels**: If both `cut-beta` and `cut-rc` labels are present, the workflow creates both beta and RC releases.
- **Dry run**: Manual workflow includes a `dry_run` option to preview what would be tagged/released without actually creating tags or releases.

**How the SDK(s) are chosen**
Priority order: **Manual input** → **PR labels**.
- **Manual**: Choose `camera` / `core` / `all` (or any supported framework)
- **Labels**: 
  - `truvideoCameraSdk` → Camera SDK
  - `truvideoSdk` → Core SDK
  - Additional frameworks can be added (see [Adding New Frameworks](#adding-new-frameworks))

**Tag naming**
- Frameworks follow the pattern: `TruvideoSdk[FrameworkName]`

**What it does**
1. **Generates** the Xcode project via `make genbuild`.
2. **Determines base version** from the last **production** tag of the same prefix (pre-release tags are ignored for the base bump).
3. **Auto-bumps version** based on commit messages using conventional commits:
   - `BREAKING CHANGE` or `!:` → **major**
   - `feat:` → **minor** 
   - `fix:`, `perf:` → **patch**
   - Default → **patch**
4. Computes the next **BETA/RC/PROD** version + **build number** (rules above).
5. Updates **Info.plist** of the affected SDK paths:
   - `CFBundleShortVersionString` → base semver (e.g., `78.1.2`)
   - `CFBundleVersion` → numeric build (see rules)
   - `TRVReleaseChannel` → `BETA` / `RC` / `PROD`
6. Writes `Sources/<SDK>/Generated/Version.swift` with:
   - `SDKVersionNumber` → full version string (e.g., `78.1.2-RC.3`)
   - `SDKEnvironment` → `BETA` / `RC` / `PROD`
   - `SDKBuildNumber` → same number used for `CFBundleVersion`
7. Creates and pushes the **annotated tag**:
   - Core example: `TruvideoSdk-78.1.2-RC.3`
   - Camera example: `TruvideoSdkCamera-78.1.2-BETA.10`
8. Creates an **internal GitHub Release** (BETA/RC marked as *prerelease*).

> The project generation/build steps align with the existing developer workflow (`make genbuild`).

---

## Public Release — "Public Release"

**Trigger**
- On every **internal tag push** matching:
  - `TruvideoSdk-*`
  - `TruvideoSdkCamera-*`

**What it does**
1. **Parses the tag** to detect SDK (Core/Camera), channel (BETA/RC/PROD), and the base version.  
2. Runs `make genbuild`, builds **device** + **sim** frameworks for the correct **scheme**, then creates an **XCFramework** zip.  
3. Computes **SwiftPM checksum** for the zip using `swift package compute-checksum`.
4. Creates a **GitHub Release** in the **public** repo:
   - Camera: `Truvideo/truvideo-sdk-ios-camera`
   - Core: `Truvideo/truvideo-sdk-ios-core`
   - Attaches the zip; body includes checksum and a pointer to the internal origin tag.
   - **BETA/RC** are created as **prerelease**; **PROD** is not.
5. **PROD only:** updates **CHANGELOG.md** in the public repo:
   - Prepends a new entry: `## Version <X.Y.Z> – <YYYY-MM-DD>`
   - Includes only **changes for the affected component** (Core vs Camera).
   - **Sanitizes** commit subjects:
     - Removes ticket IDs (`[ABC-123]`), PR refs (`(#123)`), and bracketed links (`[...]`)
     - Groups by Features/Fixes/etc. (Conventional Commit style)
     - Only includes commits that affect the specific SDK path

---

## Labels Reference

This section defines all labels used in the release process and their specific purposes.

### Release Control Labels

These labels control **when** and **what type** of release to create:

| Label | Purpose | Usage | Trigger |
|-------|---------|-------|---------|
| `cut-beta` | Create a beta release on PR merge | Add to PR when ready for beta testing | Automatic on merge to `release/*` branch |
| `cut-rc` | Create a release candidate on PR merge | Add to PR when ready for release candidate | Automatic on merge to `release/*` branch |
| `prod` | Manual production release only | Used in manual workflow dispatch | Manual only (never automatic) |

**Notes:**
- Multiple release types can be combined (e.g., both `cut-beta` and `cut-rc` will create both types)
- Production releases (`prod`) are **never automatic** and require manual workflow dispatch
- These labels only work on PRs targeting `release/*` branches

### SDK Scope Labels

These labels identify **which SDK(s)** are affected by the changes:

| Label | Affected SDK | Triggered By Changes In | Public Repository |
|-------|--------------|------------------------|-------------------|
| `truvideoSdk` | Core SDK | `Libraries/External/Extended/App/` | `Truvideo/truvideo-sdk-ios-core` |
| `truvideoCameraSdk` | Camera SDK | `Libraries/Plugins/Camera/` | `Truvideo/truvideo-sdk-ios-camera` |

**Notes:**
- Labels are **automatically applied** based on file changes using the labeler workflow
- Multiple SDK labels can be present on the same PR
- Each SDK gets its own independent release cycle

### Internal Component Labels

These labels are for **internal routing and review** purposes:

| Label | Purpose | Triggered By Changes In |
|-------|---------|------------------------|
| `internal:core` | Internal core components | `Libraries/Internal/Core/` |
| `internal:extended` | Internal extended components | `Libraries/Internal/Extended/` |
| `internal:external-core` | External core components | `Libraries/External/Core/` |
| `repo` | Repository-wide changes | `.github/`, `Scripts/`, `Docs/`, `README.md`, `LICENSE` |

**Notes:**
- These labels don't trigger releases but help with PR routing and review
- Useful for understanding the scope of changes
- Can be combined with SDK scope labels

### Label Combinations Examples

Here are common label combinations and what they trigger:

| PR Labels | Result | Description |
|-----------|--------|-------------|
| `truvideoSdk` + `cut-beta` | Core SDK beta release | Beta release for Core SDK only |
| `truvideoCameraSdk` + `cut-rc` | Camera SDK RC release | Release candidate for Camera SDK only |
| `truvideoSdk` + `truvideoCameraSdk` + `cut-beta` | Both SDKs beta releases | Beta releases for both Core and Camera |
| `truvideoSdk` + `cut-beta` + `cut-rc` | Core SDK beta + RC releases | Both beta and RC releases for Core SDK |
| `truvideoSdk` + `truvideoCameraSdk` + `cut-beta` + `cut-rc` | All combinations | Beta and RC releases for both SDKs (4 total releases) |
| `internal:core` + `truvideoSdk` | No release | Internal changes don't trigger releases, but SDK label shows Core is affected |

### Adding New Framework Labels

When adding a new framework (e.g., `TruvideoSdkAnalytics`):

1. **Add to labeler.yml**:
   ```yaml
   truvideoAnalyticsSdk:
     - changed-files:
         - any-glob-to-any-file: |
             Libraries/Plugins/Analytics/**
   ```

2. **Add to workflows**:
   - Cut Release: Add `LBL_ANALYTICS: truvideoAnalyticsSdk`
   - Public Release: Add framework to frameworks array

3. **Usage**:
   - `truvideoAnalyticsSdk` + `cut-beta` → Analytics SDK beta release

---

## Labels Cheat-Sheet (Quick Reference)

**Release Control Labels**
- `cut-beta` → allow beta cut on merge  
- `cut-rc` → allow rc cut on merge  
- `prod` → manual only (not automatic via labels)

**SDK Scope Labels** (auto-applied based on file changes)
- `truvideoSdk` → Core SDK affected (changes in `Libraries/External/Extended/App/`)
- `truvideoCameraSdk` → Camera SDK affected (changes in `Libraries/Plugins/Camera/`)
- Additional framework labels can be added (see [Adding New Frameworks](#adding-new-frameworks))

**Internal Component Labels** (for routing/review)
- `internal:core` → changes in `Libraries/Internal/Core/`
- `internal:extended` → changes in `Libraries/Internal/Extended/`
- `internal:external-core` → changes in `Libraries/External/Core/`
- `repo` → changes in `.github/`, `Scripts/`, `Docs/`, `README.md`, `LICENSE`

> Labels are automatically applied based on file changes using the GitHub Actions labeler workflow.

---

## Automatic Labeling

The **Auto-label PRs** workflow automatically applies labels to pull requests based on the files that have been changed:

- **Triggers**: When PRs are opened, edited, synchronized, reopened, or marked as ready for review
- **Uses**: The `.github/labeler.yml` configuration to determine which labels to apply
- **Sync**: Ensures labels stay in sync with file changes throughout the PR lifecycle

This ensures that PRs are properly categorized and the release workflow can automatically determine which SDKs are affected.

---

## Tag Naming Examples

**Camera**
- BETA: `TruvideoSdkCamera-78.1.2-BETA.325`
- RC: `TruvideoSdkCamera-78.1.2-RC.326`
- PROD: `TruvideoSdkCamera-78.1.2`

**Core**
- BETA: `TruvideoSdk-78.1.2-BETA.239`
- RC: `TruvideoSdk-78.1.2-RC.240`
- PROD: `TruvideoSdk-78.1.2`

**Additional Frameworks** (example)
- BETA: `TruvideoSdkAnalytics-78.1.2-BETA.15`
- RC: `TruvideoSdkAnalytics-78.1.2-RC.16`
- PROD: `TruvideoSdkAnalytics-78.1.2`

*RC build number increments beyond the last BETA for the same base.*

---

## What Goes Into Info.plist & Version.swift

- `CFBundleShortVersionString`: `78.1.2` (base semver)  
- `CFBundleVersion`: build number (BETA/RC monotonically increasing for the base; PROD equals latest pre-release N or `1`)  
- `TRVReleaseChannel`: `BETA` / `RC` / `PROD`

**Example `Version.swift`** (Current workflow output)
```swift
// Generated by CI – do not edit.
  public static let SDKVersionNumber = "78.1.2-RC.3"
  public static let SDKEnvironment = "RC"
  public static let SDKBuildNumber = "3"
```

> **Note**: The current workflow output is missing the `public struct SDKVersion {` declaration and closing `}`. This should be fixed in the workflow.

---

## Workflow Files

- **Internal Release**: `.github/workflows/cut-release.yml`
- **Public Release**: `.github/workflows/public-release.yml`
- **Auto-labeling**: `.github/workflows/auto-label-pr.yml`
- **Label Configuration**: `.github/labeler.yml`

---

## Adding New Frameworks

To add support for a new framework (e.g., `TruvideoSdkAnalytics`), you need to update several files:

### 1. **Cut Release Workflow** (`.github/workflows/cut-release.yml`)

**Add environment variables:**
```yaml
env:
  TAGPFX_ANALYTICS: 'TruvideoSdkAnalytics'
  LBL_ANALYTICS: truvideoAnalyticsSdk
```

**Update framework selection logic:**
```bash
# In the allow logic, add:
grep -qx "${{ env.LBL_ANALYTICS }}" <<< "$labels" && allow="${allow} analytics" || true
```

**Update cut_for function:**
```bash
case "$key" in
  "analytics")
    prefix="${{ env.TAGPFX_ANALYTICS }}"
    path="Libraries/Plugins/Analytics/"
    vdir="Sources/TruvideoSdkAnalytics/Generated"
    ;;
esac
```

### 2. **Public Release Workflow** (`.github/workflows/public-release.yml`)

**Add environment variables:**
```yaml
env:
  PATH_ANALYTICS: 'Libraries/Plugins/Analytics/'
  EXT_REPO_ANALYTICS: Truvideo/truvideo-sdk-ios-analytics
```

**Update framework configuration:**
```bash
frameworks=(
  "TruvideoSdkCamera:camera:${{ env.PATH_CAM }}:${{ env.EXT_REPO_CAM }}:TruvideoSdkCamera"
  "TruvideoSdk:core:${{ env.PATH_CORE }}:${{ env.EXT_REPO_CORE }}:TruvideoSdk"
  "TruvideoSdkAnalytics:analytics:${{ env.PATH_ANALYTICS }}:${{ env.EXT_REPO_ANALYTICS }}:TruvideoSdkAnalytics"
)
```

### 3. **Label Configuration** (`.github/labeler.yml`)

**Add label rules:**
```yaml
truvideoAnalyticsSdk:
  - changed-files:
      - any-glob-to-any-file: |
          Libraries/Plugins/Analytics/**
```

### 4. **Documentation**

Update this documentation to include the new framework in examples and labels cheat-sheet.

---

## Troubleshooting

### Common Issues

1. **Release not triggered**: Check that PR has correct labels (`cut-beta` or `cut-rc`)
2. **Wrong SDK affected**: Verify PR has correct SDK labels (`truvideoSdk`, `truvideoCameraSdk`, etc.)
3. **Version conflicts**: Ensure no duplicate `cut-beta` and `cut-rc` labels on same PR
4. **Build failures**: Check that `make genbuild` works locally first
5. **Unknown framework**: If adding new frameworks, ensure all configuration is updated

### Manual Release Steps

If automated workflows fail, you can manually trigger releases:

1. Go to **Actions** → **Cut Release**
2. Click **Run workflow**
3. Select release type (`beta` / `rc` / `prod`)
4. Select affected SDKs (`camera` / `core` / `all`)
5. Enable dry run first to preview changes
