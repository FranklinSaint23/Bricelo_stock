-- ========================================================
-- SCHÉMA DE BASE DE DONNÉES : STOCK PRIME (SaaS Caisse & Stock)
-- Adapté au Cameroun (Douala, Yaoundé, FCFA, OM/MoMo, Dettes)
-- ========================================================

-- 1. Boutiques / Points de vente
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Douala',
    address TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Produits & Inventaire
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Général',
    barcode TEXT,
    buy_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    sell_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    stock_quantity INT NOT NULL DEFAULT 0,
    min_stock_alert INT NOT NULL DEFAULT 5,
    is_synced_bricelo BOOLEAN DEFAULT false,
    bricelo_product_id TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index pour recherche rapide et scan code-barres en caisse
CREATE INDEX IF NOT EXISTS idx_products_barcode ON public.products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_store ON public.products(store_id);

-- 3. Ventes & Encaissements (Tickets de caisse)
CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    ticket_number TEXT NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    payment_method TEXT NOT NULL, -- 'cash', 'orange_money', 'mtn_momo', 'credit'
    customer_name TEXT DEFAULT 'Client Comptoir',
    customer_phone TEXT,
    cashier_name TEXT DEFAULT 'Caissier Principal',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Lignes d'articles par vente
CREATE TABLE IF NOT EXISTS public.sale_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID REFERENCES public.sales(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    buy_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    unit_price NUMERIC(12, 2) NOT NULL,
    total_price NUMERIC(12, 2) NOT NULL
);

-- 5. Carnet de Dettes & Crédits Clients
CREATE TABLE IF NOT EXISTS public.customer_debts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    initial_debt NUMERIC(12, 2) NOT NULL,
    paid_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    is_settled BOOLEAN DEFAULT false,
    notes TEXT,
    items_summary TEXT[],
    created_at TIMESTAMPTZ DEFAULT now(),
    last_payment_date TIMESTAMPTZ DEFAULT now()
);

-- 6. Versements / Acomptes sur dettes
CREATE TABLE IF NOT EXISTS public.debt_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    debt_id UUID REFERENCES public.customer_debts(id) ON DELETE CASCADE,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method TEXT DEFAULT 'cash',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Clôtures de Caisse Journalières (Z de Caisse)
CREATE TABLE IF NOT EXISTS public.cash_shifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    opened_at TIMESTAMPTZ DEFAULT now(),
    closed_at TIMESTAMPTZ,
    initial_cash NUMERIC(12, 2) DEFAULT 0,
    actual_cash NUMERIC(12, 2),
    expected_cash NUMERIC(12, 2),
    total_sales NUMERIC(12, 2) DEFAULT 0,
    total_orange_money NUMERIC(12, 2) DEFAULT 0,
    total_mtn_momo NUMERIC(12, 2) DEFAULT 0,
    total_credit NUMERIC(12, 2) DEFAULT 0,
    is_closed BOOLEAN DEFAULT false
);

-- 8. Données initiales d'exemple (Cameroun)
INSERT INTO public.stores (name, city, address, phone)
VALUES 
    ('Boutique BRICÉLO Akwa', 'Douala', 'Boulevard de la Liberté, Akwa', '+237 6 52 70 42 18'),
    ('Magasin BRICÉLO Bastos', 'Yaoundé', 'Face Ambassade, Bastos', '+237 6 99 00 11 22')
ON CONFLICT DO NOTHING;

-- RLS (Row Level Security) activé avec accès public pour le client API
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_shifts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read-write for stores" ON public.stores FOR ALL USING (true);
CREATE POLICY "Allow public read-write for products" ON public.products FOR ALL USING (true);
CREATE POLICY "Allow public read-write for sales" ON public.sales FOR ALL USING (true);
CREATE POLICY "Allow public read-write for sale_items" ON public.sale_items FOR ALL USING (true);
CREATE POLICY "Allow public read-write for customer_debts" ON public.customer_debts FOR ALL USING (true);
CREATE POLICY "Allow public read-write for debt_payments" ON public.debt_payments FOR ALL USING (true);
CREATE POLICY "Allow public read-write for cash_shifts" ON public.cash_shifts FOR ALL USING (true);
