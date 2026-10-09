/**
 * Application Controller for Swiss Editorial Prototype
 * Zero external dependencies. Self-contained in Vanilla ES6.
 */

import { STATUS_CONFIG, INITIAL_TICKETS } from './mock-data.js';

// --- IN-MEMORY STATE (Resets cleanly on page reload) ---
let currentUser = null;
let tickets = JSON.parse(JSON.stringify(INITIAL_TICKETS));
let activeMobileLane = 'backlog';
let isSimulatingError = false;

// Modal & Draft Guard State
let activeModalTicketId = null;
let modalDefaultLane = 'backlog';
let isDraftDirty = false;

// Keyboard Grab State for A11y
let keyboardGrabbedCardId = null;

// --- TOAST NOTIFICATION ENGINE ---
function showToast(message, isError = false, retryAction = null) {
  const outlet = document.getElementById('toastOutlet');
  if (!outlet) return;

  const toast = document.createElement('div');
  toast.className = 'toast-message';
  if (isError) {
    toast.style.background = '#8B261E'; // Terracotta error
  }

  const textSpan = document.createElement('span');
  textSpan.textContent = message;
  toast.appendChild(textSpan);

  if (retryAction) {
    const retryBtn = document.createElement('button');
    retryBtn.className = 'toast-retry-action';
    retryBtn.textContent = 'Retry';
    retryBtn.onclick = () => {
      retryAction();
      toast.remove();
    };
    toast.appendChild(retryBtn);
  }

  outlet.appendChild(toast);
  setTimeout(() => {
    toast.remove();
  }, 4000);
}

// --- MAIN RENDER ROUTER ---
function renderApp() {
  const root = document.getElementById('appRoot');
  if (!root) return;

  if (!currentUser) {
    renderAuthView(root);
  } else {
    renderBoardView(root);
  }
}

// --- AUTHENTICATION VIEW ---
function renderAuthView(root) {
  let isRegisterMode = false;

  root.innerHTML = `
    <div class="auth-wrapper">
      <div class="auth-header-caption">Working Journal &bull; Prototype Boundary</div>
      <h1 class="auth-title">The Desk</h1>
      <p class="auth-subtitle">Sign in to access your local 4-status project manifest.</p>

      <div class="auth-toggle-bar">
        <button type="button" class="auth-tab-btn is-active" id="tabSignIn">Sign In</button>
        <button type="button" class="auth-tab-btn" id="tabRegister">Create Account</button>
      </div>

      <form id="authForm" novalidate>
        <div class="form-group">
          <label class="form-label" for="authIdentifier">Email or Identifier *</label>
          <input type="text" id="authIdentifier" class="form-control" placeholder="editor@journal.design" required>
          <div class="form-feedback" id="identFeedback" style="display:none;">Please enter a valid identifier.</div>
        </div>

        <div class="form-group">
          <label class="form-label" for="authPassword">Passphrase (&ge; 6 characters) *</label>
          <input type="password" id="authPassword" class="form-control" placeholder="••••••••" minlength="6" required>
          <div class="form-feedback" id="passFeedback" style="display:none;">Password must be at least 6 characters.</div>
        </div>

        <button type="submit" class="btn-editorial btn-primary" id="authSubmitBtn" style="width: 100%; padding: 12px;">
          <span id="authBtnLabel">Enter Workspace</span>
        </button>
      </form>
    </div>
  `;

  const tabSignIn = document.getElementById('tabSignIn');
  const tabRegister = document.getElementById('tabRegister');
  const authBtnLabel = document.getElementById('authBtnLabel');
  const authForm = document.getElementById('authForm');
  const authIdentifier = document.getElementById('authIdentifier');
  const authPassword = document.getElementById('authPassword');
  const identFeedback = document.getElementById('identFeedback');
  const passFeedback = document.getElementById('passFeedback');
  const authSubmitBtn = document.getElementById('authSubmitBtn');

  tabSignIn.onclick = () => {
    isRegisterMode = false;
    tabSignIn.classList.add('is-active');
    tabRegister.classList.remove('is-active');
    authBtnLabel.textContent = 'Enter Workspace';
  };

  tabRegister.onclick = () => {
    isRegisterMode = true;
    tabRegister.classList.add('is-active');
    tabSignIn.classList.remove('is-active');
    authBtnLabel.textContent = 'Create New Account';
  };

  authForm.onsubmit = (e) => {
    e.preventDefault();
    let valid = true;

    if (!authIdentifier.value.trim()) {
      identFeedback.style.display = 'block';
      authIdentifier.classList.add('is-invalid');
      valid = false;
    } else {
      identFeedback.style.display = 'none';
      authIdentifier.classList.remove('is-invalid');
    }

    if (authPassword.value.length < 6) {
      passFeedback.style.display = 'block';
      authPassword.classList.add('is-invalid');
      valid = false;
    } else {
      passFeedback.style.display = 'none';
      authPassword.classList.remove('is-invalid');
    }

    if (!valid) return;

    // Simulated Loading State
    authSubmitBtn.disabled = true;
    authBtnLabel.textContent = 'Authenticating...';

    setTimeout(() => {
      currentUser = authIdentifier.value.trim();
      showToast(`Welcome to the Desk, ${currentUser}`);
      renderApp();
    }, 350);
  };
}

// --- BOARD VIEW ---
function renderBoardView(root) {
  root.innerHTML = `
    <!-- Masthead -->
    <header class="masthead" role="banner">
      <div class="masthead-branding">
        <span class="masthead-title">The Working Board</span>
        <span class="masthead-tag">Swiss Editorial &bull; Concept B</span>
      </div>
      <div class="masthead-actions">
        <span class="user-session-badge">Session: <strong>${escapeHtml(currentUser)}</strong></span>
        <button class="btn-editorial btn-primary" id="globalCreateBtn">+ New Ticket</button>
        <button class="btn-editorial btn-outline" id="signOutBtn">Leave</button>
      </div>
    </header>

    <!-- Main Workspace Stage -->
    <main class="stage-container" role="main">
      <div class="stage-toolbar">
        <div>
          <div style="font-size:11px; text-transform:uppercase; letter-spacing:1px; color:var(--color-ink-subtle); font-weight:700;">Issue Index</div>
          <h1 class="stage-heading">Sprint Manifest &bull; ${tickets.length} Total Work Items</h1>
        </div>
        <div class="stage-sim-toggle">
          <button id="toggleSimErrorBtn" class="btn-editorial btn-outline" style="font-size:12px; ${isSimulatingError ? 'border-color:var(--color-error); color:var(--color-error); font-weight:700;' : ''}">
            Network Simulation: ${isSimulatingError ? 'FAILURE ACTIVE (Rollback)' : 'Normal'}
          </button>
        </div>
      </div>

      <!-- Narrow View Mobile Tab Switcher (< 768px) -->
      <nav class="mobile-tabs" aria-label="Lane selector">
        ${STATUS_CONFIG.map(status => {
          const count = tickets.filter(t => t.status === status.id).length;
          const isActive = activeMobileLane === status.id;
          return `
            <button type="button" class="mobile-tab-btn ${isActive ? 'is-active' : ''}" data-lane-tab="${status.id}">
              ${status.title} (${count})
            </button>
          `;
        }).join('')}
      </nav>

      <!-- 4 Columns Ensemble -->
      <div class="lanes-ensemble">
        ${STATUS_CONFIG.map(status => renderLaneHtml(status)).join('')}
      </div>
    </main>

    <!-- Centered Create / Edit Ticket Modal -->
    <div class="curtain-backdrop" id="ticketModalBackdrop" role="dialog" aria-modal="true" aria-labelledby="modalHeading">
      <div class="dialog-box">
        <div class="dialog-header">
          <h2 class="dialog-heading" id="modalHeading">New Ticket</h2>
          <button type="button" class="btn-text" id="modalDismissBtn">Dismiss</button>
        </div>
        <div class="dialog-body">
          <form id="ticketModalForm" novalidate>
            <div class="form-group">
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <label class="form-label" for="ticketTitleInput">Title *</label>
                <span id="titleCharCount" style="font-size:11px; color:var(--color-ink-faint);">0/100</span>
              </div>
              <input type="text" id="ticketTitleInput" class="form-control" maxlength="100" placeholder="Articulate ticket goal clearly..." required>
              <div class="form-feedback" id="titleValidationFeedback" style="display:none;">Title is required (1-100 characters).</div>
            </div>

            <div class="form-group">
              <label class="form-label" for="ticketStatusSelect">Status Lane</label>
              <select id="ticketStatusSelect" class="form-control">
                ${STATUS_CONFIG.map(s => `<option value="${s.id}">${s.title}</option>`).join('')}
              </select>
            </div>

            <div class="form-group">
              <label class="form-label" for="ticketTagsInput">Tags (Comma separated)</label>
              <input type="text" id="ticketTagsInput" class="form-control" placeholder="ocr, parser, ui">
            </div>

            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label" for="ticketDescTextarea">Description / Acceptance Criteria</label>
              <textarea id="ticketDescTextarea" class="form-control" rows="4" placeholder="Detailed engineering instructions or acceptance signals..."></textarea>
            </div>
          </form>
        </div>
        <div class="dialog-footer">
          <button type="button" class="btn-editorial btn-danger" id="modalDeleteBtn" style="display:none;">Delete</button>
          <div style="display:flex; gap:10px; margin-left:auto;">
            <button type="button" class="btn-editorial btn-outline" id="modalCancelBtn">Cancel</button>
            <button type="button" class="btn-editorial btn-primary" id="modalSaveBtn">Save Ticket</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Discard Draft Protection Dialog -->
    <div class="curtain-backdrop" id="discardModalBackdrop" role="alertdialog" aria-modal="true" aria-labelledby="discardHeading">
      <div class="dialog-box" style="max-width:380px; padding:24px;">
        <h3 class="dialog-heading" id="discardHeading" style="font-size:18px; margin-bottom:8px;">Discard draft?</h3>
        <p style="font-size:13px; color:var(--color-ink-subtle); margin-bottom:20px;">
          Uncommitted inputs will be removed from your working desk.
        </p>
        <div style="display:flex; justify-content:flex-end; gap:8px;">
          <button type="button" class="btn-editorial btn-outline" id="discardKeepEditingBtn">Keep Editing</button>
          <button type="button" class="btn-editorial btn-primary" id="discardConfirmBtn" style="background:var(--color-error); border-color:var(--color-error);">Discard</button>
        </div>
      </div>
    </div>
  `;

  attachBoardListeners();
}

// --- LANE COMPONENT HTML ---
function renderLaneHtml(status) {
  const laneTickets = tickets.filter(t => t.status === status.id);
  const isMobileActive = activeMobileLane === status.id;

  return `
    <section class="lane-compartment ${isMobileActive ? 'is-mobile-active' : ''}" data-lane="${status.id}" aria-label="${status.title} lane">
      <div class="lane-header">
        <h2 class="lane-name">${status.title}</h2>
        <span class="lane-tally">${laneTickets.length} items</span>
      </div>

      <div class="lane-cards-flow" data-lane="${status.id}" role="list">
        ${laneTickets.length === 0 ? `
          <div class="lane-empty-placeholder">
            <div class="empty-state-caption">Quiet in ${status.title}</div>
            <button type="button" class="btn-editorial btn-outline lane-empty-add-btn" data-lane="${status.id}" style="font-size:11px; padding:4px 8px;">
              + Add Entry
            </button>
          </div>
        ` : laneTickets.map(t => renderCardHtml(t)).join('')}
      </div>

      <div class="lane-bottom-action">
        <button type="button" class="btn-add-lane lane-footer-add-btn" data-lane="${status.id}">
          + Add Ticket
        </button>
      </div>
    </section>
  `;
}

// --- TICKET CARD COMPONENT HTML ---
function renderCardHtml(ticket) {
  const isKeyboardGrabbed = keyboardGrabbedCardId === ticket.id;

  return `
    <article class="ticket-sheet ${isKeyboardGrabbed ? 'is-keyboard-grabbed' : ''}"
             draggable="true"
             data-id="${ticket.id}"
             tabindex="0"
             role="listitem"
             aria-label="${escapeHtml(ticket.title)}, status: ${ticket.status}">
      <div class="card-topbar">
        <span class="card-code">${ticket.id}</span>
        <button type="button" class="card-quick-menu-btn" data-id="${ticket.id}" aria-label="Move ticket ${ticket.id}" title="Quick Move Options">•••</button>
      </div>
      <h3 class="card-title-text">${escapeHtml(ticket.title)}</h3>
      <div class="card-footer-meta">
        ${ticket.tags.map(tag => `<span class="tag-capsule">#${escapeHtml(tag)}</span>`).join('')}
        ${ticket.description ? `<span class="notes-marker" title="Has written notes">¶</span>` : ''}
      </div>
    </article>
  `;
}

function escapeHtml(str) {
  if (!str) return '';
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

// --- EVENT LISTENERS ATTACHMENT ---
function attachBoardListeners() {
  // Sign Out
  document.getElementById('signOutBtn').onclick = () => {
    currentUser = null;
    renderApp();
  };

  // Network Simulation Error Toggle
  document.getElementById('toggleSimErrorBtn').onclick = () => {
    isSimulatingError = !isSimulatingError;
    const btn = document.getElementById('toggleSimErrorBtn');
    btn.style.borderColor = isSimulatingError ? 'var(--color-error)' : 'var(--border-emphasis)';
    btn.style.color = isSimulatingError ? 'var(--color-error)' : 'var(--color-ink)';
    btn.textContent = `Network Simulation: ${isSimulatingError ? 'FAILURE ACTIVE (Rollback)' : 'Normal'}`;
  };

  // Mobile Lane Switcher Tabs
  document.querySelectorAll('.mobile-tab-btn').forEach(btn => {
    btn.onclick = () => {
      activeMobileLane = btn.getAttribute('data-lane-tab');
      renderBoardView(document.getElementById('appRoot'));
    };
  });

  // Global + New Ticket (defaults to 'backlog')
  document.getElementById('globalCreateBtn').onclick = () => {
    openTicketModal(null, 'backlog');
  };

  // Lane-level Add Buttons
  document.querySelectorAll('.lane-footer-add-btn, .lane-empty-add-btn').forEach(btn => {
    btn.onclick = () => {
      const targetLane = btn.getAttribute('data-lane');
      openTicketModal(null, targetLane);
    };
  });

  // Ticket Card Clicks (Opens Edit Modal) & Keyboard Controls
  document.querySelectorAll('.ticket-sheet').forEach(card => {
    card.onclick = (e) => {
      if (e.target.classList.contains('card-quick-menu-btn')) return;
      openTicketModal(card.getAttribute('data-id'));
    };

    // Accessible Keyboard Navigation
    card.onkeydown = (e) => {
      const ticketId = card.getAttribute('data-id');

      // Space or Enter: Toggle pickup or drop
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        if (keyboardGrabbedCardId === ticketId) {
          keyboardGrabbedCardId = null;
          showToast(`Dropped ticket ${ticketId}`);
          renderBoardView(document.getElementById('appRoot'));
        } else {
          keyboardGrabbedCardId = ticketId;
          showToast(`Picked up ticket ${ticketId}. Use Arrow keys to move between lanes.`);
          renderBoardView(document.getElementById('appRoot'));
        }
      }

      // Arrow keys move grabbed ticket between lanes
      if (keyboardGrabbedCardId === ticketId) {
        if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
          e.preventDefault();
          const ticket = tickets.find(t => t.id === ticketId);
          if (!ticket) return;

          const laneIds = STATUS_CONFIG.map(s => s.id);
          const currentIndex = laneIds.indexOf(ticket.status);
          let nextIndex = e.key === 'ArrowRight' ? currentIndex + 1 : currentIndex - 1;

          if (nextIndex >= 0 && nextIndex < laneIds.length) {
            transitionTicket(ticketId, laneIds[nextIndex]);
          }
        }

        if (e.key === 'Escape') {
          e.preventDefault();
          keyboardGrabbedCardId = null;
          showToast(`Cancelled movement for ${ticketId}`);
          renderBoardView(document.getElementById('appRoot'));
        }
      }
    };
  });

  // Card Quick Menu Buttons (Touch & Click Popover)
  document.querySelectorAll('.card-quick-menu-btn').forEach(btn => {
    btn.onclick = (e) => {
      e.stopPropagation();
      openQuickMovePopover(btn, btn.getAttribute('data-id'));
    };
  });

  // Direct Pointer Drag & Drop Engine
  setupPointerDragAndDrop();

  // Modal Buttons & Inputs
  setupModalEvents();
}

// --- QUICK MOVE POPOVER MENU ---
function openQuickMovePopover(triggerBtn, ticketId) {
  document.querySelectorAll('.quick-move-menu').forEach(m => m.remove());

  const ticket = tickets.find(t => t.id === ticketId);
  if (!ticket) return;

  const menu = document.createElement('div');
  menu.className = 'quick-move-menu';

  menu.innerHTML = STATUS_CONFIG.map(status => {
    const isCurrent = ticket.status === status.id;
    return `
      <div class="quick-move-item" data-target-lane="${status.id}">
        <span>Move to ${status.title}</span>
        ${isCurrent ? '<span style="font-weight:700;">✓</span>' : ''}
      </div>
    `;
  }).join('');

  const rect = triggerBtn.getBoundingClientRect();
  menu.style.top = `${rect.bottom + window.scrollY + 4}px`;
  menu.style.left = `${Math.min(rect.left, window.innerWidth - 190)}px`;

  menu.querySelectorAll('.quick-move-item').forEach(item => {
    item.onclick = () => {
      const targetLane = item.getAttribute('data-target-lane');
      transitionTicket(ticketId, targetLane);
      menu.remove();
    };
  });

  document.body.appendChild(menu);

  // Close when clicking outside
  const outsideClickListener = (e) => {
    if (!menu.contains(e.target) && e.target !== triggerBtn) {
      menu.remove();
      document.removeEventListener('click', outsideClickListener);
    }
  };
  setTimeout(() => document.addEventListener('click', outsideClickListener), 20);
}

// --- POINTER DRAG AND DROP ENGINE ---
let draggedCardId = null;

function setupPointerDragAndDrop() {
  document.querySelectorAll('.ticket-sheet').forEach(card => {
    card.ondragstart = (e) => {
      draggedCardId = card.getAttribute('data-id');
      card.classList.add('is-dragging');
      e.dataTransfer.setData('text/plain', draggedCardId);
      e.dataTransfer.effectAllowed = 'move';
    };

    card.ondragend = () => {
      card.classList.remove('is-dragging');
      draggedCardId = null;
    };
  });

  document.querySelectorAll('.lane-cards-flow').forEach(flow => {
    flow.ondragover = (e) => {
      e.preventDefault();
      flow.classList.add('is-drag-over');
    };

    flow.ondragleave = () => {
      flow.classList.remove('is-drag-over');
    };

    flow.ondrop = (e) => {
      e.preventDefault();
      flow.classList.remove('is-drag-over');
      const targetLane = flow.getAttribute('data-lane');
      if (draggedCardId && targetLane) {
        transitionTicket(draggedCardId, targetLane);
      }
    };
  });
}

// --- OPTIMISTIC TICKET MOVEMENT WITH ROLLBACK ---
function transitionTicket(ticketId, targetLane) {
  const ticket = tickets.find(t => t.id === ticketId);
  if (!ticket || ticket.status === targetLane) return;

  const previousLane = ticket.status;

  // 1. Optimistic Update
  ticket.status = targetLane;
  ticket.updatedAt = new Date().toISOString();
  renderBoardView(document.getElementById('appRoot'));

  // 2. Simulated Async Behavior & Rollback
  if (isSimulatingError) {
    setTimeout(() => {
      ticket.status = previousLane;
      renderBoardView(document.getElementById('appRoot'));
      showToast(`Network error: Reverted ${ticket.id} to ${previousLane.toUpperCase()}`, true, () => {
        transitionTicket(ticketId, targetLane);
      });
    }, 600);
  } else {
    showToast(`Moved ${ticket.id} to ${targetLane.replace('_', ' ').toUpperCase()}`);
  }
}

// --- CREATE & EDIT MODAL SYSTEM ---
function openTicketModal(ticketId = null, defaultLane = 'backlog') {
  activeModalTicketId = ticketId;
  modalDefaultLane = defaultLane;
  isDraftDirty = false;

  const backdrop = document.getElementById('ticketModalBackdrop');
  const modalHeading = document.getElementById('modalHeading');
  const titleInput = document.getElementById('ticketTitleInput');
  const statusSelect = document.getElementById('ticketStatusSelect');
  const tagsInput = document.getElementById('ticketTagsInput');
  const descTextarea = document.getElementById('ticketDescTextarea');
  const deleteBtn = document.getElementById('modalDeleteBtn');
  const charCount = document.getElementById('titleCharCount');
  const feedback = document.getElementById('titleValidationFeedback');

  feedback.style.display = 'none';
  titleInput.classList.remove('is-invalid');

  if (ticketId) {
    const ticket = tickets.find(t => t.id === ticketId);
    if (!ticket) return;

    modalHeading.textContent = `Revise Ticket ${ticket.id}`;
    titleInput.value = ticket.title;
    statusSelect.value = ticket.status;
    tagsInput.value = ticket.tags.join(', ');
    descTextarea.value = ticket.description || '';
    deleteBtn.style.display = 'inline-flex';
    charCount.textContent = `${ticket.title.length}/100`;
  } else {
    modalHeading.textContent = 'Create New Ticket';
    titleInput.value = '';
    statusSelect.value = defaultLane;
    tagsInput.value = '';
    descTextarea.value = '';
    deleteBtn.style.display = 'none';
    charCount.textContent = '0/100';
  }

  backdrop.classList.add('is-open');
  setTimeout(() => titleInput.focus(), 100);
}

function setupModalEvents() {
  const backdrop = document.getElementById('ticketModalBackdrop');
  const discardBackdrop = document.getElementById('discardModalBackdrop');
  const titleInput = document.getElementById('ticketTitleInput');
  const charCount = document.getElementById('titleCharCount');
  const descTextarea = document.getElementById('ticketDescTextarea');
  const tagsInput = document.getElementById('ticketTagsInput');
  const statusSelect = document.getElementById('ticketStatusSelect');
  const feedback = document.getElementById('titleValidationFeedback');

  // Input tracking
  titleInput.oninput = (e) => {
    isDraftDirty = true;
    charCount.textContent = `${e.target.value.length}/100`;
    if (e.target.value.trim()) {
      feedback.style.display = 'none';
      titleInput.classList.remove('is-invalid');
    }
  };

  descTextarea.oninput = () => { isDraftDirty = true; };
  tagsInput.oninput = () => { isDraftDirty = true; };
  statusSelect.onchange = () => { isDraftDirty = true; };

  // Dismiss / Cancel with Draft Protection Guard
  const handleDismissAttempt = () => {
    if (isDraftDirty) {
      discardBackdrop.classList.add('is-open');
    } else {
      forceCloseModal();
    }
  };

  document.getElementById('modalDismissBtn').onclick = handleDismissAttempt;
  document.getElementById('modalCancelBtn').onclick = handleDismissAttempt;

  // Discard Confirmation Dialog buttons
  document.getElementById('discardKeepEditingBtn').onclick = () => {
    discardBackdrop.classList.remove('is-open');
  };

  document.getElementById('discardConfirmBtn').onclick = () => {
    discardBackdrop.classList.remove('is-open');
    forceCloseModal();
  };

  // Save Ticket
  document.getElementById('modalSaveBtn').onclick = () => {
    const titleVal = titleInput.value.trim();
    if (!titleVal) {
      feedback.style.display = 'block';
      titleInput.classList.add('is-invalid');
      titleInput.focus();
      return;
    }

    const statusVal = statusSelect.value;
    const descVal = descTextarea.value.trim();
    const tagsVal = tagsInput.value.split(',').map(s => s.trim().replace(/^#/, '')).filter(Boolean);

    if (activeModalTicketId) {
      const ticket = tickets.find(t => t.id === activeModalTicketId);
      if (ticket) {
        ticket.title = titleVal;
        ticket.status = statusVal;
        ticket.description = descVal;
        ticket.tags = tagsVal;
        ticket.updatedAt = new Date().toISOString();
        showToast(`Updated ticket ${activeModalTicketId}`);
      }
    } else {
      const newId = `TCK-${Math.floor(100 + Math.random() * 900)}`;
      tickets.push({
        id: newId,
        title: titleVal,
        status: statusVal,
        description: descVal,
        tags: tagsVal,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
      showToast(`Created ticket ${newId}`);
    }

    forceCloseModal();
    renderBoardView(document.getElementById('appRoot'));
  };

  // Delete Ticket
  document.getElementById('modalDeleteBtn').onclick = () => {
    if (!activeModalTicketId) return;
    if (confirm(`Permanently remove ticket ${activeModalTicketId} from the board?`)) {
      tickets = tickets.filter(t => t.id !== activeModalTicketId);
      showToast(`Deleted ticket ${activeModalTicketId}`);
      forceCloseModal();
      renderBoardView(document.getElementById('appRoot'));
    }
  };
}

function forceCloseModal() {
  const backdrop = document.getElementById('ticketModalBackdrop');
  if (backdrop) backdrop.classList.remove('is-open');
  activeModalTicketId = null;
  isDraftDirty = false;
}

// Initial Boot
renderApp();
