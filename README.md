# 🐳 Laravel CI Docker Image

[![Docker Pulls](https://img.shields.io/docker/pulls/x1bn/laravel-ci?style=flat-square)](https://hub.docker.com/r/x1bn/laravel-ci)
[![Docker Image Version](https://img.shields.io/docker/v/x1bn/laravel-ci?style=flat-square)](https://hub.docker.com/r/x1bn/laravel-ci)
[![Docker Image Size](https://img.shields.io/docker/image-size/x1bn/laravel-ci?style=flat-square)](https://hub.docker.com/r/x1bn/laravel-ci)
![PHP Version](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white&style=flat-square)
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
      image: x1bn/laravel-ci:php-8.4
```

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
https://github.com/xibn/laravel-ci-docker

Docker Hub:
https://hub.docker.com/r/x1bn/laravel-ci

---

## 📄 License

This project is licensed under the MIT License.
