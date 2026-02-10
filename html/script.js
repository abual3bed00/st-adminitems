let allItems = [];
let selectedItem = null;

const overlay = document.getElementById('overlay');
const searchInput = document.getElementById('search');
const itemsList = document.getElementById('items-list');
const amountInput = document.getElementById('amount');
const targetIdInput = document.getElementById('target-id');
const giveBtn = document.getElementById('give-btn');

window.addEventListener('message', (event) => {
  if (event.data?.type === 'open') {
    allItems = Array.isArray(event.data.items) ? event.data.items : [];
    overlay.style.display = 'flex';
    renderItems(allItems);
    giveBtn.disabled = !selectedItem;
  }
  if (event.data?.type === 'loadItems') {
    allItems = Array.isArray(event.data.items) ? event.data.items : [];
    renderItems(allItems);
  }
});

function renderItems(items) {
  itemsList.innerHTML = '';
  items.forEach((it, idx) => {
    const card = document.createElement('div');
    card.className = 'item';
    card.dataset.name = it.name;

    const img = document.createElement('img');
    img.src = `nui://qb-inventory/html/images/${it.name}.png`;
    img.alt = it.label;
    img.loading = 'lazy';
    img.onerror = () => { img.src = 'nui://qb-inventory/html/images/unknown.png'; };

    const span = document.createElement('span');
    span.textContent = it.label;

    card.appendChild(img);
    card.appendChild(span);

    card.addEventListener('click', () => selectItem(it, card));

    itemsList.appendChild(card);
  });

  // Keep selection highlight if still in list
  if (selectedItem) {
    const again = [...itemsList.querySelectorAll('.item')].find(el => el.dataset.name === selectedItem.name);
    if (again) again.classList.add('active'); else selectedItem = null;
    giveBtn.disabled = !selectedItem;
  }
}

function selectItem(item, cardEl) {
  selectedItem = item;
  document.querySelectorAll('.item').forEach(el => el.classList.remove('active'));
  if (cardEl) cardEl.classList.add('active');
  giveBtn.disabled = false;
}

function toast(msg) {
  const box = document.getElementById('toast-container');
  const t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  box.appendChild(t);
  setTimeout(() => t.remove(), 2100);
}

function giveItem() {
  if (!selectedItem) { toast('Select an item first.'); return; }

  const amt = Math.max(1, Math.min(1000, parseInt(amountInput.value || '1', 10)));
  const target = (targetIdInput.value || '').trim();
  const payload = { item: selectedItem.name, amount: amt, target: target !== '' ? target : null };

  fetch(`https://${GetParentResourceName()}/giveItem`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  if (payload.target) {
    toast(`Gave ${amt}x ${selectedItem.name} to ID ${payload.target}`);
  } else {
    toast(`Gave ${amt}x ${selectedItem.name} to yourself`);
  }
}

function closeUI() {
  overlay.style.display = 'none';
  fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  });
}

// Search (debounced)
let debounce;
searchInput.addEventListener('input', () => {
  clearTimeout(debounce);
  const q = searchInput.value.toLowerCase();
  debounce = setTimeout(() => {
    const filtered = allItems.filter(i =>
      i.name.toLowerCase().includes(q) || (i.label || '').toLowerCase().includes(q)
    );
    renderItems(filtered);
  }, 200);
});

// ESC to close
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closeUI();
});

// Enter to give from either amount or target fields
amountInput.addEventListener('keydown', e => { if (e.key === 'Enter') giveItem(); });
targetIdInput.addEventListener('keydown', e => { if (e.key === 'Enter') giveItem(); });

// Button
giveBtn.addEventListener('click', giveItem);
