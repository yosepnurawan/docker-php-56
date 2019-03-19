# Docker PHP 5.6 Development

Docker Image untuk keperluan development project-project.
Image ini masih bersifat sederhana, dan akan dikembangkan sesuai kebutuhan development.

# Usage

1. Copy `docker-compose.yml`, `Dockerfile,`, `.env-sample` ke webroot project directory
2. Rename `.env-sample` menjadi `.env` kemudian tambahkan di `.gitignore` project
3. Sesuaikan `COMPOSE_PROJECT_NAME=nama_project` di `.env` 
4. Add `hostname_project` di `etc/hosts`
5. Sesuaikan `hostname_project` dengan `etc/hosts` di: 
   - `docker-compose.yml` pada bagian `environment: VIRTUAL_HOST=` 
   - `/conf/apache/000-default.conf` dan `/conf/host/hosts`
6. Buat service menggunakan command di bawah ini:
   ```
   # docker-compose up -d --build
   ```
7. Running project dengan docker-compose
   ```
   docker-compose up
   ```
8. Koneksi ke container apache
   ```
   # docker exec -it container_name bash
   ```
   setelah itu koneksi ke server database via SSH
   ```
   contain@er# ssh user@host -L 3307:localhost:3306
   ```
   atau menggunakan `docker exec` langsung
   ```
   # docker exec <containerID> ssh user@host -L 3307:localhost:3306
   ```

# Details

- PHP 5.6.37
- Web Server: Apache
- PHP Ext: intl, pdo, pdo_mysql, oci8, xdebug, gd
- Composer
- Git
- Memcached

# Todos

- [x] Tambah Composer
- [x] Tambah Git
- [x] Support memcached
- [x] Support OCI8
- [ ] Support autorun ssh tunnel ke server database beta

# Author

[Yosep Nurawan](mailto:yosepnurawan.official@gmail.com)

# Copyright

(c) 2018 - Yosep Nurawan
