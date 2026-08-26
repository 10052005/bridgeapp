import pg from 'pg'
import 'dotenv/config'

/* A pool keeps a handful of connections open and reuses them.
   Opening a fresh connection per request would be far slower. */
export const pool = new pg.Pool({
  host:     process.env.PGHOST     || 'localhost',
  port:     Number(process.env.PGPORT) || 5432,
  database: process.env.PGDATABASE || 'bridgeapp',
  user:     process.env.PGUSER     || 'bridgeapp_app',
  password: process.env.PGPASSWORD,
  max: 10,
  idleTimeoutMillis: 30000,
})

pool.on('error', (err) => {
  console.error('Unexpected database error:', err.message)
})

/** Run a query. Always pass values as the second argument — never build
    SQL by joining strings, or you open the door to SQL injection. */
export const query = (text, params) => pool.query(text, params)

/** Run several statements as one all-or-nothing unit. */
export async function transaction(fn) {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')
    const result = await fn(client)
    await client.query('COMMIT')
    return result
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
}

export async function checkConnection() {
  const { rows } = await query('SELECT current_database() AS db, now() AS at')
  return rows[0]
}
