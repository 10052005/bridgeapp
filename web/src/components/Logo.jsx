import { Link } from 'react-router-dom'

// The logo lives in /public/logo.png — replace that file with the original
// high-resolution asset and every page picks it up automatically.
export default function Logo({ to = '/' }) {
  return (
    <Link to={to} className="page-logo" aria-label="BridgeApp home">
      <img src="/logo.png" alt="BridgeApp" />
    </Link>
  )
}
