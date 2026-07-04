-- schema.sql — record of the Supabase database structure for Mammoth Decisions.
--
-- NOTE: no schema.sql existed in the repo before this file was added, so the
-- table/RLS definitions below are reconstructed from how index.html queries
-- Supabase (columns selected/inserted/updated, and comments referencing RLS).
-- Verify this against Table Editor / SQL Editor in Supabase and correct
-- anything that doesn't match before treating it as ground truth going forward.
--
-- From this point on: whenever storage shape changes, add the new/changed
-- SQL below (don't rewrite history) and run only that delta in Supabase.

-- ── decisions ────────────────────────────────────────────────────────────────
create table if not exists decisions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id),
  name text not null,
  description text,
  solutions text,
  responses jsonb default '{}'::jsonb,
  grounding jsonb default '{}'::jsonb,
  decided boolean default false,
  conclusion text,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz default now()
);

alter table decisions enable row level security;

-- (CREATE POLICY has no IF NOT EXISTS clause in Postgres — drop first if re-running)
create policy "decisions_select_own" on decisions
  for select using (auth.uid() = user_id);
create policy "decisions_insert_own" on decisions
  for insert with check (auth.uid() = user_id);
create policy "decisions_update_own" on decisions
  for update using (auth.uid() = user_id);
create policy "decisions_delete_own" on decisions
  for delete using (auth.uid() = user_id);

-- ── 2026-07-04: strikethrough / "possible solutions" checklist (PR #8) ───────
-- Tracks which solution lines a user has struck through, keyed by a stable
-- per-line id (see hashLine() in index.html). Only new/changed SQL — run just
-- this statement in Supabase, do not re-run the CREATE TABLE above.
alter table decisions
  add column if not exists solutions_struck jsonb default '{}'::jsonb;
