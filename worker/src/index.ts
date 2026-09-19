/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);

		const corsHeaders = {
			'Access-Control-Allow-Origin': '*',
			'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
			'Access-Control-Allow-Headers': 'Content-Type',
		};

		if (request.method === 'OPTIONS') {
			return new Response(null, {
				status: 204,
				headers: corsHeaders,
			});
		}

		if (request.method === 'GET' && url.pathname === '/codes') {
			const { results } = await env.qr_code_db
				.prepare('SELECT id, text, created_at AS createdAt FROM qr_codes ORDER BY created_at DESC')
				.all();

			return Response.json(results, {
				headers: corsHeaders,
			});
		}

		if (request.method === 'POST' && url.pathname === '/codes') {
			const body = await request.json<{ text?: string }>();

			if (!body.text || body.text.trim() === '') {
				return Response.json({ error: 'Text is required' }, { status: 400 });
			}

			const text = body.text.trim();
			const createdAt = new Date().toISOString();

			const result = await env.qr_code_db.prepare('INSERT INTO qr_codes (text, created_at) VALUES (?, ?)').bind(text, createdAt).run();

			return Response.json(
				{
					id: result.meta.last_row_id,
					text: text,
					createdAt: createdAt,
				},
				{
					status: 201,
					headers: corsHeaders,
				},
			);
		}

		return new Response('Not Found', { status: 404 });
	},
} satisfies ExportedHandler<Env>;
