// Shared validation rules. The backend must repeat these checks in Phase 3 —
// anything enforced only in the browser can be bypassed.

export const required = (v) => (v && v.trim() ? '' : 'This field is required')

export const email = (v) => {
  if (!v || !v.trim()) return 'Email address is required'
  // Deliberately permissive: catches typos, does not try to prove deliverability.
  return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v.trim()) ? '' : 'Enter a valid email address'
}

export const phone = (v) => {
  if (!v || !v.trim()) return 'Phone number is required'
  const digits = v.replace(/\D/g, '')
  return digits.length >= 10 && digits.length <= 15 ? '' : 'Enter a valid phone number'
}

export const password = (v) => {
  if (!v) return 'Password is required'
  if (v.length < 8) return 'Use at least 8 characters'
  if (!/[A-Za-z]/.test(v) || !/[0-9]/.test(v)) return 'Include at least one letter and one number'
  return ''
}

export const confirmPassword = (v, original) => {
  if (!v) return 'Please confirm your password'
  return v === original ? '' : 'Passwords do not match'
}

/** Runs a rules object against form values and returns { field: message } for failures only. */
export function runValidation(values, rules) {
  const errors = {}
  for (const [field, rule] of Object.entries(rules)) {
    const message = rule(values[field], values)
    if (message) errors[field] = message
  }
  return errors
}
