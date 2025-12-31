# CureLedger

A medical payment rail for settling verified hospital invoices directly. Built with Flutter and Supabase.

## Features

### For Donors
- View verified hospital invoices
- Make secure partial or full payments
- Real-time payment progress tracking
- Transaction receipts and sharing

### For Hospital Staff
- **Social Workers**: Upload patient invoices
- **Hospital Admin**: Verify and approve invoices
- **Finance Officers**: Track settlements and reconciliation

### For Super Admin
- Hospital provisioning and management
- Platform configuration (fees, payment gateway)
- Audit logs for compliance
- System-wide governance

## Tech Stack

- **Frontend**: Flutter 3.8+
- **Backend**: Supabase (Auth + PostgreSQL)
- **Payments**: Paystack (with split payments)
- **State Management**: Provider

## Getting Started

### Prerequisites

- Flutter SDK 3.8 or higher
- A Supabase project
- A Paystack account

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/cure_ledger.git
   cd cure_ledger
   ```

2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

3. Configure your `.env` file with:
   - Supabase URL and Anon Key
   - Paystack Public and Secret Keys

4. Update `lib/src/config/env_config.dart` with your Supabase credentials.

5. Install dependencies:
   ```bash
   flutter pub get
   ```

6. Run the app:
   ```bash
   flutter run
   ```

### Database Setup

Run these SQL migrations in your Supabase project:

```sql
-- Hospitals table
CREATE TABLE hospitals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  address TEXT NOT NULL,
  logo_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'pending',
  bank_account_number TEXT NOT NULL,
  bank_name TEXT NOT NULL,
  paystack_subaccount_code TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  suspension_reason TEXT,
  suspended_at TIMESTAMPTZ,
  admin_user_id UUID
);

-- Access codes for hospital staff login
CREATE TABLE access_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  hospital_id UUID REFERENCES hospitals(id),
  role TEXT NOT NULL,
  is_used BOOLEAN DEFAULT false,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Invoices table
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hospital_id UUID REFERENCES hospitals(id),
  patient_name TEXT NOT NULL,
  category TEXT NOT NULL,
  amount_total DECIMAL NOT NULL,
  amount_paid DECIMAL DEFAULT 0,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  verified_at TIMESTAMPTZ,
  verified_by UUID
);

-- Audit logs for Super Admin
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action TEXT NOT NULL,
  actor_id UUID NOT NULL,
  actor_name TEXT NOT NULL,
  hospital_id UUID,
  hospital_name TEXT,
  details JSONB,
  timestamp TIMESTAMPTZ DEFAULT now()
);
```

## Architecture

```
lib/
├── main.dart                 # App entry point
└── src/
    ├── app/                  # App widget with Provider setup
    ├── config/               # Environment configuration
    ├── core/                 # Result types, logging
    ├── data/                 # Data layer (deprecated)
    ├── models/               # Data models
    ├── providers/            # State management
    ├── repositories/         # Data access layer
    ├── screens/              # UI screens
    ├── services/             # External services (Supabase, Payments)
    ├── theme/                # App theming
    ├── utils/                # Utilities
    └── widgets/              # Reusable widgets
```

## Payment Flow

1. Donor views verified invoice via shared link
2. Donor selects payment amount
3. Payment initialized via Paystack with split:
   - 95% → Hospital Subaccount
   - 5% → CureLedger Platform Fee
4. Payment verified and invoice updated
5. Bank narration: `CURE-[HOSPITALCODE]-[INVOICEID]`

## License

Proprietary - All rights reserved.
