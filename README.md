# cloudinary_client

A lightweight Flutter package for uploading and deleting assets on [Cloudinary](https://cloudinary.com). Supports signed and unsigned flows for images and raw files (PDFs, CSVs, etc.), works on mobile, desktop, and web.

---

## Features

- **Unsigned image upload** — upload directly from client-side code using an upload preset
- **Signed image upload** — server-grade upload with HMAC-SHA1 signature generated on-device
- **Raw file upload** — upload any file type (PDF, CSV, binary) via the `raw` resource type
- **Signed image deletion** — destroy an asset using the `/image/destroy` endpoint
- **Admin API deletion** — delete any asset type via the Cloudinary Admin API
- **Multi-region support** — choose between default, EU, and Asia-Pacific base URLs
- **Web + native** — handles `kIsWeb` differences automatically (byte-based vs path-based multipart)
- **Zero bloat** — thin Dio wrapper, no retry logic, no opinionated error types

---

## Cloudinary Console Setup

Before writing any code you need a Cloudinary account and the right credentials. Follow these steps at [https://console.cloudinary.com/](https://console.cloudinary.com/).

---

### 1. Create an account

Sign up for a free account at [https://console.cloudinary.com/](https://console.cloudinary.com/).

---

### 2. Get your Cloud Name

Once your account is created, look at the **left sidebar** — your cloud name is displayed there **above the "Welcome" label**. It looks something like `my-cloud-123`.

That value is your `cloudName`.

---

### 3. Get your API Key and API Secret

1. In the left sidebar open **Settings**.
2. Click the **API Keys** option.
3. Your **API Key** and **API Secret** are listed on that page.

Copy both. They are required for signed requests and Admin API calls.

> **Keep `apiSecret` out of your app in production.** Anyone who has it can manage your entire media library.

---

### 4. Create an Upload Preset

Upload presets tell Cloudinary how to handle incoming uploads. To create one:

1. In the left sidebar go to **Settings** then **Upload**.
2. Scroll down to **Upload presets** and click **Add upload preset**.
3. Set **Signing mode** to **Unsigned**.

> **Important:** Use **Unsigned** mode. Signed preset mode requires server-side signature verification and will not work with this client.

4. Enable the **Public** visibility option so the preset can be used for read, edit, and delete operations from the client.
5. Click **Save**. The **Preset name** shown at the top of the form is the value you pass as `uploadPreset`.

---

### 5. Set an Asset Folder (required for custom paths)

By default, every uploaded file lands directly at the root of your media library. If you want uploads to go into a specific subfolder you **must** set it manually inside the preset:

1. Open your preset in **Settings** then **Upload** then **Upload presets**.
2. Find the **Asset folder** field.
3. Enter the full folder path you want,this path either you create it under assets/folders in dashboard or API will create it dynamically after first request, for example:
   - `dev/images/logs`
   - `prod/images/logs`
4. Save the preset.

> This folder path must also be passed on each upload request. Use `buildFolderPath` to construct it, or pass any string you like. The value just needs to match what you set in the preset.

```dart
// buildFolderPath is a simple helper that joins parts into a path string.
// Edit the segments to match the Asset folder you configured in the preset.
// THIS is just an example for folder path you can create your own path
// for it if not set in the preset, API will create it dynamically after first request only if you add path on preset , else will uploaded on assets either you pass folder or not.
final folder = buildFolderPath(
  domainName: 'acme',    // your app or tenant name
  envName: 'prod',       // environment
  category: 'images',   // asset category
  folderName: 'logos',  // specific subfolder
);
// result: 'acme/prod/images/logos'

await cloudinary.uploadImageUnsigned(file: file, folder: folder);
```

> **Tip:** Create a separate preset per environment (`dev`, `prod`) each with its own Asset folder so uploads never mix between environments.

---

### 6. Choose your region

Cloudinary offers three API regions:

| Region           | `CloudinaryBaseUrlType` value |
| ---------------- | ----------------------------- |
| Global (default) | `CloudinaryBaseUrlType.def`   |
| Europe           | `CloudinaryBaseUrlType.eu`    |
| Asia-Pacific     | `CloudinaryBaseUrlType.ap`    |

Pick the one closest to your users or the one required by your data residency policy.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cloudinary_client:
    path: ../cloudinary_client # or your pub.dev version once published
```

Then run:

```bash
flutter pub get
```

---

## Usage

### Initialize the client

```dart
import 'package:cloudinary_client/cloudinary_client.dart';

final cloudinary = Cloudinary(
  cloudName: 'my-cloud-name',   // left sidebar, above Welcome
  apiKey: 'my-api-key',         // Settings > API Keys
  apiSecret: 'my-api-secret',   // Settings > API Keys — keep this secret
  uploadPreset: 'my-preset',    // Settings > Upload > Upload presets
  baseUrlType: CloudinaryBaseUrlType.def,
);
```

---

### Build a folder path (optional helper)

```dart
final folder = buildFolderPath(
  domainName: 'acme',
  envName: 'production',
  category: 'avatars',
  folderName: 'user-123',
);
// result: 'acme/production/avatars/user-123'
```

---

### Upload an image (unsigned)

No signature needed — just an upload preset.

```dart
import 'package:cross_file/cross_file.dart';

final file = XFile('/path/to/photo.jpg');

final result = await cloudinary.uploadImageUnsigned(
  file: file,
  folder: 'avatars/user-123',
);

print(result.secureUrl); // https://res.cloudinary.com/...
print(result.publicId);  // avatars/user-123/photo
```

---

### Upload an image (signed)

Generates an HMAC-SHA1 signature on-device before sending. Requires `apiKey` and `apiSecret`.

```dart
final result = await cloudinary.uploadImageWithSignature(
  file: file,
  folder: 'avatars/user-123',
  additionalParams: {
    'tags': 'profile,avatar',
  },
);

print(result.secureUrl);
```

---

### Upload a raw file (PDF, CSV, etc.)

Uses Cloudinary's `raw` resource type — no transcoding, any format accepted.

```dart
final pdf = XFile('/path/to/document.pdf');

final result = await cloudinary.uploadRawUnsigned(
  file: pdf,
  folder: 'documents/contracts',
);

print(result.secureUrl);
```

---

### Delete an image (signed)

Calls the `/image/destroy` endpoint with a signed request.

```dart
final deleted = await cloudinary.deleteImageSigned(
  publicId: 'avatars/user-123/photo',
);

print(deleted); // true
```

---

### Delete any asset via Admin API

Requires `apiKey` and `apiSecret`. Supports any resource type.

```dart
final deleted = await cloudinary.deleteAsset(
  publicId: 'documents/contracts/report',
  resourceType: CloudinaryResourceType.raw,
);

print(deleted); // true
```

---

## API Reference

### `Cloudinary`

| Parameter      | Type                    | Required         | Description                |
| -------------- | ----------------------- | ---------------- | -------------------------- |
| `cloudName`    | `String`                | Yes              | Your Cloudinary cloud name |
| `apiKey`       | `String?`               | For signed ops   | API key from Dashboard     |
| `apiSecret`    | `String?`               | For signed ops   | API secret from Dashboard  |
| `uploadPreset` | `String?`               | For unsigned ops | Upload preset name         |
| `baseUrlType`  | `CloudinaryBaseUrlType` | Yes              | Regional API endpoint      |

### `CloudinaryResponse`

| Field          | Type                      | Description                                   |
| -------------- | ------------------------- | --------------------------------------------- |
| `publicId`     | `String?`                 | Unique asset identifier in your media library |
| `assetId`      | `String?`                 | Internal Cloudinary asset ID                  |
| `secureUrl`    | `String?`                 | HTTPS URL of the uploaded asset               |
| `url`          | `String?`                 | HTTP URL of the uploaded asset                |
| `version`      | `String?`                 | Asset version ID                              |
| `type`         | `CloudinaryDeliveryType?` | Delivery type (upload, private, fetch...)     |
| `resourceType` | `CloudinaryResourceType?` | Resource type (image, raw, video...)          |
| `createdAt`    | `String?`                 | ISO 8601 creation timestamp                   |
| `displayName`  | `String?`                 | Display name of the asset                     |
| `signature`    | `String?`                 | Cloudinary-returned signature                 |

### `CloudinaryBaseUrlType`

| Value | Endpoint                              |
| ----- | ------------------------------------- |
| `def` | `https://api.cloudinary.com/v1_1/`    |
| `eu`  | `https://api-eu.cloudinary.com/v1_1/` |
| `ap`  | `https://api-ap.cloudinary.com/v1_1/` |

### `CloudinaryResourceType`

`image` · `raw` · `video` · `auto`

### `CloudinaryDeliveryType`

`upload` · `private` · `fetch` · `authenticated` · `auto`

---

## Security Notes

- **Never expose `apiSecret` in client-side code in production.** For signed uploads from a mobile app, consider generating the signature on your backend and passing it to the client.
- **Unsigned uploads** are safe for client-side use — they are restricted by the rules you configure in the upload preset.
- The Admin API (`deleteAsset`) embeds credentials in the URL — use it only in trusted environments.

---

## Dependencies

| Package                                             | Purpose                                   |
| --------------------------------------------------- | ----------------------------------------- |
| [`dio`](https://pub.dev/packages/dio)               | HTTP client for multipart uploads         |
| [`crypto`](https://pub.dev/packages/crypto)         | SHA1 HMAC signature generation            |
| [`cross_file`](https://pub.dev/packages/cross_file) | Cross-platform file abstraction (`XFile`) |
