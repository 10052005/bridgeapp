import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Logo from '../components/Logo.jsx'
import RoleToggle from '../components/RoleToggle.jsx'
import Field from '../components/Field.jsx'
import { UserIcon, ShopIcon } from '../components/Icons.jsx'
import { register } from '../api/client.js'
import * as v from '../api/validate.js'
import './Register.css'

/* Categories mirror the parent categories seeded in the database. */
const SERVICES = [
  'Tailoring & Stitching',
  'Beauty & Wellness',
  'Education & Tutoring',
  'Food & Catering',
  'Handicrafts',
]

const CUSTOMER_RULES = {
  fullName:        (val) => v.required(val),
  email:           (val) => v.email(val),
  phone:           (val) => v.phone(val),
  password:        (val) => v.password(val),
  confirmPassword: (val, all) => v.confirmPassword(val, all.password),
  address:         (val) => v.required(val),
}

const SELLER_RULES = {
  businessName:    (val) => v.required(val),
  ownerName:       (val) => v.required(val),
  email:           (val) => v.email(val),
  phone:           (val) => v.phone(val),
  businessAddress: (val) => v.required(val),
  service:         (val) => (val ? '' : 'Choose the service you offer'),
  description:     (val) =>
    !val || val.trim().length < 30
      ? 'Describe your service in at least 30 characters'
      : '',
  password:        (val) => v.password(val),
  confirmPassword: (val, all) => v.confirmPassword(val, all.password),
}

/* Each role keeps its OWN values object. Sharing one object made text typed
   into the customer form appear inside the greyed-out seller form. */
const EMPTY_CUSTOMER = {
  fullName: '', email: '', phone: '', address: '', preferredServices: '',
  password: '', confirmPassword: '',
}

const EMPTY_SELLER = {
  businessName: '', ownerName: '', email: '', phone: '',
  businessAddress: '', description: '', service: '',
  password: '', confirmPassword: '',
}

export default function Register() {
  const navigate = useNavigate()
  const [role, setRole] = useState('customer')
  const [customer, setCustomer] = useState(EMPTY_CUSTOMER)
  const [seller, setSeller] = useState(EMPTY_SELLER)
  const [portfolio, setPortfolio] = useState([])
  const [errors, setErrors] = useState({})
  const [banner, setBanner] = useState(null)
  const [busy, setBusy] = useState(false)

  const isCustomer = role === 'customer'
  const values = isCustomer ? customer : seller
  const setValues = isCustomer ? setCustomer : setSeller

  const switchRole = (next) => {
    setRole(next)
    setErrors({})
    setBanner(null)
  }

  const handleChange = (e) => {
    const { name, value } = e.target
    setValues((prev) => ({ ...prev, [name]: value }))
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }))
  }

  const handleFiles = (e) => {
    const picked = Array.from(e.target.files || [])
    const tooBig = picked.filter((f) => f.size > 10 * 1024 * 1024)
    if (tooBig.length) {
      setErrors((prev) => ({ ...prev, portfolio: 'Each file must be 10MB or smaller' }))
      return
    }
    setErrors((prev) => ({ ...prev, portfolio: '' }))
    setPortfolio(picked)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setBanner(null)

    const rules = isCustomer ? CUSTOMER_RULES : SELLER_RULES
    const found = v.runValidation(values, rules)
    setErrors(found)

    if (Object.keys(found).length) {
      setBanner({ type: 'error', text: 'Please fix the highlighted fields below.' })
      return
    }

    setBusy(true)
    try {
      await register({ ...values, role, portfolioCount: portfolio.length })
      setBanner({ type: 'success', text: 'Account created. Redirecting you to login…' })
      setTimeout(() => navigate('/login'), 1600)
    } catch (err) {
      if (err.fieldErrors) setErrors(err.fieldErrors)
      setBanner({ type: 'error', text: err.message })
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="page register-page">
      <Logo />

      <header className="page-head">
        <h1>Registration</h1>
        <p>Create an account as a customer or seller</p>
      </header>

      <RoleToggle value={role} onChange={switchRole} />

      <form className="register-form" onSubmit={handleSubmit} noValidate>
        {banner && (
          <div className={`banner ${banner.type} register-banner`}>{banner.text}</div>
        )}

        <div className="register-grid">
          {/* ---------- Customer ---------- */}
          <fieldset
            className={`card${isCustomer ? '' : ' is-dim'}`}
            disabled={!isCustomer}
            aria-hidden={!isCustomer}
          >
            <h2><UserIcon /> Customer Information</h2>

            <div className="two-col">
              <div>
                <Field
                  label="Full Name" name="fullName" id="c-fullName" placeholder="Enter your full name"
                  autoComplete="name"
                  value={customer.fullName} onChange={handleChange}
                  error={isCustomer ? errors.fullName : ''}
                />
                <Field
                  label="Email Address" name="email" id="c-email" type="email"
                  placeholder="Enter your email address" autoComplete="email"
                  value={customer.email} onChange={handleChange}
                  error={isCustomer ? errors.email : ''}
                />
                <Field
                  label="Phone Number" name="phone" id="c-phone" type="tel"
                  placeholder="Enter your phone number" autoComplete="tel"
                  value={customer.phone} onChange={handleChange}
                  error={isCustomer ? errors.phone : ''}
                />
                <Field
                  as="textarea" label="Preferred Services" name="preferredServices" id="c-preferredServices"
                  placeholder="What service are you looking for?"
                  value={customer.preferredServices} onChange={handleChange}
                />
              </div>

              <div>
                <Field
                  label="Password" name="password" id="c-password" type="password"
                  placeholder="Enter your password" autoComplete="new-password"
                  value={customer.password} onChange={handleChange}
                  error={isCustomer ? errors.password : ''}
                />
                <Field
                  label="Confirm Password" name="confirmPassword" id="c-confirmPassword" type="password"
                  placeholder="Confirm your password" autoComplete="new-password"
                  value={customer.confirmPassword} onChange={handleChange}
                  error={isCustomer ? errors.confirmPassword : ''}
                />
                <Field
                  as="textarea" label="Address" name="address" id="c-address"
                  placeholder="Enter your address"
                  value={customer.address} onChange={handleChange}
                  error={isCustomer ? errors.address : ''}
                />
              </div>
            </div>
          </fieldset>

          {/* ---------- Seller ---------- */}
          <fieldset
            className={`card${isCustomer ? ' is-dim' : ''}`}
            disabled={isCustomer}
            aria-hidden={isCustomer}
          >
            <h2><ShopIcon /> Seller Information</h2>

            <div className="two-col">
              <div>
                <Field
                  label="Business / Shop Name" name="businessName" id="s-businessName"
                  placeholder="Enter your business or shop name"
                  value={seller.businessName} onChange={handleChange}
                  error={!isCustomer ? errors.businessName : ''}
                />
                <Field
                  label="Owner's Full Name" name="ownerName" id="s-ownerName"
                  placeholder="Enter owner's full name" autoComplete="name"
                  value={seller.ownerName} onChange={handleChange}
                  error={!isCustomer ? errors.ownerName : ''}
                />
                <Field
                  label="Email Address" name="email" id="s-email" type="email"
                  placeholder="Enter your email address" autoComplete="email"
                  value={seller.email} onChange={handleChange}
                  error={!isCustomer ? errors.email : ''}
                />
                <Field
                  as="textarea" label="Business Address" name="businessAddress" id="s-businessAddress"
                  placeholder="Enter your business address"
                  value={seller.businessAddress} onChange={handleChange}
                  error={!isCustomer ? errors.businessAddress : ''}
                />
              </div>

              <div>
                <Field
                  label="Password" name="password" id="s-password" type="password"
                  placeholder="Enter your password" autoComplete="new-password"
                  value={seller.password} onChange={handleChange}
                  error={!isCustomer ? errors.password : ''}
                />
                <Field
                  label="Confirm Password" name="confirmPassword" id="s-confirmPassword" type="password"
                  placeholder="Confirm your password" autoComplete="new-password"
                  value={seller.confirmPassword} onChange={handleChange}
                  error={!isCustomer ? errors.confirmPassword : ''}
                />
                <Field
                  label="Phone Number" name="phone" id="s-phone" type="tel"
                  placeholder="Enter your phone number" autoComplete="tel"
                  value={seller.phone} onChange={handleChange}
                  error={!isCustomer ? errors.phone : ''}
                />
                <Field
                  as="select" label="Service" name="service" id="s-service"
                  placeholder="Select your service" options={SERVICES}
                  value={seller.service} onChange={handleChange}
                  error={!isCustomer ? errors.service : ''}
                />
              </div>
            </div>

            <Field
              as="textarea" label="Business Description" name="description" id="s-description"
              placeholder="Describe your business and service"
              value={seller.description} onChange={handleChange}
              error={!isCustomer ? errors.description : ''}
            />

            <div className="field">
              <label htmlFor="s-portfolio">Upload Portfolio</label>
              <label className="dropzone" htmlFor="s-portfolio">
                <span>
                  {portfolio.length
                    ? `${portfolio.length} file${portfolio.length > 1 ? 's' : ''} selected`
                    : 'Upload or drag and drop'}
                </span>
                <span className="hint">Images, PDF, ZIP · Max 10MB</span>
                <input
                  id="s-portfolio" name="portfolio" type="file" multiple
                  accept="image/*,.pdf,.zip" onChange={handleFiles}
                />
              </label>
              {errors.portfolio && <span className="error">{errors.portfolio}</span>}
            </div>
          </fieldset>
        </div>

        <button className="btn-submit" type="submit" disabled={busy}>
          {busy ? 'Creating account…' : 'Submit'}
        </button>
      </form>

      <p className="register-foot">
        Already have an account? <Link to="/login">Login</Link>
      </p>
    </div>
  )
}
