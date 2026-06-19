import React, { useState, useEffect } from 'react'

const TMDB_KEY = '5cd6e4d7684fdd8f4434d3fefd47d90b'
const TMDB_BASE = 'https://api.themoviedb.org/3'
const IMG = 'https://image.tmdb.org/t/p/w500'
const IMG_HD = 'https://image.tmdb.org/t/p/original'

// ── Colours ───────────────────────────────────────────────────────────────────
const C = {
  bg: '#0A0A0F', surface: '#14141E', surfaceHigh: '#1C1C2E',
  accent: '#E5173F', accentLight: '#FF4D6D', gold: '#FFD60A',
  green: '#30D158', border: '#2C2C3E', textPrimary: '#F5F5F7',
  textSecondary: '#8E8E93', textTertiary: '#48484A',
  netflix:'#E50914', prime:'#00A8E1', hotstar:'#1F80E0',
  bms:'#E5173F', sony:'#0057A8', zee5:'#8E3AF4', jio:'#003CB6'
}

const providerColor = id => ({8:C.netflix,119:C.prime,122:C.hotstar,220:C.jio,237:C.sony,232:C.zee5}[id] || C.textSecondary)

function openPlatform(provider, title) {
  const q = encodeURIComponent(title)
  const urls = {
    8:   `https://www.netflix.com/search?q=${q}`,
    119: `https://www.primevideo.com/search?phrase=${q}`,
    122: `https://www.hotstar.com/in/search?q=${q}`,
    220: `https://www.jiocinema.com/search?q=${q}`,
    237: `https://www.sonyliv.com/search?keyword=${q}`,
    232: `https://www.zee5.com/search?q=${q}`,
  }
  window.open(urls[provider.provider_id] || `https://google.com/search?q=${q}+watch+online`, '_blank')
}

function openBMS(title) {
  window.open(`https://in.bookmyshow.com/search?q=${encodeURIComponent(title)}`, '_blank')
}

// ── API ───────────────────────────────────────────────────────────────────────
async function fetchTMDB(path, params = {}) {
  const qs = new URLSearchParams({ api_key: TMDB_KEY, language: 'en-US', ...params }).toString()
  const r = await fetch(`${TMDB_BASE}${path}?${qs}`)
  return r.json()
}

// ── Components ────────────────────────────────────────────────────────────────

function StarRating({ value = 0, onChange }) {
  const [hover, setHover] = useState(0)
  return (
    <div style={{ display:'flex', gap:4 }}>
      {Array.from({ length: 10 }, (_, i) => i + 1).map(s => (
        <span key={s} onClick={() => onChange(s)}
          onMouseEnter={() => setHover(s)} onMouseLeave={() => setHover(0)}
          style={{ fontSize:22, cursor:'pointer', color: s <= (hover || value) ? C.gold : C.textTertiary }}>★</span>
      ))}
    </div>
  )
}

function Badge({ label, color }) {
  return (
    <span style={{
      background: color + '22', border: `0.5px solid ${color}66`,
      color, borderRadius:6, padding:'2px 8px', fontSize:11, fontWeight:600
    }}>{label}</span>
  )
}

function PosterCard({ movie, userMovie, onTap, onFavorite }) {
  const status = userMovie?.status
  return (
    <div onClick={onTap} style={{
      background: C.surface, borderRadius:16, border:`0.5px solid ${C.border}`,
      display:'flex', margin:'0 16px 12px', overflow:'hidden', cursor:'pointer',
      boxShadow:'0 4px 12px rgba(0,0,0,0.3)'
    }}>
      <img src={movie.poster_path ? IMG + movie.poster_path : `https://placehold.co/88x132/1C1C2E/48484A?text=🎬`}
        style={{ width:88, height:132, objectFit:'cover', flexShrink:0 }} alt={movie.title} />
      <div style={{ padding:'12px', flex:1, minWidth:0 }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start', gap:8 }}>
          <div style={{ fontWeight:700, fontSize:15, color:C.textPrimary, lineHeight:1.3,
            overflow:'hidden', display:'-webkit-box', WebkitLineClamp:2, WebkitBoxOrient:'vertical' }}>
            {movie.title}
          </div>
          {onFavorite && (
            <span onClick={e => { e.stopPropagation(); onFavorite() }}
              style={{ fontSize:18, cursor:'pointer', color: userMovie?.favorite ? C.accent : C.textTertiary, flexShrink:0 }}>
              {userMovie?.favorite ? '♥' : '♡'}
            </span>
          )}
        </div>
        <div style={{ color:C.textSecondary, fontSize:12, marginTop:3 }}>
          {movie.release_date?.slice(0,4)}
        </div>
        <div style={{ display:'flex', alignItems:'center', gap:6, marginTop:8 }}>
          <span style={{ color:C.gold, fontSize:12, fontWeight:600 }}>★ {movie.vote_average?.toFixed(1)}</span>
          <span style={{ color:C.textTertiary, fontSize:10 }}>TMDB</span>
          {userMovie?.rating && <>
            <span style={{ color:C.accentLight, fontSize:12, fontWeight:600 }}>👤 {userMovie.rating}</span>
          </>}
        </div>
        {status && (
          <div style={{ marginTop:8 }}>
            <Badge label={status === 'watched' ? '✓ Watched' : '🔖 Watchlist'}
              color={status === 'watched' ? C.green : C.gold} />
          </div>
        )}
      </div>
    </div>
  )
}

// ── Screens ───────────────────────────────────────────────────────────────────

function DetailScreen({ movie, userMovie, onBack, onAddToWatchlist, onMarkWatched, onFavorite, onRate }) {
  const [details, setDetails] = useState(null)
  const [providers, setProviders] = useState([])

  useEffect(() => {
    fetchTMDB(`/movie/${movie.id}`).then(setDetails)
    fetchTMDB(`/movie/${movie.id}/watch/providers`).then(d => {
      const region = d.results?.IN || d.results?.US || {}
      setProviders(region.flatrate || [])
    })
  }, [movie.id])

  const m = details || movie
  const um = userMovie

  return (
    <div style={{ background: C.bg, minHeight:'100vh', paddingBottom:100 }}>
      {/* Backdrop */}
      <div style={{ position:'relative', height:340 }}>
        <img src={m.backdrop_path ? IMG_HD + m.backdrop_path : (m.poster_path ? IMG + m.poster_path : '')}
          style={{ width:'100%', height:'100%', objectFit:'cover' }} alt="" />
        <div style={{ position:'absolute', inset:0, background:'linear-gradient(to bottom, transparent 30%, rgba(10,10,15,0.8) 70%, #0A0A0F 100%)' }} />
        <button onClick={onBack} style={{
          position:'absolute', top:16, left:16, background:'rgba(0,0,0,0.5)',
          border:'none', borderRadius:20, width:36, height:36, color:'white', fontSize:18, cursor:'pointer'
        }}>←</button>
        {/* Poster over backdrop */}
        <div style={{ position:'absolute', bottom:16, left:'50%', transform:'translateX(-50%)' }}>
          <img src={m.poster_path ? IMG + m.poster_path : ''} alt={m.title}
            style={{ width:110, height:165, objectFit:'cover', borderRadius:12, boxShadow:'0 8px 24px rgba(0,0,0,0.6)' }} />
        </div>
      </div>

      <div style={{ padding:'0 20px' }}>
        {/* Title */}
        <h1 style={{ textAlign:'center', fontSize:22, fontWeight:700, color:C.textPrimary, marginTop:8, letterSpacing:-0.5 }}>
          {m.title}
        </h1>
        <p style={{ textAlign:'center', color:C.textSecondary, fontSize:13, marginTop:4 }}>
          {m.release_date?.slice(0,4)}
          {m.runtime ? ` · ${m.runtime}m` : ''}
          {m.genres?.length ? ` · ${m.genres.slice(0,2).map(g=>g.name).join(' · ')}` : ''}
        </p>
        {m.tagline ? <p style={{ textAlign:'center', color:C.textTertiary, fontSize:13, fontStyle:'italic', marginTop:6 }}>"{m.tagline}"</p> : null}

        {/* Ratings */}
        <div style={{ display:'flex', justifyContent:'center', gap:10, marginTop:14 }}>
          <div style={{ background:C.gold+'18', border:`0.5px solid ${C.gold}44`, borderRadius:10, padding:'6px 12px', display:'flex', gap:6, alignItems:'center' }}>
            <span style={{ color:C.gold, fontSize:14, fontWeight:700 }}>★ {m.vote_average?.toFixed(1)}</span>
            <span style={{ color:C.textSecondary, fontSize:11 }}>TMDB</span>
          </div>
          {um?.rating && (
            <div style={{ background:C.accentLight+'18', border:`0.5px solid ${C.accentLight}44`, borderRadius:10, padding:'6px 12px', display:'flex', gap:6, alignItems:'center' }}>
              <span style={{ color:C.accentLight, fontSize:14, fontWeight:700 }}>👤 {um.rating}</span>
              <span style={{ color:C.textSecondary, fontSize:11 }}>Your rating</span>
            </div>
          )}
        </div>

        {/* Action buttons */}
        <div style={{ display:'flex', gap:10, marginTop:18 }}>
          <button onClick={() => onMarkWatched(movie)} style={{
            flex:1, padding:'12px', borderRadius:14, border:`0.8px solid ${um?.status==='watched' ? C.green+'99' : C.border}`,
            background: um?.status==='watched' ? C.green+'33' : C.surface,
            color: um?.status==='watched' ? C.green : C.textSecondary, fontWeight:600, fontSize:13, cursor:'pointer'
          }}>✓ {um?.status==='watched' ? 'Watched' : 'Mark Watched'}</button>
          <button onClick={() => onAddToWatchlist(movie)} style={{
            flex:1, padding:'12px', borderRadius:14, border:`0.8px solid ${um?.status==='watchlist' ? C.gold+'99' : C.border}`,
            background: um?.status==='watchlist' ? C.gold+'33' : C.surface,
            color: um?.status==='watchlist' ? C.gold : C.textSecondary, fontWeight:600, fontSize:13, cursor:'pointer'
          }}>🔖 {um?.status==='watchlist' ? 'In List' : 'Add to List'}</button>
        </div>

        {/* Watch On */}
        {providers.length > 0 ? (
          <>
            <h3 style={{ color:C.textPrimary, fontSize:17, fontWeight:600, marginTop:24 }}>Watch On</h3>
            <p style={{ color:C.textSecondary, fontSize:12, marginBottom:10 }}>Tap to open the app directly</p>
            <div style={{ display:'flex', flexWrap:'wrap', gap:10 }}>
              {providers.map(p => {
                const color = providerColor(p.provider_id)
                return (
                  <div key={p.provider_id} onClick={() => openPlatform(p, m.title)}
                    style={{ background:`${color}22`, border:`0.8px solid ${color}77`, borderRadius:12,
                      padding:'8px 12px', display:'flex', alignItems:'center', gap:8, cursor:'pointer' }}>
                    <img src={`https://image.tmdb.org/t/p/original${p.logo_path}`} alt={p.provider_name}
                      style={{ width:24, height:24, borderRadius:6, objectFit:'cover' }} />
                    <div>
                      <div style={{ color, fontSize:13, fontWeight:600 }}>{p.provider_name}</div>
                      <div style={{ color:`${color}bb`, fontSize:10 }}>Tap to watch ↗</div>
                    </div>
                  </div>
                )
              })}
            </div>
          </>
        ) : (
          <div style={{ background:C.surface, border:`0.5px solid ${C.border}`, borderRadius:12, padding:14, marginTop:20,
            color:C.textSecondary, fontSize:13 }}>
            ℹ️ Not available on streaming in India right now.
          </div>
        )}

        {/* BookMyShow */}
        <div onClick={() => openBMS(m.title)} style={{
          background:`${C.bms}22`, border:`0.5px solid ${C.bms}66`, borderRadius:12,
          padding:'10px 14px', marginTop:10, display:'flex', alignItems:'center', gap:10, cursor:'pointer'
        }}>
          <span style={{ fontSize:20 }}>🎟</span>
          <div>
            <div style={{ color:C.bms, fontSize:14, fontWeight:600 }}>BookMyShow</div>
            <div style={{ color:C.textSecondary, fontSize:11 }}>Book cinema tickets — opens BookMyShow ↗</div>
          </div>
        </div>

        {/* Overview */}
        {m.overview && <>
          <h3 style={{ color:C.textPrimary, fontSize:17, fontWeight:600, marginTop:24, marginBottom:8 }}>Overview</h3>
          <p style={{ color:C.textSecondary, fontSize:14, lineHeight:1.6 }}>{m.overview}</p>
        </>}

        {/* Rate it */}
        {um?.status === 'watched' && <>
          <h3 style={{ color:C.textPrimary, fontSize:17, fontWeight:600, marginTop:24, marginBottom:10 }}>Your Rating</h3>
          <StarRating value={um?.rating || 0} onChange={r => onRate(movie.id, r)} />
        </>}
      </div>
    </div>
  )
}

function HomeScreen({ library, onMovieTap, onFavorite }) {
  const [tab, setTab] = useState('watched')
  const list = library.filter(m => m.status === tab)

  const stats = {
    watched: library.filter(m => m.status==='watched').length,
    watchlist: library.filter(m => m.status==='watchlist').length,
    favorites: library.filter(m => m.favorite).length,
  }

  return (
    <div style={{ paddingBottom:20 }}>
      {/* Header */}
      <div style={{ padding:'56px 20px 16px', background:`linear-gradient(to bottom, ${C.surfaceHigh}, ${C.bg})` }}>
        <h1 style={{ fontSize:28, fontWeight:800, color:C.textPrimary, letterSpacing:-0.8 }}>CineLog</h1>
        <p style={{ color:C.textSecondary, fontSize:12, marginTop:2 }}>
          {stats.watched} watched · {stats.watchlist} in list
        </p>
      </div>

      {/* Stats */}
      <div style={{ margin:'0 16px 16px', background:C.surface, borderRadius:14, border:`0.5px solid ${C.border}`,
        display:'flex', justifyContent:'space-around', padding:'14px 0' }}>
        {[['✓',stats.watched,'Watched',C.green],['🔖',stats.watchlist,'Watchlist',C.gold],['♥',stats.favorites,'Loved',C.accent]].map(([icon,val,label,color]) => (
          <div key={label} style={{ textAlign:'center' }}>
            <div style={{ fontSize:16, marginBottom:2 }}>{icon}</div>
            <div style={{ fontSize:20, fontWeight:700, color }}>{val}</div>
            <div style={{ fontSize:11, color:C.textSecondary }}>{label}</div>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div style={{ margin:'0 16px 12px', background:C.surfaceHigh, borderRadius:12, padding:4, display:'flex' }}>
        {['watched','watchlist'].map(t => (
          <button key={t} onClick={() => setTab(t)} style={{
            flex:1, padding:'9px', borderRadius:10, border:'none', cursor:'pointer',
            background: tab===t ? C.accent : 'transparent',
            color: tab===t ? '#fff' : C.textSecondary, fontWeight:600, fontSize:13, fontFamily:'Inter,sans-serif'
          }}>{t==='watched' ? '✓  Watched' : '🔖  Watchlist'}</button>
        ))}
      </div>

      {/* List */}
      {list.length === 0 ? (
        <div style={{ textAlign:'center', padding:'48px 32px', color:C.textSecondary }}>
          <div style={{ fontSize:48, marginBottom:12 }}>🎬</div>
          <p style={{ fontSize:15 }}>
            {tab === 'watched' ? 'No watched movies yet.\nSearch and add some!' : 'Your watchlist is empty.\nDiscover movies to add!'}
          </p>
        </div>
      ) : list.map(m => (
        <PosterCard key={m.id} movie={m} userMovie={m}
          onTap={() => onMovieTap(m)}
          onFavorite={() => onFavorite(m.id)} />
      ))}
    </div>
  )
}

function SearchScreen({ library, onMovieTap, onAddToWatchlist, onMarkWatched }) {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [trending, setTrending] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchTMDB('/trending/movie/week').then(d => setTrending(d.results || []))
  }, [])

  useEffect(() => {
    if (!query.trim()) { setResults([]); return }
    const t = setTimeout(() => {
      setLoading(true)
      fetchTMDB('/search/movie', { query }).then(d => { setResults(d.results || []); setLoading(false) })
    }, 400)
    return () => clearTimeout(t)
  }, [query])

  const list = query.trim() ? results : trending
  const libMap = Object.fromEntries(library.map(m => [m.id, m]))

  return (
    <div style={{ paddingBottom:20 }}>
      <div style={{ padding:'56px 16px 12px', background:`linear-gradient(to bottom, ${C.surfaceHigh}, ${C.bg})` }}>
        <h1 style={{ fontSize:22, fontWeight:700, color:C.textPrimary, marginBottom:12 }}>Discover</h1>
        <div style={{ position:'relative' }}>
          <span style={{ position:'absolute', left:12, top:'50%', transform:'translateY(-50%)', color:C.textSecondary, fontSize:16 }}>🔍</span>
          <input value={query} onChange={e => setQuery(e.target.value)} placeholder="Search any movie..."
            style={{ width:'100%', background:C.surfaceHigh, border:`0.5px solid ${C.border}`, borderRadius:12,
              padding:'10px 12px 10px 36px', color:C.textPrimary, fontSize:15, outline:'none', fontFamily:'Inter,sans-serif' }} />
        </div>
      </div>

      {!query && <div style={{ padding:'4px 20px 10px', color:C.textPrimary, fontSize:18, fontWeight:700 }}>🔥 Trending</div>}
      {loading && <div style={{ textAlign:'center', padding:40, color:C.textSecondary }}>Loading…</div>}

      {list.map(m => {
        const um = libMap[m.id]
        return (
          <div key={m.id} style={{ margin:'0 16px 10px', background:C.surface, borderRadius:14,
            border:`0.5px solid ${C.border}`, display:'flex', alignItems:'center', padding:12, gap:12, cursor:'pointer' }}
            onClick={() => onMovieTap(m)}>
            <img src={m.poster_path ? IMG + m.poster_path : `https://placehold.co/52x78/1C1C2E/48484A?text=🎬`}
              style={{ width:52, height:78, objectFit:'cover', borderRadius:8, flexShrink:0 }} alt={m.title} />
            <div style={{ flex:1, minWidth:0 }}>
              <div style={{ fontWeight:600, fontSize:15, color:C.textPrimary, overflow:'hidden',
                display:'-webkit-box', WebkitLineClamp:2, WebkitBoxOrient:'vertical' }}>{m.title}</div>
              <div style={{ color:C.textSecondary, fontSize:12, marginTop:2 }}>{m.release_date?.slice(0,4)}</div>
              <div style={{ color:C.gold, fontSize:12, fontWeight:600, marginTop:4 }}>★ {m.vote_average?.toFixed(1)}</div>
            </div>
            {um ? (
              <div style={{ background:C.green+'22', border:`0.5px solid ${C.green}66`, borderRadius:20,
                width:32, height:32, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
                <span style={{ color:C.green, fontSize:14 }}>✓</span>
              </div>
            ) : (
              <div style={{ background:C.accent+'22', border:`0.5px solid ${C.accent}66`, borderRadius:20,
                width:32, height:32, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0,
                cursor:'pointer' }}
                onClick={e => { e.stopPropagation()
                  const action = window.confirm(`Add "${m.title}" to:\n[OK] Watchlist\n[Cancel] to close`)
                  if (action) onAddToWatchlist(m)
                }}>
                <span style={{ color:C.accent, fontSize:18 }}>+</span>
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}

function ProfileScreen({ library, onSignOut }) {
  const stats = {
    watched: library.filter(m=>m.status==='watched').length,
    watchlist: library.filter(m=>m.status==='watchlist').length,
    favorites: library.filter(m=>m.favorite).length,
  }

  return (
    <div style={{ paddingBottom:100 }}>
      {/* Header */}
      <div style={{ background:`linear-gradient(to bottom, ${C.surfaceHigh}, ${C.bg})`, padding:'56px 20px 30px', textAlign:'center' }}>
        <div style={{ width:72, height:72, borderRadius:36, background:`linear-gradient(135deg, ${C.accent}, ${C.accentLight})`,
          display:'flex', alignItems:'center', justifyContent:'center', fontSize:28, fontWeight:700, color:'#fff',
          margin:'0 auto', boxShadow:`0 8px 24px ${C.accent}66` }}>GK</div>
        <h2 style={{ color:C.textPrimary, fontSize:20, fontWeight:600, marginTop:10 }}>Gopal K</h2>
        <p style={{ color:C.textSecondary, fontSize:13 }}>Movie enthusiast</p>
      </div>

      <div style={{ padding:'0 16px' }}>
        {/* Stats */}
        <div style={{ display:'flex', gap:10, marginBottom:24 }}>
          {[['Watched',stats.watched,C.accent],['Watchlist',stats.watchlist,C.gold],['Loved',stats.favorites,'#FF453A']].map(([label,val,color]) => (
            <div key={label} style={{ flex:1, background:`${color}18`, border:`0.5px solid ${color}33`,
              borderRadius:16, padding:'18px 8px', textAlign:'center' }}>
              <div style={{ fontSize:30, fontWeight:700, color }}>{val}</div>
              <div style={{ fontSize:12, color:C.textSecondary, marginTop:2, lineHeight:1.3 }}>{label}</div>
            </div>
          ))}
        </div>

        {/* Tech stack info */}
        <div style={{ background:C.surface, border:`0.5px solid ${C.border}`, borderRadius:14, padding:16, marginBottom:16 }}>
          <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:8 }}>
            <span style={{ fontSize:16 }}>☁️</span>
            <span style={{ color:C.textPrimary, fontSize:15, fontWeight:600 }}>How CineLog Works</span>
          </div>
          {[
            ['🎬','Movie Data','TMDB API (real-time, 1M+ movies)'],
            ['☁️','Your Library','Firebase Firestore (real-time sync)'],
            ['🔐','Sign In','Google Sign-In via Firebase Auth'],
            ['📲','Deep Links','Tap → opens Netflix / Prime / Hotstar etc.'],
            ['🌍','Availability','TMDB Watch Providers (India region)'],
          ].map(([icon,label,val]) => (
            <div key={label} style={{ display:'flex', gap:10, marginBottom:10 }}>
              <span style={{ fontSize:15 }}>{icon}</span>
              <div>
                <div style={{ color:C.textPrimary, fontSize:14, fontWeight:500 }}>{label}</div>
                <div style={{ color:C.textSecondary, fontSize:12 }}>{val}</div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ background:C.surface, border:`0.5px solid ${C.border}`, borderRadius:14, padding:16, marginBottom:16 }}>
          <div style={{ color:C.textPrimary, fontSize:15, fontWeight:600, marginBottom:4 }}>⚠️ This is a web preview</div>
          <div style={{ color:C.textSecondary, fontSize:13, lineHeight:1.5 }}>
            The real app is built in Flutter and will run natively on your iPhone. This preview shows the full UI and live TMDB data. Firebase auth & Firestore are active in the Flutter app.
          </div>
        </div>

        <button onClick={onSignOut} style={{
          width:'100%', padding:14, borderRadius:14, border:`0.8px solid ${C.accent}55`,
          background:`${C.accent}18`, color:C.accent, fontSize:15, fontWeight:600, cursor:'pointer', fontFamily:'Inter,sans-serif'
        }}>Sign Out</button>
      </div>
    </div>
  )
}

// ── Main App ──────────────────────────────────────────────────────────────────

export default function App() {
  const [tab, setTab] = useState('home')
  const [library, setLibrary] = useState([])
  const [detail, setDetail] = useState(null)

  const addToWatchlist = movie => {
    setLibrary(prev => {
      const existing = prev.find(m => m.id === movie.id)
      if (existing) return prev.map(m => m.id === movie.id ? { ...m, status:'watchlist' } : m)
      return [...prev, { ...movie, status:'watchlist', favorite:false }]
    })
  }

  const markWatched = movie => {
    setLibrary(prev => {
      const existing = prev.find(m => m.id === movie.id)
      if (existing) return prev.map(m => m.id === movie.id ? { ...m, status:'watched', watchedDate: new Date().toISOString() } : m)
      return [...prev, { ...movie, status:'watched', favorite:false, watchedDate: new Date().toISOString() }]
    })
  }

  const toggleFavorite = id => {
    setLibrary(prev => prev.map(m => m.id === id ? { ...m, favorite: !m.favorite } : m))
  }

  const setRating = (id, rating) => {
    setLibrary(prev => prev.map(m => m.id === id ? { ...m, rating } : m))
  }

  const getUserMovie = id => library.find(m => m.id === id)

  if (detail) {
    return (
      <DetailScreen movie={detail} userMovie={getUserMovie(detail.id)}
        onBack={() => setDetail(null)}
        onAddToWatchlist={m => { addToWatchlist(m); setDetail(null) }}
        onMarkWatched={m => { markWatched(m) }}
        onFavorite={() => toggleFavorite(detail.id)}
        onRate={setRating} />
    )
  }

  return (
    <div style={{ background:C.bg, minHeight:'100vh' }}>
      {/* Screen */}
      <div style={{ paddingBottom:80 }}>
        {tab === 'home' && <HomeScreen library={library} onMovieTap={setDetail} onFavorite={toggleFavorite} />}
        {tab === 'search' && <SearchScreen library={library} onMovieTap={setDetail} onAddToWatchlist={addToWatchlist} onMarkWatched={markWatched} />}
        {tab === 'profile' && <ProfileScreen library={library} onSignOut={() => alert('Sign out available in the real Flutter app!')} />}
      </div>

      {/* Bottom Tab Bar */}
      <div style={{
        position:'fixed', bottom:0, left:'50%', transform:'translateX(-50%)',
        width:'100%', maxWidth:430, background:C.surfaceHigh,
        borderTop:`0.5px solid ${C.border}`, paddingBottom:'env(safe-area-inset-bottom,16px)',
        display:'flex', justifyContent:'space-around', paddingTop:8
      }}>
        {[['home','🎬','Collection'],['search','🔍','Discover'],['profile','👤','Profile']].map(([id,icon,label]) => (
          <button key={id} onClick={() => setTab(id)} style={{
            background:'none', border:'none', cursor:'pointer', display:'flex', flexDirection:'column',
            alignItems:'center', gap:2, padding:'4px 16px'
          }}>
            <span style={{ fontSize:22, opacity: tab===id ? 1 : 0.4 }}>{icon}</span>
            <span style={{ fontSize:10, fontWeight: tab===id ? 600 : 400,
              color: tab===id ? C.accent : C.textTertiary, fontFamily:'Inter,sans-serif' }}>{label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}
