# 📱 HƯỚNG DẪN BUILD APK - ĐỌC TRUYỆN
## Dùng GitHub Actions (MIỄN PHÍ, không cần cài gì!)

---

## 🕐 Thời gian: ~10 phút | Độ khó: ⭐☆☆☆☆

---

## BƯỚC 1 — Tạo tài khoản GitHub (miễn phí)

1. Vào https://github.com
2. Nhấn **Sign up** (góc trên phải)
3. Điền email, mật khẩu, username
4. Xác nhận email

---

## BƯỚC 2 — Tạo Repository mới

1. Đăng nhập GitHub
2. Nhấn nút **"+"** góc trên phải → **"New repository"**
3. Điền:
   - Repository name: `doc-truyen`
   - Chọn **Public** hoặc **Private** đều được
   - ☑ Check vào **"Add a README file"**
4. Nhấn **"Create repository"**

---

## BƯỚC 3 — Upload Source Code

1. Trong trang repository vừa tạo, nhấn **"uploading an existing file"**
   (hoặc Add file → Upload files)
2. Giải nén file `DocTruyen_GitHub.zip` ra máy tính
3. **Kéo thả TOÀN BỘ** các file và thư mục vào trang GitHub
   ⚠️ Quan trọng: phải upload đúng cấu trúc thư mục!
4. Cuộn xuống nhấn **"Commit changes"**

---

## BƯỚC 4 — GitHub tự động build APK!

1. Nhấn vào tab **"Actions"** (trên đầu trang repo)
2. Bạn sẽ thấy workflow **"Build APK Đọc Truyện"** đang chạy
3. Chờ ~5-8 phút cho đến khi thấy ✅ màu xanh
   (Nếu thấy ❌ đỏ → liên hệ để mình fix)

---

## BƯỚC 5 — Tải APK về

1. Nhấn vào workflow run vừa chạy xong ✅
2. Cuộn xuống phần **"Artifacts"**
3. Nhấn **"DocTruyen-APK"** để tải về
4. Giải nén → có file **app-debug.apk**

---

## BƯỚC 6 — Cài lên điện thoại

1. Gửi file **app-debug.apk** qua **Zalo** sang điện thoại
2. Mở file trên điện thoại
3. Nếu hỏi "Cài từ nguồn không rõ" → nhấn **Cài đặt**
4. Xong! 🎉

---

## ❓ Gặp lỗi?

Chụp màn hình lỗi và gửi lại để được hỗ trợ.

---

## 📌 Lưu ý
- APK này là "debug build" — dùng bình thường được, chỉ không upload lên CH Play
- File APK lưu trên GitHub 90 ngày, sau đó cần build lại
- Lần sau muốn cập nhật: sửa code → push lên GitHub → tự động build lại
