
export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);

		const corsHeaders = {
			'Access-Control-Allow-Origin': 'http://localhost:5000',
			'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
			'Access-Control-Allow-Headers': 'Content-Type',
			'Access-Control-Allow-Credentials': 'true',
		};

		if (request.method === 'OPTIONS') {
			return new Response(null, {
				status: 204,
				headers: corsHeaders,
			});
		}

		if (request.method === 'GET' && url.pathname === '/login') {
			return Response.redirect('http://localhost:5000', 302);
		}

		if (request.method === 'GET' && url.pathname === '/auth/check') {
			return Response.json(
				{ authenticated: true },
				{ headers: corsHeaders },
			);
		}

		if (request.method === 'GET' && url.pathname === '/codes') {
			const { results } = await env.qr_code_db
				.prepare(
					'SELECT id, text, created_at AS createdAt FROM qr_codes ORDER BY created_at DESC',
				)
				.all();

			return Response.json(results, {
				headers: corsHeaders,
			});
		}

		if (request.method === 'POST' && url.pathname === '/codes') {
			const body = await request.json<{ text?: string }>();

			if (!body.text || body.text.trim() === '') {
				return Response.json(
					{ error: 'Text is required' },
					{
						status: 400,
						headers: corsHeaders,
					},
				);
			}

			const text = body.text.trim();
			const createdAt = new Date().toISOString();

			const result = await env.qr_code_db
				.prepare(
					'INSERT INTO qr_codes (text, created_at) VALUES (?, ?)',
				)
				.bind(text, createdAt)
				.run();

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

		if (request.method === 'DELETE' && url.pathname.startsWith('/codes/')) {
			const id = url.pathname.split('/')[2];

			if (!id || isNaN(Number(id))) {
				return Response.json(
					{ error: 'Invalid code ID' },
					{
						status: 400,
						headers: corsHeaders,
					},
				);
			}

			const result = await env.qr_code_db
				.prepare('DELETE FROM qr_codes WHERE id = ?')
				.bind(Number(id))
				.run();

			if (result.meta.changes === 0) {
				return Response.json(
					{ error: 'QR code not found' },
					{
						status: 404,
						headers: corsHeaders,
					},
				);
			}

			return Response.json(
				{ deleted: true },
				{ headers: corsHeaders },
			);
		}

		return new Response('Not Found', {
			status: 404,
			headers: corsHeaders,
		});
	},
} satisfies ExportedHandler<Env>;