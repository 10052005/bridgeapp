import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Logo from '../components/Logo.jsx'
import Field from '../components/Field.jsx'
import { LockIcon } from '../components/Icons.jsx'
import { login, session } from '../api/client.js'
import * as v from '../api/validate.js'
import './Login.css'

const RULES = {
  email: (val) => v.email(val),
  password: (val) => (val ? '' : 'Password is required'),
}

export default function Login() {
  const navigate = useNavigate()
  const [values, setValues] = useState({ email: '', password: '' })
  const [remember, setRemember] = useState(false)
  const [errors, setErrors] = useState({})
  const [banner, setBanner] = useState(null)
  const [busy, setBusy] = useState(false)

  const handleChange = (e) => {
    const { name, value } = e.target
    setValues((prev) => ({ ...prev, [name]: value }))
    // Clear a field's error as soon as the person starts fixing it.
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setBanner(null)

    const found = v.runValidation(values, RULES)
    setErrors(found)
    if (Object.keys(found).length) return

    setBusy(true)
    try {
      const result = await login(values)
      session.save(result)
      setBanner({ type: 'success', text: `Welcome back, ${result.user.name}. Signed in as ${result.user.role}.` })
      setTimeout(() => navigate('/'), 1400)
    } catch (err) {
      if (err.fieldErrors) setErrors(err.fieldErrors)
      setBanner({ type: 'error', text: err.message })
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="page login-page">
      <Logo />

      <header className="page-head">
        <h1>Login</h1>
        <p>Welcome back. Sign in to continue.</p>
      </header>

      <form className="login-form" onSubmit={handleSubmit} noValidate>
        <main className="login-main">
          <div className="card login-card">
            <h2><LockIcon /> Account Login</h2>

            {banner && <div className={`banner ${banner.type}`}>{banner.text}</div>}

            <Field
              label="Email Address" name="email" type="email"
              placeholder="Enter your email address" autoComplete="email"
              value={values.email} onChange={handleChange} error={errors.email}
            />

            <Field
              label="Password" name="password" type="password"
              placeholder="Enter your password" autoComplete="current-password"
              value={values.password} onChange={handleChange} error={errors.password}
            />

            <div className="row">
              <label className="remember">
                <input
                  type="checkbox"
                  checked={remember}
                  onChange={(e) => setRemember(e.target.checked)}
                />
                Keep me signed in
              </label>
              <Link className="forgot" to="/login">Forgot password?</Link>
            </div>

            <div className="divider">NEW TO BRIDGEAPP</div>
            <p className="prompt">
              Don&apos;t have an account? <Link to="/register">Create one</Link>
            </p>
          </div>
        </main>

        <button className="btn-submit" type="submit" disabled={busy}>
          {busy ? 'Signing in…' : 'Login'}
        </button>
      </form>
    </div>
  )
}
