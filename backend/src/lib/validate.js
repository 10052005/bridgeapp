/* The browser runs the same checks for a nicer experience, but these are the
   ones that count — anyone can bypass the browser and post straight here. */

const isEmail = (v) => /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(String(v || '').trim())
const digits  = (v) => String(v || '').replace(/\D/g, '')

export function validateLogin(body) {
  const errors = {}
  if (!isEmail(body.email)) errors.email = 'Enter a valid email address'
  if (!body.password) errors.password = 'Password is required'
  return errors
}

export function validateRegister(body) {
  const errors = {}
  const role = body.role

  if (role !== 'customer' && role !== 'seller') {
    errors.role = 'Role must be customer or seller'
    return errors
  }

  if (!isEmail(body.email)) errors.email = 'Enter a valid email address'

  const phoneDigits = digits(body.phone)
  if (phoneDigits.length < 10 || phoneDigits.length > 15) {
    errors.phone = 'Enter a valid phone number'
  }

  const pw = body.password || ''
  if (pw.length < 8) errors.password = 'Use at least 8 characters'
  else if (!/[A-Za-z]/.test(pw) || !/[0-9]/.test(pw)) {
    errors.password = 'Include at least one letter and one number'
  }

  if (role === 'customer') {
    if (!String(body.fullName || '').trim()) errors.fullName = 'Full name is required'
    if (!String(body.address  || '').trim()) errors.address  = 'Address is required'
  } else {
    if (!String(body.businessName    || '').trim()) errors.businessName    = 'Business name is required'
    if (!String(body.ownerName       || '').trim()) errors.ownerName       = "Owner's name is required"
    if (!String(body.businessAddress || '').trim()) errors.businessAddress = 'Business address is required'
    if (!String(body.service         || '').trim()) errors.service         = 'Choose the service you offer'
    if (String(body.description || '').trim().length < 30) {
      errors.description = 'Describe your service in at least 30 characters'
    }
  }

  return errors
}
