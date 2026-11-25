import express from "express";
import { tanaman } from "./src/data/tanaman.js";

const app = express();
const PORT = process.env.PORT ?? 3000;

app.use(express.json());

// Helper supaya format response selalu konsisten:
//   berhasil -> { data: ... }
//   gagal    -> { error: { pesan, kode } }
const kirimData = (res, data, status = 200) => res.status(status).json({ data });
const kirimError = (res, status, pesan, kode) =>
  res.status(status).json({ error: { pesan, kode } });

// GET / -> teks sambutan
app.get("/", (req, res) => {
  res.type("text/plain").send("Selamat datang di REST API Koleksi Tanaman Hias");
});

// GET /tanaman -> semua data
app.get("/tanaman", (req, res) => {
  kirimData(res, tanaman);
});

// GET /tanaman/:id -> satu data
// req.params.id selalu string, jadi harus diubah ke Number dulu sebelum
// dibandingkan dengan field id (angka) di data.
app.get("/tanaman/:id", (req, res) => {
  const id = Number(req.params.id);
  const satuTanaman = tanaman.find((item) => item.id === id);

  if (!satuTanaman) {
    return kirimError(
      res,
      404,
      `Tanaman dengan id ${req.params.id} tidak ditemukan`,
      "TANAMAN_TIDAK_DITEMUKAN",
    );
  }

  kirimData(res, satuTanaman);
});

// DELETE /tanaman/:id -> hapus satu data (data hanya di memori)
// Array hasil import tidak bisa di-assign ulang, jadi pakai findIndex + splice.
app.delete("/tanaman/:id", (req, res) => {
  const id = Number(req.params.id);
  const index = tanaman.findIndex((item) => item.id === id);

  if (index === -1) {
    return kirimError(
      res,
      404,
      `Tanaman dengan id ${req.params.id} tidak ditemukan`,
      "TANAMAN_TIDAK_DITEMUKAN",
    );
  }

  tanaman.splice(index, 1);
  res.status(204).end(); // 204 No Content, tanpa body
});

// Endpoint yang tidak dikenal tetap memakai format error yang sama
app.use((req, res) => {
  kirimError(
    res,
    404,
    `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`,
    "ENDPOINT_TIDAK_DITEMUKAN",
  );
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
