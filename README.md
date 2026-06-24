# 🐳 Laravel CI Docker Image

![PHP Versions](https://img.shields.io/badge/PHP-8.2%20%7C%208.3%20%7C%208.4%20%7C%208.5-777BB4?logo=php&logoColor=white&style=flat-square)
![Node Version](https://img.shields.io/badge/Node-20-green?style=flat-square)

---

## 🚀 Overview

Optimized Docker image based on [shivammathur/node](https://hub.docker.com/r/shivammathur/node) for running Laravel tests via PestPHP with:

* ⚡ Fast startup (no [setup-php](https://setup-php.com) needed)
* 🧪 PestPHP-focused (Xdebug and PCOV disabled)
* 📦 Composer preinstalled
* 🟢 Node.js included (for Vite builds)
* 🧩 Additional PHP extensions preinstalled

Designed specifically for **GitHub Actions / CI environments**.

Built automatically for **PHP 8.2, 8.3, 8.4 and 8.5** and published to two registries:

* **GitHub Container Registry:** `ghcr.io/john-wink/laravel-ci:php-<version>`
* **Docker Hub:** `<dein-docker-hub-user>/laravel-ci:php-<version>`

The newest version (currently 8.5) is additionally tagged `:latest`.

---

## ✨ Tweaks:

* Additional PHP extensions:

  * `bcmath`
  * `gd`
  * `intl`
  * `exif`
  * `sqlite3`
  * `imagick`
* ImageMagick (for media libraries)
* Xdebug + PCOV disabled (for faster tests)

---

## 📦 Usage

### GitHub Actions

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/john-wink/laravel-ci:php-8.5
```

---

## ⚙️ How images are built

Images are built and pushed automatically by [`.github/workflows/build.yml`](.github/workflows/build.yml):

* On every push to `main` that touches the `Dockerfile` or the workflow
* Manually via **Actions → Run workflow** (`workflow_dispatch`)
* Weekly (Mondays), to pick up base-image security updates

To add or change a PHP version, edit the `matrix.php` list in the workflow (and `LATEST_PHP` if needed). The [`Dockerfile`](Dockerfile) is parameterized via `ARG PHP_VERSION`, so no other change is required.

---

## ⚠️ Notes

* ❌ Not intended for production use
* ✅ Optimized for CI pipelines

---

## 🧠 Why this image?

This image avoids:

* Slow setup caused by using [setup-php](https://setup-php.com)
* Reinstalling extensions every run
* Missing system dependencies

👉 Result: **faster and more reliable pipelines**

---

## 🔗 Repository

GitHub:
https://github.com/john-wink/laravel-ci

---

## 📄 License

This project is licensed under the MIT License and is based on the original
[laravel-ci-docker](https://github.com/x1bn/laravel-ci-docker) work.
