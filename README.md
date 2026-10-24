# mantest scode

Workspace pengujian manual dari Dapur Kreatif Scode. Logo berupa hiu menggigit komputer.

## Paket siap unggah GitHub Pages

ZIP berisi index.html, config.js, assets/, supabase/, panduan ini, dan folder source/.
File pada ROOT paket sudah dibangun. Tidak perlu npm atau Vercel untuk menjalankannya.
Jangan unggah ZIP sebagai satu file. Ekstrak terlebih dahulu, lalu unggah ISINYA.

1. Buat repository GitHub, misalnya mantest-scode.
2. Jika akun GitHub Anda tidak mendukung Pages untuk private repository, gunakan repository public.
3. Upload semua file hasil ekstrak ke root repository. Pastikan index.html ada di root, bukan di dalam folder tambahan.
4. Buka Settings > Pages. Pilih Deploy from a branch, branch main, folder / (root), lalu Save.
5. Tunggu deployment berhasil. Buka URL yang ditampilkan GitHub Pages.
6. Aplikasi langsung masuk mode lokal jika config.js belum diisi.

## Dua mode penyimpanan

Mode lokal: untuk mencoba aplikasi sendiri. Data disimpan melalui localStorage pada browser yang digunakan, tanpa login. Akun lokal Admin bukan autentikasi dan tidak membatasi pengguna perangkat. Gunakan Unduh backup secara berkala. Anggota yang dibuat pada mode ini hanya menjadi data lokal dan tidak dapat login dari HP lain. Penghapusan data browser menghapus data lokal. Bukti besar dapat memenuhi kapasitas localStorage; gunakan tautan untuk bukti berukuran besar.

Mode bersama: frontend tetap di GitHub Pages. Supabase menyediakan login email/password, database dan penyimpanan bukti privat. Tidak ada server Node/PHP yang perlu dihosting sendiri. Mode bersama baru aktif setelah konfigurasi di bawah selesai. Data lokal tidak otomatis dipindahkan ke database bersama.

## Mengaktifkan akun masing-masing

1. Buat proyek Supabase terpisah khusus mantest scode.
2. Buka SQL Editor dan jalankan supabase/schema.sql sekali pada proyek baru. Script membuat tabel, RLS dan bucket bukti privat. Jangan menjalankannya di database produksi CERMAT.
3. Tambahkan Admin pertama melalui SQL berikut, mengganti email dan nama dengan milik Anda. Email harus huruf kecil dan sama dengan email yang dipakai untuk mendaftar:

   insert into public.mantest_members(email,name,role)
   values('emailanda@example.com','Nama Anda','Admin');

4. Isi config.js pada root repository:

   window.MANTEST_CONFIG = {
     supabaseUrl: 'https://PROJECT-ANDA.supabase.co',
     supabaseKey: 'PUBLISHABLE-ATAU-ANON-KEY-ANDA'
   };

5. Gunakan publishable/anon key, JANGAN service_role/secret key. Key frontend memang terlihat publik; aturan akses ditegakkan oleh RLS.
6. Pada pengaturan Authentication Supabase, aktifkan provider Email dan pendaftaran akun. Atur Site URL ke URL GitHub Pages lengkap dengan nama repository dan trailing slash. Tambahkan URL itu pada daftar Redirect URLs agar konfirmasi email dan pemulihan password kembali ke aplikasi.
7. Buka aplikasi, isi email dan password minimal 8 karakter, lalu klik Daftar akun. Jika konfirmasi email aktif, konfirmasi email terlebih dahulu, kemudian login.
8. Masuk sebagai Admin. Buka Anggota > Tambah anggota. Isi email, nama, dan peran Tester atau Developer.
9. Anggota membuka URL aplikasi dan mendaftar menggunakan email yang sama, lalu login. Menambahkan anggota tidak mengirim undangan email otomatis.
10. Uji dua akun pada browser terpisah. Akun yang belum tercatat sebagai anggota tidak memperoleh akses data.

Lupa password: isi email lalu klik Lupa password. Buka tautan pada email dan masukkan password baru di aplikasi. Pengiriman email bergantung pada konfigurasi dan batas layanan email Supabase Anda.

Peran berlaku pada seluruh workspace. Semua anggota yang terdaftar dapat membaca semua proyek. Versi ini belum memisahkan akses anggota per proyek. Admin mengelola master dan keputusan rilis; Tester menjalankan kasus dan menangani bug; Developer menangani bug tanpa mencatat run atau menutup bug. Pencabutan anggota sementara dilakukan dengan menghapus baris email pada tabel mantest_members melalui dashboard Supabase oleh pengelola.

## Data awal

217 test case dan 426 rencana run berasal dari EKSEKUSI_QA_CERMAT_AI_CFO(2).xlsx. Semua run awal belum diuji. Baris placeholder BUG-001 dan seterusnya tidak diimpor sebagai temuan. Hasil pengujian contoh dari pemeriksaan aplikasi tidak disertakan dalam paket.

Kode perangkat:
- D01: Desktop Chrome, Windows 10/11, target 1366 × 768.
- D02: Desktop Edge, Windows 10/11, target 1920 × 1080.
- D03: Desktop Firefox, OS tersedia, target 1366 × 768.
- M01: Redmi Note 11 Chrome, Android 13, target 393 × 873; perangkat fisik.
- M02: itel P65 Chrome, konfirmasi OS aktual, target 360 × 800; perangkat fisik.
- M03: iPhone Safari, konfirmasi iOS aktual, target 390 × 844 bila didukung.
- P58 dan P80: printer thermal fisik roll 58 mm dan 80 mm.

## Alur penggunaan

1. Pilih proyek dan siklus. Siklus bawaan S1 untuk System Testing. Admin dapat menambah proyek dan siklus.
2. Buka Test Case untuk membaca atau mengubah prasyarat, data, langkah, hasil yang diharapkan dan reset. Admin dapat menetapkan tester pada kasus. Tombol Tugas saya di Eksekusi memfilter penugasan tersebut.
3. Buka Eksekusi. Pilih run dan klik Jalankan.
4. Isi kondisi perangkat, build, hasil aktual, bukti dan status.
5. Gagal memerlukan Bug ID. Gunakan Buat bug dari hasil ini untuk membuat temuan, lalu simpan run. Lengkapi severity, prioritas dan penanggung jawab pada Laporan Bug.
6. Terblokir dan Tidak berlaku memerlukan alasan; untuk Tidak berlaku cantumkan pemberi persetujuan pada isian alasan.
7. Developer menandai bug Siap retest dan mencatat build perbaikan.
8. Tester melakukan Retest. Hasil lama tetap tersimpan; run baru menyimpan snapshot test case dan referensi ke run sebelumnya. Masukkan Bug ID yang sama agar retest terhubung.
9. Jika retest lulus, buka bug dan isi Run ID retest yang lulus, lalu pilih Ditutup. Mode cloud memeriksa tautan retest di database.
10. Buka Laporan QA untuk riwayat run, ekspor CSV, cetak/PDF dan keputusan reviewer. PDF dibuat melalui dialog cetak browser, pilih Save as PDF.
11. Tombol panah melingkar pada header menyegarkan data dari database. Pembaruan rekan tampil setelah refresh atau perpindahan/reload halaman; tidak menggunakan realtime subscription.

Dashboard memakai hasil terakhir untuk setiap pasangan kasus/perangkat pada siklus aktif. Laporan riwayat dan ekspor CSV tetap memuat seluruh percobaan. Completion = (Lulus + Gagal) / (total rencana run - Tidak berlaku). Terblokir belum selesai. Pass rate = Lulus / (Lulus + Gagal). Tidak ada eksekusi menampilkan Belum ada eksekusi.

Bukti: PNG, JPEG, WebP atau PDF maksimal 5 MB. Pada mode cloud bukti disimpan dalam bucket privat dan dibuka menggunakan URL sementara. Untuk video gunakan tautan yang dapat diakses reviewer. Hindari password, token, dan data pelanggan nyata pada bukti.

## Impor dan ekspor

Data Excel lampiran telah dimasukkan sebagai data awal. Impor tambahan pada versi ini menggunakan JSON melalui menu Test Case. Ekspor kasus JSON menghasilkan format yang bisa diimpor kembali; ID sama memperbarui master. Impor berjalan per kasus, sehingga kegagalan di tengah dapat menyisakan kasus yang sudah berhasil. Aplikasi belum menyediakan parser unggah Excel langsung atau impor satu batch atomik.

Ekspor hasil menggunakan CSV. Backup/pemulihan JSON tersedia khusus mode lokal. Mode cloud menggunakan fasilitas backup database dan bucket pada Supabase. Riwayat run tidak dapat diedit/ditimpa melalui aplikasi maupun RLS; buat retest baru untuk koreksi.

## Mengubah source

Folder source/ berisi React + TypeScript dan Vite. Node.js 22.13 atau lebih baru diperlukan untuk build.

cd source
npm install
npm run dev

Untuk membangun:
npm run build

Build menghasilkan source/build/. Salin isinya ke root repository. Salin juga source/config.js ke root dan source/assets/logo.png ke assets/logo.png karena kedua file dipakai melalui path relatif saat runtime. Pertahankan konfigurasi Supabase yang sudah Anda isi pada root. Seluruh path aset relatif, sehingga dapat dipakai pada GitHub project Pages.

File penting:
- config.js: konfigurasi Supabase runtime, tidak memerlukan build ulang.
- source/src/Workspace.tsx: tampilan dan alur interaksi.
- source/src/style.css: desain desktop dan responsive.
- source/src/backend.ts: autentikasi, akses data, bukti dan mode lokal.
- source/src/seed.json: 217 master kasus CERMAT.
- source/src/runplan.json: 426 rencana run dari Excel.
- supabase/schema.sql: struktur database dan kebijakan akses.
- assets/logo.png: logo hiu menggigit komputer.

## Verifikasi dan batas

Build produksi berhasil. Navigasi desktop, pembukaan formulir run, penyimpanan hasil lokal, pembaruan rekap dan menu mobile diperiksa melalui browser. Tampilan mobile ditinjau pada lebar 390 dan 320 piksel. Data cloud, pengiriman email, dan RLS belum diuji pada proyek Supabase nyata karena kredensial proyek belum dikonfigurasi. Lakukan smoke test dua akun sebelum penggunaan tim.

Ini implementasi awal yang fungsional. Fitur audit perubahan bug lengkap, arsip test case, akses per proyek, unggah Excel langsung dan notifikasi belum tersedia. Label rekomendasi QA dan keputusan rilis diisi reviewer, bukan persetujuan otomatis.
