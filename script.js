document.addEventListener('DOMContentLoaded', () => {

  // ── Tab switching ──
  window.switchTab = function(group, id, btn) {
    document.querySelectorAll(`#${group}-tabs .tab`).forEach(t => t.classList.remove('active'));
    // Only target tab-panels, not the tabs container itself
    document.querySelectorAll(`.tab-panel[id^="${group}-"]`).forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    const target = document.getElementById(`${group}-${id}`);
    if (target) target.classList.add('active');
  };

  // ── Accordion ──
  window.toggleAcc = function(header) {
    const item = header.parentElement;
    const body = item.querySelector('.acc-body');
    const inner = item.querySelector('.acc-body-inner');
    const isOpen = item.classList.contains('open');

    // Close all open items
    document.querySelectorAll('.acc-item.open').forEach(i => {
      i.classList.remove('open');
      i.querySelector('.acc-body').style.maxHeight = '0';
    });

    // Open clicked item if it was closed
    if (!isOpen) {
      item.classList.add('open');
      body.style.maxHeight = inner.scrollHeight + 32 + 'px';
    }
  };

  // ── Copy code ──
  window.copyCode = function(id, btn) {
    const el = document.getElementById(id);
    // Strip HTML tags and get clean text
    const clone = el.cloneNode(true);
    // Remove prompt spans
    clone.querySelectorAll('.t-prompt').forEach(s => s.remove());
    clone.querySelectorAll('.t-comment').forEach(s => s.remove());
    const text = clone.innerText
      .split('\n')
      .map(l => l.trim())
      .filter(l => l.length > 0)
      .join('\n');

    navigator.clipboard.writeText(text)
      .then(() => {
        btn.textContent = '✓ Copied';
        btn.classList.add('copied');
        setTimeout(() => {
          btn.textContent = 'Copy';
          btn.classList.remove('copied');
        }, 2000);
      })
      .catch(() => {
        // Fallback for older browsers
        const ta = document.createElement('textarea');
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        btn.textContent = '✓ Copied';
        setTimeout(() => { btn.textContent = 'Copy'; }, 2000);
      });
  };

  // ── Mobile menu ──
  window.toggleMobileMenu = function() {
    const nav = document.querySelector('.topbar-nav');
    const isVisible = nav.classList.contains('mobile-open');
    if (isVisible) {
      nav.classList.remove('mobile-open');
      nav.style.cssText = '';
    } else {
      nav.classList.add('mobile-open');
      nav.style.cssText = [
        'display:flex',
        'flex-direction:column',
        'position:fixed',
        'top:64px',
        'left:0',
        'right:0',
        'background:rgba(15,13,19,0.97)',
        'padding:16px',
        'gap:4px',
        'border-bottom:1px solid var(--md-sys-color-outline-var)',
        'backdrop-filter:blur(20px)',
        'z-index:99'
      ].join(';');
    }
  };

  // ── Topbar scroll effect ──
  const topbar = document.querySelector('.topbar');
  if (topbar) {
    window.addEventListener('scroll', () => {
      topbar.style.background = window.scrollY > 20
        ? 'rgba(15,13,19,0.97)'
        : 'rgba(15,13,19,0.85)';
    });
  }

  // ── Smooth scroll ──
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const href = a.getAttribute('href');
      if (href === '#') return;
      e.preventDefault();
      const target = document.querySelector(href);
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
      // Close mobile menu
      const nav = document.querySelector('.topbar-nav');
      nav.classList.remove('mobile-open');
      nav.style.cssText = '';
    });
  });

  // ── Scroll reveal ──
  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });

    document.querySelectorAll('.card, .acc-item, .contact-card').forEach(el => {
      el.style.opacity = '0';
      el.style.transform = 'translateY(16px)';
      el.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
      observer.observe(el);
    });
  }

  console.log('proot-termux-desktop loaded ✅');
});
