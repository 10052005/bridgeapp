import { useState } from 'react'
import { EyeIcon, EyeOffIcon } from './Icons.jsx'

/**
 * One labelled input. Handles text, email, tel, password, textarea and select.
 * Passing an `error` string turns the border red and prints the message below.
 */
export default function Field({
  label, name, value, onChange, error,
  id,                       // defaults to name; set it when the same field
                            // name appears twice on one page (customer + seller)
  type = 'text', placeholder, as = 'input', options = [], ...rest
}) {
  const fieldId = id || name
  const [revealed, setRevealed] = useState(false)
  const isPassword = type === 'password'
  const inputType = isPassword && revealed ? 'text' : type
  const cls = error ? 'has-error' : ''
  const errorId = error ? `${fieldId}-error` : undefined

  return (
    <div className="field">
      <label htmlFor={fieldId}>{label}</label>
      <div className={`control${isPassword ? ' has-eye' : ''}`}>
        {as === 'textarea' && (
          <textarea
            id={fieldId} name={name} value={value} onChange={onChange}
            placeholder={placeholder} className={cls}
            aria-invalid={!!error} aria-describedby={errorId} {...rest}
          />
        )}

        {as === 'select' && (
          <select
            id={fieldId} name={name} value={value} onChange={onChange}
            className={cls} aria-invalid={!!error} aria-describedby={errorId} {...rest}
          >
            <option value="">{placeholder || 'Select an option'}</option>
            {options.map((o) => <option key={o} value={o}>{o}</option>)}
          </select>
        )}

        {as === 'input' && (
          <input
            id={fieldId} name={name} type={inputType} value={value} onChange={onChange}
            placeholder={placeholder} className={cls}
            aria-invalid={!!error} aria-describedby={errorId} {...rest}
          />
        )}

        {isPassword && (
          <button
            type="button"
            className="eye"
            onClick={() => setRevealed((v) => !v)}
            aria-label={revealed ? 'Hide password' : 'Show password'}
          >
            {revealed ? <EyeOffIcon /> : <EyeIcon />}
          </button>
        )}
      </div>
      {error && <span className="error" id={errorId}>{error}</span>}
    </div>
  )
}
