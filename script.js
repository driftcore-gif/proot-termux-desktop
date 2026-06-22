// Tab switching
function switchTab(group, id, btn) {
  document.querySelectorAll(`#${group}-tabs .tab`).forEach(t => t.classList.remove('active'));
  document.querySelectorAll(`[id^="${group}-"]`).forEach(p => p.classList.remove('active'));
  btn.classList.add('active');
  document.getElementById(`${group}-${id}`).classList.add('active');
}

// Accordion
function toggleAcc(header) {
  const item = header.parentElement;
  const body = item.querySelector('.acc-body');
  const inner = item.querySelector('.acc-body-inner');
  const isOpen = item.classList.contains('open');
  // Close all
  document.querySelectorAll('.acc-item.open').forEach(i => {
    i.classList.remove('open');
    i.querySelector('.acc-body').style.maxHeight = '0';
  });
  if (!isOpen) {
    item.classList.add('open');
    body.style.maxHeight = inner.scrollHeight + 'px';
  }
}

// Copy code
function copyCode(id, btn) {
  const el = document.getElementById(id);
  const text = el.innerText.replace(/^\$ /gm, '').replace(/^# .+\n/gm, '').trim();
  navigator.clipboard.writeText(text).then(() => {
    btn.textContent = '✓ Copied';
    btn.classList.add('copied');
    setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 2000);
  });
}

// Mobile menu
function toggleMobileMenu() {
  const nav = document.querySelector('.topbar-nav');
  const isVisible = nav.style.display === 'flex';
  nav.style.cssText = isVisible ? '' :
    'display:flex;flex-direction:column;position:fixed;top:64px;left:0;right:0;background:rgba(15,13,19,0.97);padding:16px;gap:4px;border-bottom:1px solid var(--md-sys-color-outline-var);backdrop-filter:blur(20px);z-index:99;';
}

// Topbar scroll effect
window.addEventListener('scroll', () => {
  document.querySelector('.topbar').style.background =
    window.scrollY > 20 ? 'rgba(15,13,19,0.97)' : 'rgba(15,13,19,0.85)';
});

// Smooth scroll for nav links
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    e.preventDefault();
    const el = document.querySelector(a.getAttribute('href'));
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    // Close mobile menu if open
    document.querySelector('.topbar-nav').style.cssText = '';
  });
});

// Intersection observer for scroll-reveal
const observer = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.style.opacity = '1'; });
}, { threshold: 0.1 });

document.querySelectorAll('.card, .acc-item, .contact-card').forEach(el => {
  el.style.opacity = '0';
  el.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
  observer.observe(el);
});
