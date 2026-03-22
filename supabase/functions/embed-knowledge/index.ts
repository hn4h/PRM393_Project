import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const GEMINI_EMBED_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent";

async function embedText(text: string): Promise<number[]> {
    const res = await fetch(`${GEMINI_EMBED_URL}?key=${GEMINI_API_KEY}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content: { parts: [{ text }] } }),
    });
    if (!res.ok) {
        const err = await res.text();
        throw new Error(`Embedding failed: ${err}`);
    }
    const data = await res.json();
    return data.embedding?.values ?? [];
}

Deno.serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type" } });
    }
    try {
        const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
        const { data: entries, error } = await supabase.from("support_knowledge").select("id, title, content").is("embedding", null).eq("is_active", true);
        if (error) throw error;
        if (!entries || entries.length === 0) {
            return new Response(JSON.stringify({ message: "No entries need embedding", count: 0 }), { status: 200, headers: { "Content-Type": "application/json" } });
        }
        let embedded = 0;
        for (const entry of entries) {
            const textToEmbed = `${entry.title}\n${entry.content}`;
            const embedding = await embedText(textToEmbed);
            const { error: updateError } = await supabase.from("support_knowledge").update({ embedding: JSON.stringify(embedding) }).eq("id", entry.id);
            if (updateError) { console.error(`Failed: ${entry.id}`, updateError); continue; }
            embedded++;
            await new Promise((r) => setTimeout(r, 250));
        }
        return new Response(JSON.stringify({ message: `Embedded ${embedded}/${entries.length}`, count: embedded }), { status: 200, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } });
    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message ?? "Internal error" }), { status: 500, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } });
    }
});
