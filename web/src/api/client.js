/* ============================================================
   API layer — every network call in the app goes through here.
   Connected to the Express backend. No fake data.

   Requires the backend running on port 4000:
       cd backend && npm run dev
   Vite proxies /api to it (see vite.config.js).
   ============================================================ */

const BASE = '/api'

async function post(path, body) {
  let res
  try {
    res = await fetch(BASE + path, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })
  } catch {
    // fetch only throws when the server can't be reached at all.
    throw new ApiError('Cannot reach the server. Is the backend running on port 4000?')
  }

  const data = await res.json().catch(() => ({}))
  if (!res.ok) {
    throw new ApiError(data.message || 'Something went wrong. Please try again.', data.errors)
  }
  return data
}

/** Carries per-field errors from the server so forms can highlight them. */
export class ApiError extends Error {
  constructor(message, fieldErrors) {
    super(message)
    this.name = 'ApiError'
    this.fieldErrors = fieldErrors || null
  }
}

export const login    = (credentials) => post('/auth/login', credentials)
export const register = (payload)     => post('/auth/register', payload)

export async function getCategories() {
  const res = await fetch(BASE + '/auth/categories')
  if (!res.ok) return []
  const data = await res.json()
  return data.categories || []
}

/** Stores the signed-in user. Phase 4 can move this into React context. */
export const session = {
  save({ user, token }) {
    sessionStorage.setItem('bridgeapp.user', JSON.stringify(user))
    sessionStorage.setItem('bridgeapp.token', token)
  },
  user() {
    try { return JSON.parse(sessionStorage.getItem('bridgeapp.user')) } catch { return null }
  },
  clear() {
    sessionStorage.removeItem('bridgeapp.user')
    sessionStorage.removeItem('bridgeapp.token')
  },
}
