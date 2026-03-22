import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const GEMINI_EMBED_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent";
const GEMINI_GENERATE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

const SYSTEM_PROMPT = `You are HoSe AI Assistant — a helpful, friendly support chatbot for the HoSe (Home Services) mobile application.

Your role:
- Answer questions about HoSe services, bookings, policies, and account features
- Help customers understand their booking history and service options
- Be concise, accurate, and helpful
- Always respond in English
- If you don't know the answer, say so honestly and suggest the customer contact human support
- Never make up information not provided in the context
- When referring to prices, use the dollar sign ($) format
- When referring to dates, use a human-readable format

IMPORTANT: Base your answers ONLY on the provided context data. Do not hallucinate or invent information.`;

// ── Helpers ──────────────────────────────────────────────────────────────

async function embedText(text: string): Promise<number[]> {
    const res = await fetch(`${GEMINI_EMBED_URL}?key=${GEMINI_API_KEY}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            content: { parts: [{ text }] },
        }),
    });
    if (!res.ok) {
        const err = await res.text();
        throw new Error(`Embedding failed: ${err}`);
    }
    const data = await res.json();
    return data.embedding?.values ?? [];
}

async function generateAnswer(prompt: string): Promise<string> {
    const res = await fetch(`${GEMINI_GENERATE_URL}?key=${GEMINI_API_KEY}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: {
                temperature: 0.3,
                maxOutputTokens: 1024,
            },
        }),
    });
    if (!res.ok) {
        const err = await res.text();
        throw new Error(`Generation failed: ${err}`);
    }
    const data = await res.json();
    return data.candidates?.[0]?.content?.parts?.[0]?.text ?? "I'm sorry, I couldn't generate a response.";
}

// ── Main handler ─────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
    // CORS
    if (req.method === "OPTIONS") {
        return new Response("ok", {
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
                "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
            },
        });
    }

    try {
        // 1. Parse request
        const { question, conversation_id } = await req.json();
        if (!question || typeof question !== "string" || question.trim().length === 0) {
            return new Response(JSON.stringify({ error: "Question is required" }), {
                status: 400,
                headers: { "Content-Type": "application/json" },
            });
        }

        // 2. Auth — get user from JWT
        const authHeader = req.headers.get("Authorization") ?? "";
        const token = authHeader.replace("Bearer ", "");

        const supabaseUser = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
        const { data: { user }, error: userError } = await createClient(
            SUPABASE_URL,
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: `Bearer ${token}` } } }
        ).auth.getUser();

        if (userError || !user) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), {
                status: 401,
                headers: { "Content-Type": "application/json" },
            });
        }

        const customerId = user.id;

        // 3. Get or create conversation
        let convId = conversation_id;
        if (!convId) {
            const { data: existingConv } = await supabaseUser
                .from("ai_support_conversations")
                .select("id")
                .eq("customer_id", customerId)
                .order("created_at", { ascending: false })
                .limit(1)
                .maybeSingle();

            if (existingConv) {
                convId = existingConv.id;
            } else {
                const { data: newConv, error: convError } = await supabaseUser
                    .from("ai_support_conversations")
                    .insert({ customer_id: customerId })
                    .select("id")
                    .single();
                if (convError) throw convError;
                convId = newConv.id;
            }
        }

        // 4. Insert user message
        await supabaseUser.from("ai_support_messages").insert({
            conversation_id: convId,
            role: "user",
            content: question.trim(),
        });

        // 5. RAG — embed question & search knowledge
        const queryEmbedding = await embedText(question.trim());

        const { data: knowledgeChunks } = await supabaseUser.rpc(
            "match_support_knowledge",
            {
                query_embedding: JSON.stringify(queryEmbedding),
                match_threshold: 0.3,
                match_count: 5,
            }
        );

        // 6. Dynamic context — customer profile
        const { data: profile } = await supabaseUser
            .from("profiles")
            .select("full_name, phone, address, gender")
            .eq("id", customerId)
            .maybeSingle();

        // 7. Dynamic context — recent bookings
        const { data: bookings } = await supabaseUser
            .from("bookings")
            .select(`
        id, status, scheduled_at, address, total_price, payment_method, notes,
        service:services!bookings_service_id_fkey(name, price),
        worker:profiles!bookings_worker_id_fkey(full_name)
      `)
            .eq("customer_id", customerId)
            .order("created_at", { ascending: false })
            .limit(10);

        // 8. Dynamic context — all active services
        const { data: services } = await supabaseUser
            .from("services")
            .select("name, description, price, duration_minutes, category")
            .eq("is_active", true)
            .order("name");

        // 9. Conversation history (last 6 messages)
        const { data: history } = await supabaseUser
            .from("ai_support_messages")
            .select("role, content")
            .eq("conversation_id", convId)
            .order("created_at", { ascending: false })
            .limit(7);

        const historyMessages = (history ?? [])
            .reverse()
            .slice(0, -1)
            .map((m: { role: string; content: string }) => `${m.role}: ${m.content}`)
            .join("\n");

        // 10. Build prompt
        const knowledgeContext = (knowledgeChunks ?? [])
            .map((c: { title: string; content: string }) => `[${c.title}]\n${c.content}`)
            .join("\n\n");

        const profileContext = profile
            ? `Customer name: ${profile.full_name ?? "Unknown"}, Phone: ${profile.phone ?? "N/A"}, Address: ${profile.address ?? "N/A"}, Gender: ${profile.gender ?? "N/A"}`
            : "Customer profile not available.";

        const bookingsContext = (bookings ?? []).length > 0
            ? (bookings ?? []).map((b: any, i: number) => {
                const svc = b.service?.name ?? "Unknown service";
                const worker = b.worker?.full_name ?? "Unassigned";
                const date = b.scheduled_at ? new Date(b.scheduled_at).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" }) : "N/A";
                return `${i + 1}. ${svc} — Status: ${b.status}, Date: ${date}, Worker: ${worker}, Price: $${b.total_price ?? b.service?.price ?? "N/A"}, Address: ${b.address ?? "N/A"}`;
            }).join("\n")
            : "No recent bookings found.";

        const servicesContext = (services ?? []).length > 0
            ? (services ?? []).map((s: any) => `- ${s.name} ($${s.price}) — ${s.description} (${s.duration_minutes} min, Category: ${s.category})`).join("\n")
            : "No services available.";

        const fullPrompt = `${SYSTEM_PROMPT}

=== KNOWLEDGE BASE ===
${knowledgeContext || "No relevant knowledge found."}

=== CUSTOMER PROFILE ===
${profileContext}

=== CUSTOMER'S RECENT BOOKINGS (most recent first) ===
${bookingsContext}

=== AVAILABLE SERVICES ===
${servicesContext}

=== CONVERSATION HISTORY ===
${historyMessages || "(New conversation)"}

=== CURRENT QUESTION ===
${question.trim()}

Please provide a helpful, concise answer:`;

        // 11. Generate answer
        const answer = await generateAnswer(fullPrompt);

        // 12. Save assistant message
        const sources = (knowledgeChunks ?? []).map((c: { id: string; title: string; category: string }) => ({
            id: c.id,
            title: c.title,
            category: c.category,
        }));

        await supabaseUser.from("ai_support_messages").insert({
            conversation_id: convId,
            role: "assistant",
            content: answer,
            sources: JSON.stringify(sources),
        });

        // 13. Update conversation timestamp
        await supabaseUser
            .from("ai_support_conversations")
            .update({ updated_at: new Date().toISOString() })
            .eq("id", convId);

        return new Response(
            JSON.stringify({ answer, conversation_id: convId, sources }),
            {
                status: 200,
                headers: {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
            }
        );
    } catch (err: any) {
        console.error("AI Support Chat error:", err);
        return new Response(
            JSON.stringify({ error: err.message ?? "Internal server error" }),
            {
                status: 500,
                headers: {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
            }
        );
    }
});
