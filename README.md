# management_debts_app
Hisabi (حسابي) — Customer Debt Ledger for Small Shops

An offline-first, multi-tenant mobile app that lets grocery stores and small retailers replace the paper debt notebook: record customer debts and payments, track balances automatically, and send statements and reminders over WhatsApp. Arabic-first (RTL) UI.

Features
1-Customers & ledger — add customers, record debts/payments, automatic running balance, per-customer statement history.
2-Offline-first — Cloud Firestore persistence: operations are saved locally and synced automatically when the connection returns.
3-WhatsApp integration — send an account statement or a payment reminder straight to the customer's chat (wa.me deep links).
4-Debt-limit alerts — set a maximum debt; customers who reach it appear in an in-app notification center with one-tap reminder or dismiss.
5-Reports — today / this week / this month: total debts added, total payments, top debtors.
6-Quick entry — product-name suggestions while recording a debt; shop owners can add their own products.
7-Backup & restore — export all data to a JSON file and re-import it (idempotent import).
8-Subscriptions — free trial, expiry and deactivation gate, plus an admin panel to renew, deactivate or contact stores.
9-Multi-tenant — every store has its own isolated account and data.

Tech Stack:

Framework: Flutter (Dart)

Backend as a Service: Firebase (Firestore, Authentication)

State Management: Provider

Tools: flutter_launcher_icons, flutter_native_splash, file_picker, share_plus.

Architecture:
lib/
├── core/        constants, theme (colors, Material 3 theme)
├── models/      Store, Customer, Transaction
├── providers/   app state (customers, store settings, alerts)
├── services/    Firebase data layer + auth
├── views/       screens (auth, home, customers, reports, settings, notifications, admin)
├── widgets/     reusable components
└── routes/      named routes
