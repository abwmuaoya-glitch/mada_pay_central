-- Mada Pay API security hardening

ALTER TABLE public.mada_integration_secrets
    ENABLE ROW LEVEL SECURITY;

REVOKE ALL PRIVILEGES
ON TABLE public.mada_integration_secrets
FROM anon, authenticated;

GRANT ALL PRIVILEGES
ON TABLE public.mada_integration_secrets
TO service_role;

-- Keep API credentials inaccessible through the public client.
COMMENT ON TABLE public.mada_integration_secrets IS
'Private API credentials. Access only through trusted server-side functions.';
