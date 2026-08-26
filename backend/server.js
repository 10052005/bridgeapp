import express from 'express'
import cors from 'cors'
import 'dotenv/config'
import authRoutes from './src/routes/auth.js'
import { checkConnection } from './src/lib/db.js'

const app = express()
const PORT = Number(process.env.PORT) || 4000

app.use(cors({ origin: ['http://localhost:5173', 'http://127.0.0.1:5173'] }))
app.use(express.json())

// Health check — open http://localhost:4000/api/health in a browser to
// confirm the server is up and the database is reachable.
app.get('/api/health', async (req, res) => {
  try {
    const info = await checkConnection()
    res.json({ status: 'ok', database: info.db, serverTime: info.at })
  } catch (err) {
    res.status(503).json({ status: 'database unreachable', message: err.message })
  }
})

app.use('/api/auth', authRoutes)

app.use((req, res) => {
  res.status(404).json({ message: `No route for ${req.method} ${req.originalUrl}` })
})

// Catch-all error handler. Logs the real error for you, returns a generic
// message to the browser so internals aren't leaked to users.
app.use((err, req, res, next) => {
  console.error('[error]', err)
  res.status(500).json({ message: 'Something went wrong on the server.' })
})

app.listen(PORT, async () => {
  console.log(`BridgeApp API listening on http://localhost:${PORT}`)
  try {
    const info = await checkConnection()
    console.log(`Connected to database "${info.db}"`)
  } catch (err) {
    console.error('WARNING: could not reach the database —', err.message)
    console.error('Check that PostgreSQL is running and .env has the right password.')
  }
})
