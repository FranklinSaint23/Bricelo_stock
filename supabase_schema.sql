-- =================================================================================
-- BRICELO / STOCKPLUS : SCRIPT DE CREATION DE LA BASE DE DONNÉES SUPABASE (100% DYNAMIQUE)
-- Copiez tout ce code et exécutez-le dans "SQL Editor" sur votre Dashboard Supabase.
-- =================================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILS UTILISATEURS / BOUTIQUES
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    company_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    role TEXT DEFAULT 'Administrateur (Gérant)',
    language TEXT DEFAULT 'fr',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. BOUTIQUES & POINTS DE VENTE (Stores)
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    address TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. CATÉGORIES DE PRODUITS (Categories)
CREATE TABLE IF NOT EXISTS public.categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    parent_name TEXT DEFAULT 'Aucune (Catégorie principale)',
    tva DOUBLE PRECISION DEFAULT 19.25,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. PRODUITS (Products)
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    purchase_price DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    stock INTEGER NOT NULL DEFAULT 0,
    min_stock INTEGER NOT NULL DEFAULT 5,
    barcode TEXT NOT NULL,
    unit TEXT DEFAULT 'Pièce (Pce)',
    product_type TEXT DEFAULT 'Produit',
    store_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. CLIENTS (Customers)
CREATE TABLE IF NOT EXISTS public.customers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT DEFAULT '',
    address TEXT DEFAULT '',
    loyalty_points INTEGER DEFAULT 0,
    total_spent DOUBLE PRECISION DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. FOURNISSEURS (Suppliers)
CREATE TABLE IF NOT EXISTS public.suppliers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT DEFAULT '',
    category TEXT DEFAULT 'Marchandises Générales',
    address TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. VENTES (Sales)
CREATE TABLE IF NOT EXISTS public.sales (
    id TEXT PRIMARY KEY,
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    total_amount DOUBLE PRECISION NOT NULL,
    amount_received DOUBLE PRECISION DEFAULT 0.0,
    change_returned DOUBLE PRECISION DEFAULT 0.0,
    payment_method TEXT NOT NULL,
    status TEXT NOT NULL,
    customer_name TEXT DEFAULT 'Client Comptoir',
    cashier_name TEXT DEFAULT 'Gérant',
    store_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. LIGNES DE VENTE (Sale Items)
CREATE TABLE IF NOT EXISTS public.sale_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sale_id TEXT REFERENCES public.sales(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 9. DETTES CLIENTS (Customer Debts)
CREATE TABLE IF NOT EXISTS public.customer_debts (
    id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    phone TEXT,
    total_debt DOUBLE PRECISION NOT NULL,
    remaining_amount DOUBLE PRECISION NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    store_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 10. HISTORIQUE PAIEMENTS DETTES (Debt Payments)
CREATE TABLE IF NOT EXISTS public.debt_payments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    debt_id TEXT REFERENCES public.customer_debts(id) ON DELETE CASCADE,
    amount DOUBLE PRECISION NOT NULL,
    payment_method TEXT NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 11. DÉPENSES (Expenses)
CREATE TABLE IF NOT EXISTS public.expenses (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    payment_method TEXT DEFAULT 'Espèces (Caisse)',
    beneficiary TEXT DEFAULT '',
    notes TEXT DEFAULT '',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 12. MOUVEMENTS DE STOCK (Stock Movements)
CREATE TABLE IF NOT EXISTS public.stock_movements (
    id TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    movement_type TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    reason TEXT DEFAULT '',
    author TEXT DEFAULT '',
    movement_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 13. SESSIONS DE CAISSE (Cash Shifts)
CREATE TABLE IF NOT EXISTS public.cash_shifts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    store_name TEXT NOT NULL,
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    closed_at TIMESTAMP WITH TIME ZONE,
    initial_float DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    final_cash_counted DOUBLE PRECISION,
    status TEXT DEFAULT 'OPEN'
);

-- ACTIVATION RLS & POLITIQUES D'ACCÈS PUBLIC (POUR SYNCHRONISATION DIRECTE)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_shifts ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOREACH tbl IN ARRAY ARRAY[
        'user_profiles', 'stores', 'categories', 'products', 'customers',
        'suppliers', 'sales', 'sale_items', 'customer_debts', 'debt_payments',
        'expenses', 'stock_movements', 'cash_shifts'
    ]
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "Enable all access for %I" ON public.%I;', tbl, tbl);
        EXECUTE format('CREATE POLICY "Enable all access for %I" ON public.%I FOR ALL USING (true) WITH CHECK (true);', tbl, tbl);
    END LOOP;
END
$$;
