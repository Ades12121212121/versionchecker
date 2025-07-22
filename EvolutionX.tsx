import React, { useState } from 'react';

const NAV_ITEMS = [
  { label: 'Home', section: 'home' },
  { label: 'Scripts', section: 'scripts' },
  { label: 'Downloads', section: 'downloads' },
  { label: 'API', section: 'api' },
];

const scripts = [
  { name: 'Script 1', code: `print('Hello EvolutionX!')` },
  { name: 'Script 2', code: `game.Players.LocalPlayer:Kick('¡Actualiza EvolutionX!')` },
];

export default function EvolutionX() {
  const [active, setActive] = useState('home');

  return (
    <div style={{ minHeight: '100vh', background: 'linear-gradient(135deg, #181a1b 60%, #2e2e2e 100%)', color: '#f5f5f5', fontFamily: 'Segoe UI, Arial, sans-serif' }}>
      <nav style={{ width: '100%', background: 'rgba(30,30,30,0.95)', boxShadow: '0 2px 16px 0 rgba(31, 38, 135, 0.17)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0.5rem 2rem', position: 'sticky', top: 0, zIndex: 100 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.7rem' }}>
          <img src="https://raw.githubusercontent.com/Ades12121212121/versionchecker/refs/heads/main/EvolutinX.ico" alt="EvolutionX Logo" style={{ width: 48, height: 48, filter: 'drop-shadow(0 0 12px #4fc3f7)' }} draggable={false} />
          <span style={{ fontSize: '1.5rem', fontWeight: 700, background: 'linear-gradient(90deg, #4fc3f7, #f5f5f5)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', letterSpacing: 1 }}>EvolutionX</span>
        </div>
        <div style={{ display: 'flex', gap: '2rem' }}>
          {NAV_ITEMS.map(item => (
            <button
              key={item.section}
              onClick={() => setActive(item.section)}
              style={{
                background: 'none',
                border: 'none',
                color: active === item.section ? '#4fc3f7' : '#f5f5f5',
                fontSize: '1.1rem',
                fontWeight: 500,
                cursor: 'pointer',
                borderBottom: active === item.section ? '2px solid #4fc3f7' : '2px solid transparent',
                padding: '0.5rem 0',
                transition: 'color 0.2s, border-bottom 0.2s',
              }}
            >
              {item.label}
            </button>
          ))}
        </div>
      </nav>
      <main style={{ maxWidth: 900, margin: '2.5rem auto 0 auto', padding: '2rem', background: 'rgba(30,30,30,0.7)', borderRadius: '2rem', boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.27)' }}>
        {active === 'home' && (
          <section>
            <img src="https://raw.githubusercontent.com/Ades12121212121/versionchecker/refs/heads/main/EvolutinX.ico" alt="EvolutionX Logo" style={{ width: 120, height: 120, margin: '0 auto 1.5rem auto', display: 'block', filter: 'drop-shadow(0 0 24px #4fc3f7)' }} draggable={false} />
            <h1 style={{ fontSize: '2.8rem', fontWeight: 800, letterSpacing: 2, margin: 0, background: 'linear-gradient(90deg, #4fc3f7, #f5f5f5)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', textAlign: 'center' }}>EvolutionX Executor</h1>
            <div style={{ fontSize: '1.2rem', color: '#4fc3f7', marginBottom: '1.5rem', letterSpacing: 1, textAlign: 'center' }}>Versión 1.0.0</div>
            <div style={{ fontSize: '1.1rem', color: '#f5f5f5', marginBottom: '2rem', textAlign: 'center', maxWidth: 500, marginLeft: 'auto', marginRight: 'auto' }}>
              El executor más avanzado y elegante para Roblox.<br />
              Disfruta de velocidad, seguridad y una experiencia visual única.<br />
              ¡Bienvenido a la evolución!
            </div>
          </section>
        )}
        {active === 'scripts' && (
          <section>
            <h1>Scripts</h1>
            <div style={{ fontSize: '1.1rem', color: '#f5f5f5', marginBottom: '2rem', textAlign: 'center' }}>Explora y descarga scripts populares para Roblox. (¡Pronto podrás agregar los tuyos!)</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem', marginTop: '2rem' }}>
              {scripts.map((script, i) => (
                <div key={i} style={{ background: 'rgba(44, 44, 44, 0.85)', borderRadius: '1rem', padding: '1.2rem 1.5rem', boxShadow: '0 2px 12px 0 rgba(79,195,247,0.08)', color: '#f5f5f5', borderLeft: '4px solid #4fc3f7' }}>
                  <strong>{script.name}:</strong> <code>{script.code}</code>
                </div>
              ))}
            </div>
          </section>
        )}
        {active === 'downloads' && (
          <section>
            <h1>Descargas</h1>
            <div style={{ fontSize: '1.1rem', color: '#f5f5f5', marginBottom: '2rem', textAlign: 'center' }}>
              Descarga la última versión de EvolutionX Executor para Roblox.<br />
              <a href="https://t.me/EvolutionXExecutor" style={{ display: 'inline-block', background: 'linear-gradient(90deg, #4fc3f7, #2e2e2e)', color: '#181a1b', border: 'none', borderRadius: '2rem', padding: '1rem 2.5rem', fontSize: '1.2rem', fontWeight: 700, cursor: 'pointer', boxShadow: '0 4px 16px 0 rgba(79,195,247,0.2)', margin: '2rem auto 0 auto', textDecoration: 'none', transition: 'transform 0.2s, box-shadow 0.2s, background 0.2s' }}>Descargar EvolutionX</a>
            </div>
          </section>
        )}
        {active === 'api' && (
          <section>
            <h1>API</h1>
            <div style={{ fontSize: '1.1rem', color: '#f5f5f5', marginBottom: '2rem', textAlign: 'center' }}>
              Documentación de la API para integraciones y automatizaciones.<br />
              (Próximamente más detalles)
            </div>
            <div style={{ background: 'rgba(44, 44, 44, 0.85)', borderRadius: '1rem', padding: '1.2rem 1.5rem', marginTop: '2rem', color: '#f5f5f5', fontSize: '1rem', boxShadow: '0 2px 12px 0 rgba(79,195,247,0.08)' }}>
              <strong>GET</strong> <code>/api/version</code> — Devuelve la versión actual de EvolutionX.<br />
              <strong>GET</strong> <code>/api/scripts</code> — Lista los scripts disponibles.<br />
              {/* Agrega más endpoints aquí */}
            </div>
          </section>
        )}
      </main>
    </div>
  );
}