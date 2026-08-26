import { Link } from 'react-router-dom'
import Logo from '../components/Logo.jsx'
import { ArrowIcon, StarIcon } from '../components/Icons.jsx'
import './Home.css'

export default function Home() {
  return (
    <div className="home">
      <div className="home-left">
        <Logo />

        <h1 className="hero-title">
          Connecting<br />Needs with<br />Services
        </h1>

        <p className="hero-sub">
          A free platform to showcase skills, build trust,<br />and earn fairly.
        </p>

        <div className="hero-actions">
          <Link to="/register" className="pill-btn">
            SignUp <ArrowIcon />
          </Link>
          <Link to="/login" className="pill-btn">
            Login <ArrowIcon />
          </Link>
        </div>

        <div className="hero-trust">
          <p>100%<br />Verified Service<br />Providers</p>
          <div className="stars" role="img" aria-label="Rated 5 out of 5">
            {[0, 1, 2, 3, 4].map((i) => <StarIcon key={i} />)}
          </div>
        </div>
      </div>

      <div className="home-right">
        {/* Replace /public/hero.png with the full-resolution artwork. */}
        <img src="/hero.png" alt="" />
      </div>
    </div>
  )
}
