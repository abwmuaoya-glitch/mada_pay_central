import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ message: "POST only" }, 405);
  }

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!url || !anonKey || !serviceKey) {
    return json({
      message: "إعدادات Supabase الخاصة بالخادم غير مكتملة.",
    }, 500);
  }

  const authHeader = req.headers.get("Authorization") ?? "";

  const userClient = createClient(url, anonKey, {
    global: {
      headers: { Authorization: authHeader },
    },
  });

  const { data: userData, error: userError } =
    await userClient.auth.getUser();

  if (userError || !userData.user) {
    return json({ message: "يجب تسجيل الدخول أولًا." }, 401);
  }

  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false },
  });

  const uid = userData.user.id;

  let isOwner = false;

  const profile = await admin
    .from("profiles")
    .select("role,status")
    .eq("id", uid)
    .maybeSingle();

  if (
    profile.data &&
    String(profile.data.role ?? "").toUpperCase() === "OWNER" &&
    ["ACTIVE", "APPROVED"].includes(
      String(profile.data.status ?? "").toUpperCase()
    )
  ) {
    isOwner = true;
  }

  if (!isOwner) {
    const role = await admin
      .from("user_roles")
      .select("role")
      .eq("user_id", uid);

    isOwner = (role.data ?? []).some(
      (r: { role?: string }) =>
        String(r.role ?? "").toUpperCase() === "OWNER"
    );
  }

  if (!isOwner) {
    return json({ message: "هذه العملية مخصصة لمالك النظام." }, 403);
  }

  let input: Record<string, unknown>;

  try {
    input = await req.json();
  } catch {
    return json({ message: "بيانات الطلب غير صحيحة." }, 400);
  }

  const action = String(input.action ?? "");

  // حفظ جهة API وبيانات اعتمادها السرية
  if (action === "save") {
    const providerName = String(
      input.display_name ?? input.provider_name ?? ""
    ).trim();

    const baseUrl = String(input.base_url ?? "")
      .trim()
      .replace(/\/$/, "");

    if (!providerName || !baseUrl) {
      return json({
        message: "اسم الجهة وعنوان API مطلوبان.",
      }, 400);
    }

    if (!/^https?:\/\//i.test(baseUrl)) {
      return json({
        message: "عنوان API يجب أن يبدأ بـ http:// أو https://",
      }, 400);
    }

    const row = await admin
      .from("mada_integrations")
      .insert({
        provider_name: providerName,
        base_url: baseUrl,
        token_url: String(input.token_url ?? "").trim() || null,
        auth_type: String(input.auth_type ?? "API Key"),
        status: "INACTIVE",
        notes: String(input.notes ?? "").trim() || null,
      })
      .select(
        "id,provider_name,base_url,auth_type,status,created_at"
      )
      .single();

    if (row.error || !row.data) {
      return json({
        message: "تعذر حفظ جهة API: " +
          (row.error?.message ?? "خطأ غير معروف"),
      }, 500);
    }

    const secret = await admin
      .from("mada_integration_secrets")
      .insert({
        integration_id: row.data.id,
        owner_id: uid,
        username: String(input.username ?? "").trim() || null,
        api_key: String(input.api_key ?? "") || null,
        api_secret: String(input.api_secret ?? "") || null,
      });

    if (secret.error) {
      await admin
        .from("mada_integrations")
        .delete()
        .eq("id", row.data.id);

      return json({
        message: "تعذر حفظ بيانات الاعتماد السرية: " +
          secret.error.message,
      }, 500);
    }

    return json({
      message: "تم حفظ جهة الربط. يجب اختبار الاتصال قبل تفعيلها.",
      integration: row.data,
    });
  }

  const id = String(input.id ?? "");

  if (!id) {
    return json({ message: "معرّف جهة الربط مطلوب." }, 400);
  }

  const { data: integration, error: intError } = await admin
    .from("mada_integrations")
    .select("id,provider_name,base_url,auth_type,status")
    .eq("id", id)
    .single();

  if (intError || !integration) {
    return json({ message: "جهة الربط غير موجودة." }, 404);
  }

  const { data: secret, error: secretError } = await admin
    .from("mada_integration_secrets")
    .select("username,api_key,api_secret,owner_id")
    .eq("integration_id", id)
    .single();

  if (secretError || !secret || secret.owner_id !== uid) {
    return json({
      message: "بيانات الاعتماد غير متاحة لهذا المالك.",
    }, 403);
  }

  const isMega =
    /mega\s*center|megatec-center\.com/i.test(
      `${integration.provider_name} ${integration.base_url}`
    );

  try {
    // الاستعلام عن رصيد Mega Center
    if (action === "balance") {
      if (!isMega) {
        return json({
          message:
            "طلب الرصيد لهذا المزود يحتاج إلى محول API خاص به.",
        }, 400);
      }

      if (!secret.username || !secret.api_key) {
        return json({
          message: "اسم المستخدم وApiKey مطلوبان.",
        }, 400);
      }

      const endpoint =
        `${integration.base_url}/${encodeURIComponent(secret.username)}` +
        `/${encodeURIComponent(secret.api_key)}`;

      const resp = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({ request: "balance" }),
      });

      const body = await resp.text();

      if (!resp.ok) {
        return json({
          message: `رفض المزود الطلب (HTTP ${resp.status}).`,
          provider_response: body.slice(0, 1000),
        }, 502);
      }

      await admin
        .from("mada_integrations")
        .update({
          status: "ACTIVE",
          updated_at: new Date().toISOString(),
        })
        .eq("id", id);

      return json({
        message: "استجابة المزود لطلب الرصيد:",
        balance: body.slice(0, 1500),
        status: "ACTIVE",
      });
    }

    // اختبار الاتصال
    if (action === "test") {
      if (isMega) {
        if (!secret.username || !secret.api_key) {
          return json({
            message: "اسم المستخدم وApiKey مطلوبان.",
          }, 400);
        }

        const endpoint =
          `${integration.base_url}/${encodeURIComponent(secret.username)}` +
          `/${encodeURIComponent(secret.api_key)}`;

        const resp = await fetch(endpoint, {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: new URLSearchParams({ request: "balance" }),
        });

        const body = await resp.text();

        if (!resp.ok) {
          await admin
            .from("mada_integrations")
            .update({
              status: "INACTIVE",
              updated_at: new Date().toISOString(),
            })
            .eq("id", id);

          return json({
            message: `فشل الاتصال (HTTP ${resp.status}).`,
            provider_response: body.slice(0, 1000),
            status: "INACTIVE",
          }, 502);
        }

        await admin
          .from("mada_integrations")
          .update({
            status: "ACTIVE",
            updated_at: new Date().toISOString(),
          })
          .eq("id", id);

        return json({
          message:
            "استجاب Mega Center للطلب. لم يتم التحقق المالي المستقل من الرصيد.",
          status: "ACTIVE",
          provider_response: body.slice(0, 1000),
        });
      }

      // اختبار عام لبقية الجهات
      const headers: Record<string, string> = {
        Accept: "application/json",
      };

      if (secret.api_key) {
        headers["X-API-Key"] = secret.api_key;
      }

      const resp = await fetch(integration.base_url, {
        method: "GET",
        headers,
      });

      const body = await resp.text();
      const ok = resp.status < 500;

      await admin
        .from("mada_integrations")
        .update({
          status: ok ? "ACTIVE" : "INACTIVE",
          updated_at: new Date().toISOString(),
        })
        .eq("id", id);

      return json({
        message: ok
          ? `وصل الطلب إلى عنوان API (HTTP ${resp.status}). لا يعني ذلك بالضرورة نجاح المصادقة.`
          : `فشل الاتصال (HTTP ${resp.status}).`,
        status: ok ? "ACTIVE" : "INACTIVE",
        provider_response: body.slice(0, 1000),
      }, ok ? 200 : 502);
    }

    return json({ message: "الإجراء غير معروف." }, 400);
  } catch (e) {
    await admin
      .from("mada_integrations")
      .update({
        status: "INACTIVE",
        updated_at: new Date().toISOString(),
      })
      .eq("id", id);

    return json({
      message: "تعذر الاتصال بالمزود: " +
        (e instanceof Error ? e.message : String(e)),
    }, 502);
  }
});
