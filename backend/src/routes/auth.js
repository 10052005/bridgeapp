import { Router } from 'express'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { query, transaction } from '../lib/db.js'
import { validateLogin, validateRegister } from '../lib/validate.js'

const router = Router()
const SALT_ROUNDS = 10

const signToken = (user) =>
  jwt.sign(
    { userId: user.user_id, role: user.role },
    process.env.JWT_SECRET || 'dev-secret',
    { expiresIn: '7d' }
  )

const publicUser = (row) => ({
  userId: row.user_id,
  name: row.name,
  email: row.email,
  role: row.role,
  verified: row.verified,
})

/* ------------------------------------------------------------------
   POST /api/auth/register
   Creates a users row and its profiles row together. If either fails,
   the transaction rolls back and no half-made account is left behind.
   ------------------------------------------------------------------ */
router.post('/register', async (req, res, next) => {
  try {
    const errors = validateRegister(req.body)
    if (Object.keys(errors).length) {
      return res.status(400).json({ message: 'Please fix the highlighted fields.', errors })
    }

    const { role, email, phone, password } = req.body
    const isSeller = role === 'seller'
    const name = isSeller ? req.body.ownerName : req.body.fullName

    const existing = await query(
      'SELECT role FROM users WHERE LOWER(email) = LOWER($1)',
      [email]
    )
    if (existing.rowCount > 0) {
      return res.status(409).json({
        message: `This email is already registered as a ${existing.rows[0].role} account. Try logging in instead.`,
        errors: { email: 'Email already registered' },
      })
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS)

    const user = await transaction(async (client) => {
      const inserted = await client.query(
        `INSERT INTO users (name, email, password_hash, phone, role, verified)
         VALUES ($1, $2, $3, $4, $5, FALSE)
         RETURNING user_id, name, email, role, verified`,
        [name.trim(), email.trim(), passwordHash, phone.trim(), role]
      )
      const row = inserted.rows[0]

      // Sellers pick a category by name; translate it to its id.
      let categoryId = null
      if (isSeller) {
        const cat = await client.query(
          'SELECT category_id FROM categories WHERE name = $1',
          [req.body.service]
        )
        categoryId = cat.rows[0]?.category_id ?? null
      }

      await client.query(
        `INSERT INTO profiles
           (user_id, bio, location, address, preferred_services, business_name, primary_category_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          row.user_id,
          isSeller ? req.body.description?.trim() ?? null : null,
          null,
          isSeller ? req.body.businessAddress?.trim() : req.body.address?.trim(),
          isSeller ? null : req.body.preferredServices?.trim() || null,
          isSeller ? req.body.businessName?.trim() : null,
          categoryId,
        ]
      )

      return row
    })

    return res.status(201).json({ user: publicUser(user), token: signToken(user) })
  } catch (err) {
    next(err)
  }
})

/* ------------------------------------------------------------------
   POST /api/auth/login
   ------------------------------------------------------------------ */
router.post('/login', async (req, res, next) => {
  try {
    const errors = validateLogin(req.body)
    if (Object.keys(errors).length) {
      return res.status(400).json({ message: 'Please fix the highlighted fields.', errors })
    }

    const { email, password } = req.body
    const found = await query(
      `SELECT user_id, name, email, role, verified, password_hash
       FROM users WHERE LOWER(email) = LOWER($1)`,
      [email]
    )

    const row = found.rows[0]
    // One message for both failure cases. Saying "no such email" would let
    // anyone test which addresses are registered.
    const ok = row ? await bcrypt.compare(password, row.password_hash) : false
    if (!ok) {
      return res.status(401).json({ message: 'Email or password is incorrect.' })
    }

    await query(
      `INSERT INTO logs (user_id, activity_performed, activity_type)
       VALUES ($1, 'Signed in from the web application', 'auth')`,
      [row.user_id]
    )

    return res.json({ user: publicUser(row), token: signToken(row) })
  } catch (err) {
    next(err)
  }
})

/* Categories for the seller dropdown, so the form isn't hardcoded. */
router.get('/categories', async (req, res, next) => {
  try {
    const { rows } = await query(
      'SELECT category_id, name FROM categories WHERE parent_category_id IS NULL ORDER BY name'
    )
    res.json({ categories: rows })
  } catch (err) {
    next(err)
  }
})

export default router
