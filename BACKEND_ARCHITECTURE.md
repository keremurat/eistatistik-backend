# eistatistik Backend Mimari ve Uygulama Planı

> Durum: Planlama dokümanı  
> Son güncelleme: 3 Kasım 2026  
> Backend: Rails 8.1 API + PostgreSQL  
> Frontend: Next.js (`eistatistik-frontend`)  
> Kapsam: Bu doküman mimariyi ve uygulama sırasını tanımlar. Henüz uygulama kodu yazılması anlamına gelmez.

## 1. Amaç

Bu dokümanın amacı, mevcut Next.js frontend ekranlarının ihtiyaçlarına göre Rails backend mimarisini tanımlamak; iş alanlarını, veri modelini, API sınırlarını, güvenlik gereksinimlerini ve tahmini uygulama süresini belirlemektir.

Temel hedef uçtan uca şu iş akışını güvenilir şekilde çalıştırmaktır:

1. Müşteri hesap açar veya giriş yapar.
2. Hizmet seçerek analiz talebi oluşturur.
3. Çalışma bilgilerini ve dosyalarını gönderir.
4. Yönetim siparişi değerlendirir ve fiyat verir.
5. Müşteri havale veya Akbank Sanal POS ile ödeme yapar.
6. Sipariş analizöre/asistana atanır.
7. Mesaj, görev ve randevu süreçleri yürütülür.
8. Analiz sonuçları ve teslimat dosyaları müşteriye sunulur.
9. Tüm kritik işlemler yetki ve audit kayıtlarıyla izlenir.

## 2. Mevcut durum

### 2.1 Rails projesi

`eistatistik-backend` şu anda temiz bir Rails API iskeletidir:

- Rails 8.1.3
- PostgreSQL
- API-only yapı
- Puma
- Active Storage ve `image_processing`
- Solid Queue
- Solid Cache
- Solid Cable
- Kamal ve Docker temeli

Henüz iş alanına ait model, migration, controller veya endpoint bulunmamaktadır. Bu nedenle veri modeli frontend akışlarına göre temiz şekilde kurulabilir.

### 2.2 Frontend durumu

Frontend büyük ölçüde tamamlanmış bir prototiptir. Veriler çoğunlukla:

- Sabit TypeScript dizileri
- `localStorage`
- Demo hesaplar
- İstemci tarafı durumları

üzerinden çalışmaktadır.

Backend’e taşınması gereken ana roller:

- Müşteri
- Analizör
- Asistan
- Editör
- Admin

Backend’e taşınması gereken ana iş alanları:

- Kimlik doğrulama ve kullanıcı yönetimi
- Rol ve yetki yönetimi
- Hizmet kataloğu
- Sipariş ve analiz süreci
- Fiyatlandırma, ödeme ve muhasebe
- Dosya ve teslimat yönetimi
- Mesajlaşma ve bildirim
- Görev, pano ve randevu
- Eğitim sistemi
- İçerik/CMS
- Dashboard ve raporlama
- Audit ve güvenlik

## 3. Mimari yaklaşım

### 3.1 Modüler monolit

İlk ve orta ölçek için mikroservis yerine **Rails modüler monolit** kullanılacaktır.

Nedenleri:

- İş alanları birbirine bağlıdır.
- Sipariş, ödeme, görev, mesaj ve teslimat aynı transaction sınırlarına ihtiyaç duyar.
- Küçük/orta ekip için geliştirme ve operasyon daha hızlıdır.
- Dağıtık transaction, servis keşfi, ayrı deployment ve mesaj broker maliyeti oluşmaz.
- İleride ihtiyaç oluşursa ödeme, bildirim veya raporlama modülleri ayrıştırılabilir.

### 3.2 Genel sistem görünümü

```text
Next.js Web                 Mobil Uygulama
     │                            │
     └──────── HTTPS / JSON ──────┘
                    │
                    ▼
             Rails API /api/v1
                    │
       ┌────────────┼─────────────┐
       │            │             │
  PostgreSQL   Active Storage  Solid Queue
       │       S3 uyumlu alan      │
       │                           ├── SMTP
       │                           ├── Akbank
       │                           ├── Paraşüt
       │                           └── Bildirim işleri
       │
  Solid Cache / Solid Cable
```

### 3.3 Rails uygulama katmanları

```text
app/
├── controllers/
│   └── api/v1/
├── models/
├── policies/
├── serializers/
├── services/
│   ├── authentication/
│   ├── orders/
│   ├── payments/
│   ├── education/
│   └── notifications/
├── queries/
├── jobs/
├── mailers/
├── channels/
└── validators/
```

Katmanların sorumlulukları:

- `controllers`: HTTP isteğini alır, parametreleri doğrular ve cevap döndürür.
- `models`: İlişkiler, veri bütünlüğü ve temel doğrulamalar.
- `policies`: Rol, permission ve kayıt bazlı erişim kontrolü.
- `services`: Sipariş oluşturma, ödeme onaylama ve teslimat gibi iş akışları.
- `queries`: Liste filtreleri, dashboard ve rapor sorguları.
- `serializers`: Frontend’e sunulan kararlı JSON sözleşmeleri.
- `jobs`: E-posta, toplu mesaj, dosya işleme, export ve periyodik işler.
- `channels`: Gerçek zamanlı mesaj ve bildirim.

Controller’larda ödeme, sipariş geçişi veya yetki gibi iş kuralları tutulmayacaktır.

## 4. API standardı

Tüm uygulama endpoint’leri versiyonlanacaktır:

```text
/api/v1/...
```

### 4.1 Başarılı liste cevabı

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "perPage": 25,
    "total": 248
  }
}
```

### 4.2 Hata cevabı

```json
{
  "error": {
    "code": "invalid_transition",
    "message": "Ödeme alınmadan sipariş başlatılamaz.",
    "fields": {}
  }
}
```

### 4.3 API kuralları

- Frontend ile uyum için JSON alanları `camelCase` sunulabilir.
- Veritabanı ve Ruby tarafı `snake_case` kalır.
- Tarihler ISO 8601 formatında ve timezone bilgisiyle döner.
- Uygulama timezone’u `Europe/Istanbul` olarak tanımlanır.
- Liste endpoint’lerinde pagination zorunludur.
- Arama ve filtreler query parametreleriyle yönetilir.
- Mutasyon endpoint’lerinde açık hata kodları kullanılır.
- Ödeme ve webhook işlemlerinde idempotency uygulanır.
- Geriye dönük uyumsuz değişiklikte yeni API versiyonu açılır.

## 5. Kimlik doğrulama ve kullanıcı yönetimi

### 5.1 Web oturumu

Web uygulamasında tercih edilen yöntem sunucu tarafından yönetilen güvenli session cookie’dir:

- `HttpOnly`
- `Secure`
- Uygun `SameSite` politikası
- CSRF koruması
- Kısa/orta ömürlü session
- Sunucu tarafında session iptali

Kimlik doğrulama bilgisinin `localStorage` içinde tutulması production için kullanılmayacaktır.

### 5.2 Mobil oturum

Mobil repo ayrı geliştirilecektir. Rails API aynı domain servislerini sunar. Mobil için ileride:

- Kısa ömürlü access token
- Döndürülebilir refresh token
- Cihaz/session kaydı
- Token iptali

eklenebilir. Web ve mobilin istemci oturum yöntemi farklı olabilir; iş kuralları aynı Rails servislerini kullanır.

### 5.3 Tablolar

```text
users
user_profiles
roles
permissions
role_permissions
user_roles
sessions
password_reset_tokens
audit_logs
```

`users` için temel alanlar:

```text
id
email
password_digest
status
last_sign_in_at
failed_attempts
locked_at
created_at
updated_at
```

`user_profiles` için temel alanlar:

```text
user_id
full_name
phone
account_type
university
faculty
department
city
district
address
```

### 5.4 Roller ve permission yapısı

Roller:

- `customer`
- `analyzer`
- `assistant`
- `editor`
- `admin`

Frontend’de tanımlanan permission anahtarları backend’de veri olarak tutulacaktır. Örnekler:

```text
siparis.listele
siparis.goruntule
siparis.olustur
siparis.analizor
siparis.teslim
egitim.guncelle
kullanici.rapor
diger.rol
```

Frontend yalnızca menü görünürlüğünü yönetir. Nihai yetki kontrolü her API endpoint’inde Rails policy katmanında yapılır.

### 5.5 Kimlik API’si

```text
POST   /api/v1/auth/register
POST   /api/v1/auth/login
DELETE /api/v1/auth/logout
GET    /api/v1/auth/me
POST   /api/v1/auth/password/forgot
POST   /api/v1/auth/password/reset
GET    /api/v1/me/profile
PATCH  /api/v1/me/profile
GET    /api/v1/admin/users
GET    /api/v1/admin/users/:id
PATCH  /api/v1/admin/users/:id
```

## 6. Hizmet kataloğu ve analiz talebi

### 6.1 Modeller

```text
service_types
service_form_definitions
service_form_fields
order_form_answers
```

Hizmet türleri:

- İstatistiksel veri analizi
- Power analizi
- Geçerlilik ve güvenilirlik
- Online danışmanlık/mentörlük
- Graphical Abstract
- Proforma

### 6.2 Yeni analiz talebi akışı

Frontend adımları:

1. Hizmet seçimi
2. Çalışma bilgileri
3. Dosyalar
4. Teslimat
5. Onay

Form ilk adımdan itibaren backend’de `draft` olarak tutulur. Kullanıcı sayfadan ayrıldığında ilerleme kaybolmaz.

```text
GET    /api/v1/service-types
GET    /api/v1/service-types/:slug
POST   /api/v1/orders
PATCH  /api/v1/orders/:id
POST   /api/v1/orders/:id/submit
```

Sık raporlanacak alanlar normal kolonlarda, hizmete özgü ve değişken cevaplar kontrollü `jsonb` veya cevap tablosunda tutulabilir. Kritik finans ve durum bilgileri `jsonb` içine konulmayacaktır.

## 7. Sipariş ve analiz operasyonu

### 7.1 Modeller

```text
orders
order_items
order_assignments
order_status_events
order_relationships
order_notes
order_files
order_deliveries
order_settings
quotes
```

### 7.2 `orders` temel alanları

```text
id
code
customer_id
service_type_id
title
description
work_type
status
priority
assigned_analyst_id
assigned_assistant_id
quoted_at
paid_at
started_at
due_at
completed_at
delivered_at
cancelled_at
lock_version
created_at
updated_at
```

`lock_version`, aynı sipariş üzerinde eşzamanlı düzenlemelerde veri ezilmesini engellemek için kullanılacaktır.

### 7.3 Sipariş durumları

```text
draft
submitted
reviewing
quoted
awaiting_payment
paid
in_progress
analysis_completed
ready_for_delivery
delivered
revision_requested
cancelled
archived
```

Durum alanı genel `PATCH` ile serbestçe değiştirilmeyecektir. İşlem odaklı endpoint’ler kullanılacaktır:

```text
POST /api/v1/orders/:id/submit
POST /api/v1/orders/:id/quote
POST /api/v1/orders/:id/confirm-payment
POST /api/v1/orders/:id/start
POST /api/v1/orders/:id/complete
POST /api/v1/orders/:id/deliver
POST /api/v1/orders/:id/request-revision
POST /api/v1/orders/:id/cancel
POST /api/v1/orders/:id/archive
```

Her durum geçişi:

1. Kayıt bazlı yetkiyi kontrol eder.
2. Geçişin mevcut durumda geçerli olduğunu doğrular.
3. Transaction içinde siparişi günceller.
4. `order_status_events` kaydı oluşturur.
5. Audit log yazar.
6. Gerekli bildirim işlerini kuyruğa ekler.

### 7.4 Rol bazlı görünürlük

- Müşteri yalnızca kendi siparişlerini görür.
- Analizör yalnızca kendisine atanmış veya açıkça izin verilmiş siparişleri görür.
- Asistan görevli olduğu siparişleri görür.
- Editör permission seti kapsamındaki siparişleri görür.
- Admin tüm kayıtlara erişebilir.

Bu filtre controller’da unutulabilecek şekilde değil, policy scope içinde merkezi olarak uygulanacaktır.

## 8. Dosya ve teslimat yönetimi

Active Storage kullanılacaktır. Üretim dosyaları Rails sunucusunun yerel diskinde tutulmayacaktır.

Önerilen depolama:

- S3 uyumlu private bucket
- Direct upload
- Kısa süreli signed URL
- Yetki kontrolünden sonra indirme

Dosya kategorileri:

```text
source_data
questionnaire
supporting_document
payment_receipt
analysis_output
report
delivery
invoice
education_material
certificate
```

Güvenlik gereksinimleri:

- Dosya boyutu limiti
- Uzantı ve MIME doğrulaması
- Zararlı dosya taraması
- Dosya adı güvenli hale getirme
- Private erişim
- İndirme audit kaydı
- KVKK saklama ve silme politikası
- Yedekleme

API:

```text
POST   /api/v1/direct-uploads
GET    /api/v1/orders/:order_id/files
POST   /api/v1/orders/:order_id/files
DELETE /api/v1/orders/:order_id/files/:id
POST   /api/v1/orders/:order_id/deliveries
```

## 9. Fiyatlandırma, ödeme ve muhasebe

### 9.1 Modeller

```text
quotes
payments
payment_attempts
credit_card_payments
bank_transfers
refunds
coupons
coupon_redemptions
ledger_entries
proforma_invoices
subscription_plans
subscriptions
```

Para alanları `float` olmayacaktır. Tercih edilen saklama biçimi:

```text
amount_cents bigint
currency string # TRY
```

### 9.2 Akbank Sanal POS kararı

Ödeme sağlayıcısı bellidir: **Akbank Sanal POS**.

Referans repo:

```text
/home/panda/eistatistik/archived-akbank-test-backend
```

Referans projede doğrulanan akış:

- `3D_PAY_HOSTING`
- Satış işlem kodu `3000`
- TL para birimi kodu `949`
- Backend’de HMAC-SHA512 form hash’i üretme
- Frontend/mobil istemciye Akbank `form_data` döndürme
- İstemcinin Akbank gateway’e hidden form/WebView ile POST etmesi
- Akbank’ın backend success/fail callback endpoint’lerine dönmesi
- Callback hash doğrulaması
- Sonucun veritabanına kaydedilmesi
- Web sonuç ekranı veya mobil deep-link’e yönlendirme

Referans kod **doğrudan production’a kopyalanmayacaktır**. Test uygulamasındaki kavramlar korunarak aşağıdaki production gereksinimleri eklenecektir:

1. `Order` oluşturma ile ödeme başlatma birbirinden ayrılacak.
2. Sipariş tutarı istemciden güvenilir kaynak olarak alınmayacak; aktif quote backend’den okunacak.
3. Her ödeme denemesi için benzersiz, tahmin edilemez provider order ID üretilecek.
4. Callback tekrarları idempotent işlenecek.
5. Callback replay koruması uygulanacak.
6. Hash karşılaştırmasında sabit zamanlı güvenli karşılaştırma kullanılacak.
7. Callback parametreleri ham olarak audit amacıyla saklanabilecek; hassas veriler filtrelenecek.
8. Başarısız ödeme siparişi doğrudan iptal etmeyecek; yalnızca ödeme denemesi başarısız olacaktır.
9. Sipariş ancak doğrulanmış başarılı ödeme sonrasında `paid` durumuna geçirilecek.
10. Aynı payment için çift onay engellenecek.
11. Web ve mobil dönüş adresleri tek ENV değeriyle değiştirilmek yerine izinli istemci/return target üzerinden yönetilecek.
12. Callback endpoint’leri rate limit, loglama ve alarm ile izlenecek.
13. Test ve production Akbank credential’ları kesin şekilde ayrılacak.
14. Kart numarası, CVV veya son kullanma tarihi Rails veritabanına/loglarına alınmayacak.

Önerilen API:

```text
POST /api/v1/orders/:order_id/payments/akbank
GET  /api/v1/payments/:id
POST /api/v1/payment-callbacks/akbank/success
POST /api/v1/payment-callbacks/akbank/fail
POST /api/v1/orders/:order_id/bank-transfers
POST /api/v1/payments/:id/refund
```

Ödeme başlatma cevabı:

```json
{
  "data": {
    "paymentId": "...",
    "gatewayUrl": "https://...",
    "formData": {}
  }
}
```

Akbank entegrasyonu servis katmanında soyutlanacaktır:

```text
Payments::Akbank::CreateForm
Payments::Akbank::VerifyCallback
Payments::Akbank::HandleSuccess
Payments::Akbank::HandleFailure
```

Bu sayede controller içinde hash üretme veya ödeme durum kuralları tutulmaz.

### 9.3 Havale/EFT

```text
POST /api/v1/orders/:order_id/bank-transfers
POST /api/v1/admin/bank-transfers/:id/approve
POST /api/v1/admin/bank-transfers/:id/reject
```

Dekont Active Storage ile private dosya olarak saklanacaktır. Onay ve ret işlemleri audit kaydına yazılır.

### 9.4 Kuponlar

Kuponlar için:

- Başlangıç/bitiş zamanı
- Kullanım limiti
- Kullanıcı başına limit
- Belirli sipariş/hizmet kısıtı
- Sabit tutar/yüzde ayrımı
- Minimum tutar
- Redemption kaydı

backend tarafından doğrulanacaktır. İndirim hesabı frontend’e bırakılamaz.

### 9.5 Paraşüt e-fatura kararı

E-fatura sağlayıcısı: **Paraşüt**.

Entegrasyon bilgileri ve referans kod kullanıcı tarafından ilgili faza gelindiğinde sağlanacaktır. Şimdilik adapter sınırı planlanacaktır:

```text
Invoicing::Gateway
Invoicing::ParasutGateway
Invoicing::IssueInvoice
Invoicing::CancelInvoice
Invoicing::SyncInvoiceStatus
```

Paraşüt bilgileri gelmeden varsayıma dayalı entegrasyon kodu yazılmayacaktır.

## 10. Mesajlaşma ve bildirim

### 10.1 Modeller

```text
conversations
conversation_participants
messages
message_templates
notifications
notification_preferences
bulk_messages
bulk_message_recipients
```

### 10.2 API

```text
GET  /api/v1/orders/:order_id/messages
POST /api/v1/orders/:order_id/messages
GET  /api/v1/message-templates
GET  /api/v1/notifications
POST /api/v1/notifications/:id/read
POST /api/v1/admin/bulk-messages
```

Yeni mesaj ve bildirimler gerektiğinde Solid Cable ile gerçek zamanlı iletilebilir. İlk sürümde polling ile başlanıp WebSocket daha sonra etkinleştirilebilir.

### 10.3 E-posta kararı

E-posta servisi **SMTP** olacaktır.

Action Mailer SMTP üzerinden çalışacaktır. Şifre ve bağlantı bilgileri Rails credentials veya deployment secret’larında saklanacaktır.

E-posta gönderimleri HTTP request içinde yapılmayacak, Solid Queue üzerinden `deliver_later` ile gönderilecektir.

Gönderilecek temel e-postalar:

- E-posta doğrulama
- Şifre sıfırlama
- Sipariş alındı
- Fiyat teklifi hazır
- Ödeme başarılı/başarısız
- Analizör atandı
- Yeni mesaj
- Randevu oluşturuldu/değişti
- Teslimat hazır
- Eğitim kaydı
- Sertifika hazır

SMTP sağlayıcısı/host bilgileri uygulama fazında netleştirilecektir.

## 11. Görev, pano, takvim ve randevu

### 11.1 Modeller

```text
boards
board_columns
tasks
task_assignments
task_labels
task_labelings
task_comments
appointments
appointment_participants
```

`tasks` temel alanları:

```text
board_id
order_id
title
description
status
priority
position
due_at
completed_at
created_by_id
```

`appointments` temel alanları:

```text
order_id
customer_id
assignee_id
title
description
starts_at
ends_at
status
meeting_url
external_calendar_id
```

API:

```text
GET    /api/v1/tasks
POST   /api/v1/tasks
PATCH  /api/v1/tasks/:id
POST   /api/v1/tasks/:id/move
POST   /api/v1/tasks/:id/archive
GET    /api/v1/appointments
POST   /api/v1/appointments
PATCH  /api/v1/appointments/:id
POST   /api/v1/appointments/:id/cancel
```

Google Calendar/Meet entegrasyonu ilk sürüm için zorunlu değildir. İlk aşamada toplantı URL’si manuel tutulabilir.

## 12. Eğitim sistemi

Eğitim ürünleri, eğitim dönemleri ve kullanıcı kayıtları birbirinden ayrılacaktır.

### 12.1 Modeller

```text
courses
course_modules
lessons
course_module_memberships
course_runs
course_run_modules
enrollments
lesson_progresses
education_requests
certificates
mentorship_settings
mentorship_sessions
```

Örnek ayrım:

```text
Course
  Temel Düzey Veri Analizi

CourseRun
  Nisan 2026 grubu
  starts_at
  ends_at
  quota
  price
  delivery_mode

Enrollment
  user_id
  course_run_id
  access_starts_at
  access_ends_at
  payment_status
```

API:

```text
GET  /api/v1/courses
GET  /api/v1/courses/:slug
GET  /api/v1/me/enrollments
POST /api/v1/course-runs/:id/enrollments
POST /api/v1/lessons/:id/progress
GET  /api/v1/me/certificates
```

Video ve eğitim dosyalarına erişim aktif enrollment kontrolünden sonra verilecektir. Doğrudan herkese açık kalıcı dosya URL’leri kullanılmayacaktır.

## 13. İçerik ve CMS

Yönetilebilir içerikler:

- Hizmetler
- Landing/anasayfa ayarları
- Duyurular
- Bültenler
- Bülten içerikleri
- Blog yazıları
- Analiz şablonları
- Rehber adımları
- SSS
- Referanslar ve yorumlar

Modeller:

```text
services
announcements
newsletters
newsletter_items
articles
analysis_templates
guide_steps
faqs
testimonials
site_settings
```

Ortak yayın alanları:

```text
status: draft/scheduled/published/archived
published_at
created_by_id
updated_by_id
```

Her şeyi tek bir genel `contents` tablosuna koymak yerine davranışı farklı içerikler ayrı modellerde tutulacaktır.

## 14. Favoriler

Frontend’de `localStorage` kullanan favoriler kullanıcı hesabına bağlanacaktır:

```text
favorites
  user_id
  favoritable_type
  favoritable_id
```

Bu yapı sipariş, kullanıcı veya desteklenen diğer yönetim kayıtlarının favorilenmesine izin verir.

## 15. Dashboard ve raporlama

İlk aşamada ayrı dashboard veri tabanı veya mikroservisi kurulmayacaktır.

```text
Analytics::OrderSummaryQuery
Analytics::RevenueSeriesQuery
Analytics::AnalystPerformanceQuery
Analytics::DeliveryPerformanceQuery
```

kullanılarak PostgreSQL aggregate sorguları ve Solid Cache ile başlanacaktır.

Veri büyüdüğünde:

- Günlük özet tabloları
- Materialized view
- Asenkron rapor üretimi

değerlendirilebilir.

## 16. Audit, KVKK ve güvenlik

### 16.1 Audit log

```text
audit_logs
  actor_id
  action
  auditable_type
  auditable_id
  changes_json
  ip_address
  user_agent
  request_id
  created_at
```

Audit kaydı gereken işlemler:

- Kullanıcı ve rol değişiklikleri
- Sipariş durum değişiklikleri
- Fiyat değişiklikleri
- Analizör/asistan atamaları
- Ödeme onayı, ret ve iade
- Dosya görüntüleme ve indirme
- Teslimat
- İptal ve arşivleme
- Toplu mesaj
- Eğitim erişim değişikliği

### 16.2 Güvenlik gereksinimleri

- CORS için açık wildcard yerine allowlist
- Rate limiting
- Login deneme sınırı ve hesap kilidi
- Hassas parameter filtering
- Güvenli secret yönetimi
- Yetki testleri
- SQL ve dosya erişim denetimleri
- Düzenli PostgreSQL yedeği
- Point-in-time recovery
- Hata izleme ve alarm
- Health check
- KVKK veri saklama/silme süreci
- Production ve test ortamlarının ayrılması

## 17. Solid Queue iş planı

Önerilen kuyruklar:

```text
critical
payments
mailers
notifications
files
exports
maintenance
```

Kuyruğa taşınacak işler:

- SMTP e-posta gönderimleri
- Bildirim dağıtımı
- Dosya tarama ve metadata çıkarma
- Rapor/export üretimi
- Paraşüt senkronizasyonu
- Süresi yaklaşan sipariş ve randevu hatırlatmaları
- Eğitim erişim süresi kontrolleri
- Eski kayıt temizleme

Ödeme callback’i gibi kritik doğrulama işlemleri request sırasında transaction içinde yapılır; takip e-postası ve bildirimler job olarak çalışır.

## 18. Test stratejisi

Mevcut Minitest altyapısı korunabilir.

Test katmanları:

- Model validation testleri
- Policy ve permission testleri
- Service object testleri
- API request testleri
- Job testleri
- Mailer testleri
- Akbank callback/hash testleri
- Duplicate callback/idempotency testleri
- Sipariş durum geçiş testleri
- Dosya erişim yetki testleri
- Paraşüt adapter contract testleri

En kritik güvenlik matrisi her rolün hangi kaydı ve işlemi görebildiğini kanıtlayan policy testleridir.

## 19. Deployment ve ortamlar

Ortamlar:

```text
development
test
staging
production
```

Staging ortamı Akbank test callback’leri, SMTP testleri ve frontend kabul testleri için zorunlu kabul edilmelidir.

Production bileşenleri:

- Rails web process
- Solid Queue worker/dispatcher
- PostgreSQL primary
- Cache/queue/cable veritabanları veya başlangıçta kontrollü ortak PostgreSQL altyapısı
- S3 uyumlu private storage
- HTTPS reverse proxy/load balancer
- Merkezi log ve hata izleme
- Otomatik yedek

## 20. Eski sistemden veri aktarımı

Eski sistem kodları ve veri yapısı daha sonra kullanıcı tarafından sağlanacaktır.

Bu nedenle şu anda migration kodu yazılmayacaktır. Yeni veri modelinde dış sistem izlenebilirliği için gerekirse aşağıdaki alanlar ayrılabilir:

```text
legacy_source
legacy_id
imported_at
```

Eski sistem geldiğinde ayrı çalışma yapılacaktır:

1. Kaynak şema ve veri kalitesi analizi
2. Alan eşleme dokümanı
3. Temizleme/normalizasyon kuralları
4. Tekrarlanabilir import scriptleri
5. Dry-run raporu
6. Mutabakat kontrolleri
7. Cutover planı
8. Geri dönüş planı

## 21. Mobil uygulama

Mobil uygulama ayrı repoda geliştirilmekte ve kullanıcı tarafından ayrıca sürdürülecektir.

Backend açısından yapılacaklar:

- Web ile aynı `/api/v1` iş kaynaklarını sunmak
- Mobil token/session desteğini planlamak
- Akbank ödeme dönüşü için izinli deep-link/app-link desteği
- API response’larını istemciden bağımsız tutmak
- Mobil versiyon uyumluluğu için API versioning uygulamak

Backend mimarisi mobil UI uygulamasını kapsamına almaz; yalnızca mobilin ihtiyaç duyduğu API sözleşmesini kapsar.

## 22. Uygulama fazları

### Faz 0 — Kararlar, sözleşme ve hazırlık

Amaç: Kodlama öncesi kritik teknik ve ürün kararlarını netleştirmek.

#### Netleşen kararlar

| Konu | Karar | Durum |
|---|---|---|
| Backend | Rails 8.1 API | Netleşti |
| Veritabanı | PostgreSQL | Netleşti |
| Mimari | Modüler monolit | Öneri kabul aşamasında |
| Ödeme | Akbank Sanal POS, `3D_PAY_HOSTING` | Referans repo mevcut |
| E-posta | SMTP | Netleşti |
| E-fatura | Paraşüt | Referans/credential daha sonra verilecek |
| Eski veri aktarımı | Eski sistem geldikten sonra | Bekliyor |
| Mobil | Ayrı repo, aynı API | Mevcut ve ayrı ilerleyecek |

#### Açık kararlar

- Production dosya depolama sağlayıcısı
- SMTP host/port/gönderici domain bilgileri
- Video barındırma ve korumalı erişim yöntemi
- WhatsApp/toplu mesaj sağlayıcısı gerekip gerekmediği
- Paraşüt entegrasyon kapsamı ve referans kod
- Akbank production credential ve callback domainleri
- Web ve API production domainleri
- KVKK veri saklama süreleri
- Eski sistem aktarım kapsamı

#### Faz 0 çıktıları

- Veri modeli ERD
- OpenAPI sözleşmesi
- Permission matrisi
- Sipariş durum geçiş diyagramı
- Akbank production akış diyagramı
- Dosya erişim politikası
- Deployment topolojisi
- Test ve kabul kriterleri

### Faz 1 — Kimlik, kullanıcı ve yetki

- Register/login/logout
- Şifre sıfırlama
- Profil
- Session/token altyapısı
- Rol ve permission
- Kullanıcı yönetimi
- Audit log temeli

### Faz 2 — İlk uçtan uca sipariş

- Hizmetleri API’den alma
- Analiz talebi taslağı
- Sipariş oluşturma
- Dosya yükleme
- Admin sipariş listesi/detayı
- Fiyat teklifi
- Müşteri sipariş detayı

Bu faz sonunda sistem ilk kez gerçek bir analiz talebini backend’de uçtan uca saklayabilir.

### Faz 3 — Ödeme ve operasyon

- Akbank Sanal POS
- Havale/dekont
- Kupon
- Analizör/asistan atama
- Sipariş durum akışı
- Mesajlaşma
- Bildirimler
- Görevler
- Teslimat

### Faz 4 — Randevu ve eğitim

- Takvim/randevu
- Kurs/modül/ders
- Eğitim dönemi
- Enrollment/satın alma
- Ders ilerlemesi
- Sertifika
- Mentörlük

### Faz 5 — CMS, fatura ve raporlama

- Duyuru
- Bülten
- Blog
- Landing ayarları
- Analiz şablonları
- Paraşüt entegrasyonu
- Dashboard
- Arşiv
- Finans raporları
- Toplu mesaj

### Faz 6 — Veri aktarımı ve canlıya hazırlık

- Eski sistem veri analizi ve import
- Yetki güvenlik kontrolleri
- Yük testi
- Backup/restore testi
- Monitoring
- KVKK süreçleri
- Kullanıcı kabul testleri
- Production cutover

## 23. Tahmini süre

Süreler ürün kararlarının zamanında verilmesi ve harici servis erişimlerinin hazır olması varsayımıyla verilmiştir.

### 23.1 Tek deneyimli backend geliştirici

| Aşama | Tahmin |
|---|---:|
| Analiz, ERD ve API sözleşmesi | 1–2 hafta |
| Rails altyapısı, auth ve RBAC | 2 hafta |
| Hizmet kataloğu ve CMS temeli | 1 hafta |
| Sipariş, teklif ve durum akışı | 3 hafta |
| Dosya, mesaj ve bildirim | 2 hafta |
| Akbank, havale, kupon ve muhasebe | 2–3 hafta |
| Görev, pano, takvim ve randevu | 2 hafta |
| Eğitim sistemi | 2–3 hafta |
| Dashboard ve raporlama | 1–2 hafta |
| Güvenlik, test, deployment ve düzeltmeler | 2–3 hafta |

Toplam backend eforu: **18–23 geliştirici/hafta**.

Frontend entegrasyonu da aynı kişideyse gerçekçi takvim yaklaşık **5–6 ay** olabilir.

### 23.2 Önerilen ekip

- 2 backend geliştirici
- 1 frontend geliştirici
- Part-time ürün sorumlusu/test
- Gerektiğinde DevOps desteği

Bu ekiple:

- Çalışan çekirdek MVP: **8–10 hafta**
- Mevcut frontend ekranlarına büyük ölçüde backend karşılığı: **12–16 hafta**
- Ödeme, eğitim, CMS, güvenlik sertleştirmesi ve canlıya geçiş dahil olgun sürüm: **16–20 hafta**

Paraşüt, WhatsApp, takvim entegrasyonu ve eski veri aktarımı kapsamına göre **2–5 hafta risk payı** bırakılmalıdır.

## 24. Önerilen geliştirme yöntemi

Tüm tabloları baştan oluşturup frontend’i en sonda bağlamak yerine dikey dilimler halinde ilerlenmelidir.

Her dilimde:

1. Kullanıcı senaryosu belirlenir.
2. API sözleşmesi yazılır.
3. Migration ve model oluşturulur.
4. Policy ve servis katmanı uygulanır.
5. Request/model/service testleri yazılır.
6. Frontend ilgili endpoint’e bağlanır.
7. Kabul kriterleri doğrulanır.
8. Sonraki dilime geçilir.

İlk production değerli dikey dilim:

```text
Müşteri giriş yapar
→ analiz talebi oluşturur
→ dosya yükler
→ admin talebi görür
→ fiyat verir
→ müşteri Akbank/havale ile ödeme yapar
→ analizör atanır
→ mesajlaşma yapılır
→ sonuç dosyası teslim edilir
```

Bu omurga tamamlandıktan sonra eğitim, CMS, toplu mesaj ve gelişmiş raporlama daha güvenli biçimde eklenir.

## 25. Faz 0 başlamadan önce hazırlanacak ilk çalışma listesi

1. Frontend ekran–endpoint matrisi çıkarılacak.
2. Permission matrisi rollerle birlikte onaylanacak.
3. Sipariş durum diyagramı ürün tarafıyla doğrulanacak.
4. ERD hazırlanacak.
5. OpenAPI dosyasının ilk sürümü oluşturulacak.
6. Akbank test reposundaki form ve callback alanları production sözleşmesine eşlenecek.
7. Web/mobil ödeme dönüş stratejisi kesinleştirilecek.
8. SMTP yapılandırma gereksinimleri yazılacak.
9. Storage sağlayıcısı seçilecek.
10. İlk dikey dilimin kabul kriterleri yazılacak.

Bu onaylardan önce kapsamı etkileyen production koduna başlanmamalıdır.
