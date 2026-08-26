import { UserIcon, ShopIcon } from './Icons.jsx'

/**
 * Customer / Seller switch used on both Login and Registration.
 * Controlled by the parent so the parent owns which role is active.
 */
export default function RoleToggle({ value, onChange }) {
  return (
    <div className="toggle" role="tablist" aria-label="Account type">
      <button
        role="tab"
        type="button"
        aria-selected={value === 'customer'}
        onClick={() => onChange('customer')}
      >
        <UserIcon /> Customer
      </button>
      <button
        role="tab"
        type="button"
        aria-selected={value === 'seller'}
        onClick={() => onChange('seller')}
      >
        <ShopIcon /> Seller
      </button>
    </div>
  )
}
