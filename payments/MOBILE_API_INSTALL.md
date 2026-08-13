# Mobile REST API — Integration Guide (Sewain Flutter app)

This folder now contains a **mobile-facing REST API** layer in addition to the admin panel.
Everything lives under the `Api` namespace so it never collides with the `Admin` controllers.

## Kebijakan Guest Browsing

Browsing properti bersifat publik, tetapi booking dan pembayaran memerlukan login:
- **Publik:** `GET /api/v1/home`, `/api/v1/properties`, `/api/v1/properties/{id}`, `/api/v1/cities`, `/api/v1/vouchers`
- **Login Required:** `POST /api/v1/bookings`, `/POST /api/v1/orders/{id}/pay`, `/api/v1/wishlists`, `/api/v1/conversations`
- Di Flutter, `SplashScreen` mengarahkan guest ke `Routes.home`. Aksi transaksional menampilkan `Routes.login` jika tidak terautentikasi.

## Files added

```
app/Http/Controllers/Api/
  AuthController.php          register / login / logout / me   (Sanctum tokens)
  HomeController.php          home feed (banners + sections), CMS pages, FAQs, host dashboard
  PropertyController.php      search + filters + detail + availability + host CRUD
  BookingController.php       create booking (+order), list, detail, cancel
  OrderController.php         list / detail + host-scoped orders (forHost/showForHost)
  PaymentController.php       Midtrans Snap create + S2S webhook
  WishlistController.php      toggle / list
  ReviewController.php        property reviews + submit review
  VoucherController.php       list active + apply (shared resolveDiscount)
  ProfileController.php       show / update / become-host
  NotificationController.php  list / mark read / FCM token registration
  ChatController.php          conversations + messages
app/Http/Resources/PropertyResource.php
app/Models/DeviceToken.php
database/migrations/2026_07_14_082400_create_device_tokens_table.php
routes/api_mobile.php
```

## Wiring steps (after `composer create-project` + scaffold copy)

1. **Sanctum** — install and enable API token auth on the User model:
   ```bash
   composer require laravel/sanctum
   php artisan install:api        # publishes routes/api.php + sanctum migration
   ```
   Then add the trait to `app/Models/User.php`:
   ```php
   use Laravel\Sanctum\HasApiTokens;
   class User extends Authenticatable {
       use HasApiTokens, HasFactory, Notifiable;
   }
   ```

2. **Register the mobile routes** — append to `routes/api.php`:
   ```php
   require base_path('routes/api_mobile.php');
   ```
   All endpoints are then served under `/api/v1/...`.

3. **Midtrans** — add to `config/services.php`:
   ```php
   'midtrans' => [
       'server_key'    => env('MIDTRANS_SERVER_KEY'),
       'client_key'    => env('MIDTRANS_CLIENT_KEY'),
       'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
   ],
   ```
   and to `.env`:
   ```
   MIDTRANS_SERVER_KEY=
   MIDTRANS_CLIENT_KEY=
   MIDTRANS_IS_PRODUCTION=false
   ```
   Install the SDK to enable real Snap tokens (otherwise `pay()` returns the raw params payload):
   ```bash
   composer require midtrans/midtrans-php
   ```
   Point your Midtrans dashboard **Payment Notification URL** at `POST /api/v1/payments/webhook`.

4. **Migrate** (includes the new `device_tokens` table):
   ```bash
   php artisan migrate
   ```

## Endpoint summary

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/v1/auth/register` | – | Register consumer/host, returns token |
| POST | `/api/v1/auth/login` | – | Login, returns token |
| POST | `/api/v1/auth/logout` | token | Revoke current token |
| GET | `/api/v1/auth/me` | token | Current user |
| GET | `/api/v1/home` | – | Banners + recommendation sections |
| GET | `/api/v1/properties` | – | Search + filters (q, type, guests, price, sort) |
| GET | `/api/v1/properties/{id}` | – | Property detail |
| GET | `/api/v1/properties/{id}/reviews` | – | Reviews |
| GET | `/api/v1/properties/{id}/availability` | – | Availability calendar |
| GET | `/api/v1/vouchers` | – | Active vouchers |
| POST | `/api/v1/vouchers/apply` | token | Validate + compute discount |
| GET | `/api/v1/cms/{slug}` | – | Privacy / T&C / About |
| GET | `/api/v1/faqs` | – | FAQ grouped by category |
| GET/POST | `/api/v1/bookings` | token | List / create booking (+order) |
| POST | `/api/v1/bookings/{id}/cancel` | token | Cancel |
| POST | `/api/v1/bookings/{id}/review` | token | Submit review |
| POST | `/api/v1/bookings/{id}/confirm` | token | Host confirms booking |
| POST | `/api/v1/bookings/{id}/reject` | token | Host rejects booking |
| POST | `/api/v1/bookings/{id}/checkin` | token | Host marks guest arrived |
| POST | `/api/v1/bookings/{id}/confirm-checkin` | token | Host confirms check-in |
| GET | `/api/v1/orders` `/{id}` | token | Orders (user's own) |
| GET | `/api/v1/host/orders` `/{id}` | token | Orders for host (based on property.host_id) |
| POST | `/api/v1/orders/{id}/pay` | token | Create Midtrans transaction |
| POST | `/api/v1/payments/webhook` | signature | Midtrans notification |
| GET | `/api/v1/wishlists` | token | List |
| POST/DELETE | `/api/v1/wishlists/{property}` | token | Toggle / remove |
| GET | `/api/v1/notifications` | token | List + unread count |
| POST | `/api/v1/devices/fcm-token` | token | Register FCM token |
| GET/POST | `/api/v1/conversations` | token | Chat list / start |
| GET/POST | `/api/v1/conversations/{id}/messages` | token | Messages |
| GET/POST/PUT | `/api/v1/host/properties` | token | Host property CRUD |
| GET | `/api/v1/host/dashboard` | token | Host stats |

## Notes

- `properties.facilities` / `gallery` and `reviews.photos` are JSON string columns; `PropertyResource` decodes them. Actual image **upload** endpoints still need wiring (see scaffold README "Known gaps").
- Booking price is computed from `property_prices` matching the `duration_type`, plus cleaning/service fee and deposit, minus any voucher discount.
