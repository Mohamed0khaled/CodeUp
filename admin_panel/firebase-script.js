// Firebase Admin Panel JavaScript
import { 
    collection, 
    addDoc, 
    getDocs, 
    doc, 
    updateDoc, 
    deleteDoc, 
    query, 
    orderBy, 
    where,
    serverTimestamp 
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

class FirebaseAdminPanel {
    constructor() {
        this.currentSection = 'dashboard';
        this.tournaments = [];
        this.currentPage = 1;
        this.itemsPerPage = 6;
        this.searchQuery = '';
        this.statusFilter = '';
        this.init();
    }

    async init() {
        console.log('Initializing Firebase Admin Panel...');
        
        // Wait for Firebase to be initialized
        while (!window.db) {
            console.log('Waiting for Firebase to initialize...');
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        
        console.log('Firebase initialized successfully');
        this.db = window.db;
        console.log('Setting up event listeners...');
        this.setupEventListeners();
        console.log('Loading tournaments...');
        await this.loadTournaments();
        console.log('Showing dashboard section...');
        this.showSection('dashboard');
        console.log('Updating dashboard stats...');
        this.updateDashboardStats();
        console.log('Admin panel initialization complete');
        
        // Add a test method to window for debugging
        window.testModal = () => {
            console.log('Test modal function called');
            this.openTournamentModal();
        };
    }

    setupEventListeners() {
        // Sidebar navigation
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('click', (e) => {
                const section = e.currentTarget.dataset.section;
                this.showSection(section);
            });
        });

        // Mobile menu toggle
        const menuToggle = document.querySelector('.menu-toggle');
        const sidebar = document.querySelector('.sidebar');
        menuToggle?.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });

        // Tournament management
        const addTournamentBtn = document.getElementById('addTournamentBtn');
        if (addTournamentBtn) {
            addTournamentBtn.addEventListener('click', () => {
                console.log('Add tournament button clicked');
                this.openTournamentModal();
            });
        }

        // Modal controls
        const modalClose = document.querySelector('.modal-close');
        if (modalClose) {
            modalClose.addEventListener('click', () => {
                this.closeTournamentModal();
            });
        }

        const cancelBtn = document.getElementById('cancelBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => {
                this.closeTournamentModal();
            });
        }

        // Tournament form submission
        const tournamentForm = document.getElementById('tournamentForm');
        if (tournamentForm) {
            tournamentForm.addEventListener('submit', (e) => {
                console.log('Form submitted');
                e.preventDefault();
                this.saveTournament();
            });
        }

        // Search and filter
        document.getElementById('tournamentSearch')?.addEventListener('input', (e) => {
            this.searchQuery = e.target.value.toLowerCase();
            this.currentPage = 1;
            this.renderTournaments();
        });

        document.getElementById('statusFilter')?.addEventListener('change', (e) => {
            this.statusFilter = e.target.value;
            this.currentPage = 1;
            this.renderTournaments();
        });

        // Pagination
        document.getElementById('prevPage')?.addEventListener('click', () => {
            if (this.currentPage > 1) {
                this.currentPage--;
                this.renderTournaments();
            }
        });

        document.getElementById('nextPage')?.addEventListener('click', () => {
            const maxPages = Math.ceil(this.getFilteredTournaments().length / this.itemsPerPage);
            if (this.currentPage < maxPages) {
                this.currentPage++;
                this.renderTournaments();
            }
        });

        // Close modal when clicking outside
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeTournamentModal();
                this.closeConfirmModal();
            }
        });

        // Prize distribution auto-calculation
        const prizeInputs = ['firstPrize', 'secondPrize', 'thirdPrize'];
        prizeInputs.forEach(id => {
            document.getElementById(id)?.addEventListener('input', () => {
                this.validatePrizeDistribution();
            });
        });
    }

    showSection(sectionName) {
        // Update sidebar active state
        document.querySelectorAll('.menu-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionName}"]`)?.classList.add('active');

        // Update page title
        const pageTitle = document.querySelector('.page-title');
        if (pageTitle) {
            pageTitle.textContent = this.capitalize(sectionName);
        }

        // Show/hide sections
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        document.getElementById(sectionName)?.classList.add('active');

        this.currentSection = sectionName;

        // Load section-specific data
        if (sectionName === 'tournaments') {
            this.renderTournaments();
        } else if (sectionName === 'dashboard') {
            this.updateDashboardStats();
        }
    }

    // Tournament Management
    async loadTournaments() {
        try {
            const q = query(collection(this.db, 'tournaments'), orderBy('createdAt', 'desc'));
            const querySnapshot = await getDocs(q);
            
            this.tournaments = [];
            querySnapshot.forEach((doc) => {
                this.tournaments.push({
                    id: doc.id,
                    ...doc.data()
                });
            });
            
            this.renderTournaments();
            this.updateDashboardStats();
        } catch (error) {
            console.error('Error loading tournaments:', error);
            this.showNotification('Failed to load tournaments', 'error');
        }
    }

    getFilteredTournaments() {
        let filtered = [...this.tournaments];

        if (this.searchQuery) {
            filtered = filtered.filter(tournament => 
                tournament.title.toLowerCase().includes(this.searchQuery) ||
                tournament.subtitle.toLowerCase().includes(this.searchQuery) ||
                tournament.difficulty.toLowerCase().includes(this.searchQuery)
            );
        }

        if (this.statusFilter) {
            filtered = filtered.filter(tournament => tournament.status === this.statusFilter);
        }

        return filtered;
    }

    renderTournaments() {
        const grid = document.getElementById('tournamentsGrid');
        if (!grid) return;

        const filtered = this.getFilteredTournaments();
        const startIndex = (this.currentPage - 1) * this.itemsPerPage;
        const endIndex = startIndex + this.itemsPerPage;
        const currentTournaments = filtered.slice(startIndex, endIndex);

        if (currentTournaments.length === 0) {
            grid.innerHTML = `
                <div class="no-tournaments">
                    <i class="fas fa-trophy"></i>
                    <h3>No tournaments found</h3>
                    <p>Create your first tournament to get started.</p>
                </div>
            `;
            return;
        }

        grid.innerHTML = currentTournaments.map(tournament => this.createTournamentCard(tournament)).join('');
        this.renderPagination(filtered.length);
    }

    createTournamentCard(tournament) {
        const statusClass = `status-${tournament.status}`;
        const participationPercentage = Math.round((tournament.participants / tournament.maxParticipants) * 100);
        
        // Calculate prize amounts
        const firstPrize = Math.round(tournament.prizePool * (tournament.prizes?.first || 50) / 100);
        const secondPrize = Math.round(tournament.prizePool * (tournament.prizes?.second || 30) / 100);
        const thirdPrize = Math.round(tournament.prizePool * (tournament.prizes?.third || 20) / 100);

        const colors = this.getTournamentColors(tournament.difficulty);

        return `
            <div class="tournament-card" style="--card-color-1: ${colors.primary}; --card-color-2: ${colors.secondary};">
                <div class="tournament-header">
                    <div class="tournament-info">
                        <h3>${tournament.title}</h3>
                        <p>${tournament.subtitle}</p>
                    </div>
                    <span class="tournament-status ${statusClass}">${tournament.status}</span>
                </div>
                
                <div class="tournament-details">
                    <div class="detail-item">
                        <i class="fas fa-calendar"></i>
                        <span>${this.formatDate(tournament.startDate)}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-clock"></i>
                        <span>${tournament.duration}h</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-dollar-sign"></i>
                        <span>$${tournament.prizePool.toLocaleString()}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-users"></i>
                        <span>${tournament.participants || 0}/${tournament.maxParticipants}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-signal"></i>
                        <span>${tournament.difficulty}</span>
                    </div>
                    <div class="detail-item">
                        <i class="fas fa-code"></i>
                        <span>${tournament.language}</span>
                    </div>
                </div>

                <div class="prize-preview">
                    <small>Prize Distribution:</small>
                    <div class="prize-amounts">
                        <span>🥇 $${firstPrize.toLocaleString()}</span>
                        <span>🥈 $${secondPrize.toLocaleString()}</span>
                        <span>🥉 $${thirdPrize.toLocaleString()}</span>
                    </div>
                </div>

                <div class="tournament-actions">
                    <button class="action-btn edit" onclick="adminPanel.editTournament('${tournament.id}')">
                        <i class="fas fa-edit"></i>
                        Edit
                    </button>
                    <button class="action-btn delete" onclick="adminPanel.deleteTournament('${tournament.id}')">
                        <i class="fas fa-trash"></i>
                        Delete
                    </button>
                </div>
            </div>
        `;
    }

    getTournamentColors(difficulty) {
        const colors = {
            Easy: { primary: '#10b981', secondary: '#06b6d4' },
            Medium: { primary: '#3b82f6', secondary: '#06b6d4' },
            Hard: { primary: '#8b5cf6', secondary: '#ec4899' },
            Expert: { primary: '#ef4444', secondary: '#f59e0b' }
        };
        return colors[difficulty] || colors.Medium;
    }

    renderPagination(totalItems) {
        const maxPages = Math.ceil(totalItems / this.itemsPerPage);
        const pageNumbers = document.getElementById('pageNumbers');
        const prevBtn = document.getElementById('prevPage');
        const nextBtn = document.getElementById('nextPage');

        if (!pageNumbers) return;

        // Update navigation buttons
        prevBtn.disabled = this.currentPage === 1;
        nextBtn.disabled = this.currentPage === maxPages || maxPages === 0;

        // Generate page numbers
        let pages = '';
        for (let i = 1; i <= maxPages; i++) {
            if (i === 1 || i === maxPages || (i >= this.currentPage - 1 && i <= this.currentPage + 1)) {
                pages += `<button class="page-number ${i === this.currentPage ? 'active' : ''}" onclick="adminPanel.goToPage(${i})">${i}</button>`;
            } else if (i === this.currentPage - 2 || i === this.currentPage + 2) {
                pages += `<span class="page-ellipsis">...</span>`;
            }
        }

        pageNumbers.innerHTML = pages;
    }

    goToPage(page) {
        this.currentPage = page;
        this.renderTournaments();
    }

    openTournamentModal(tournament = null) {
        console.log('openTournamentModal called with:', tournament);
        const modal = document.getElementById('tournamentModal');
        const form = document.getElementById('tournamentForm');
        const title = document.getElementById('modalTitle');

        console.log('Modal element:', modal);
        console.log('Form element:', form);
        console.log('Title element:', title);

        if (tournament) {
            title.textContent = 'Edit Tournament';
            this.populateForm(tournament);
        } else {
            title.textContent = 'Add Tournament';
            form.reset();
            // Set default values
            document.getElementById('firstPrize').value = 50;
            document.getElementById('secondPrize').value = 30;
            document.getElementById('thirdPrize').value = 20;
        }

        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
        console.log('Modal should now be visible');
    }

    closeTournamentModal() {
        const modal = document.getElementById('tournamentModal');
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }

    populateForm(tournament) {
        document.getElementById('tournamentTitle').value = tournament.title;
        document.getElementById('tournamentSubtitle').value = tournament.subtitle;
        document.getElementById('startDate').value = tournament.startDate;
        document.getElementById('duration').value = tournament.duration;
        document.getElementById('prizePool').value = tournament.prizePool;
        document.getElementById('maxParticipants').value = tournament.maxParticipants;
        document.getElementById('difficulty').value = tournament.difficulty;
        document.getElementById('language').value = tournament.language;
        document.getElementById('description').value = tournament.description;
        document.getElementById('rules').value = (tournament.rules || []).join('\n');
        document.getElementById('firstPrize').value = tournament.prizes?.first || 50;
        document.getElementById('secondPrize').value = tournament.prizes?.second || 30;
        document.getElementById('thirdPrize').value = tournament.prizes?.third || 20;

        // Store the tournament ID for editing
        document.getElementById('tournamentForm').dataset.editId = tournament.id;
    }

    validatePrizeDistribution() {
        const first = parseInt(document.getElementById('firstPrize').value) || 0;
        const second = parseInt(document.getElementById('secondPrize').value) || 0;
        const third = parseInt(document.getElementById('thirdPrize').value) || 0;
        const total = first + second + third;

        console.log('Prize distribution validation:', { first, second, third, total });

        // Visual feedback for prize distribution
        const inputs = [document.getElementById('firstPrize'), document.getElementById('secondPrize'), document.getElementById('thirdPrize')];
        inputs.forEach(input => {
            input.style.borderColor = total === 100 ? '#10b981' : '#ef4444';
        });

        const isValid = total === 100;
        console.log('Prize distribution valid:', isValid);
        return isValid;
    }

    async saveTournament() {
        console.log('saveTournament called');
        const form = document.getElementById('tournamentForm');
        const editId = form.dataset.editId;
        const submitBtn = document.getElementById('saveBtn') || form.querySelector('button[type="submit"]');

        // Prevent multiple submissions
        if (submitBtn && submitBtn.disabled) {
            console.log('Save already in progress, ignoring...');
            return;
        }

        // Disable submit button
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.textContent = 'Saving...';
        }

        try {
            // Validate prize distribution
            if (!this.validatePrizeDistribution()) {
                this.showNotification('Prize distribution must total 100%', 'error');
                return;
            }

            // Collect form data
            const formData = {
                title: document.getElementById('tournamentTitle').value,
                subtitle: document.getElementById('tournamentSubtitle').value,
                startDate: document.getElementById('startDate').value,
                duration: parseInt(document.getElementById('duration').value),
                prizePool: parseInt(document.getElementById('prizePool').value),
                maxParticipants: parseInt(document.getElementById('maxParticipants').value),
                difficulty: document.getElementById('difficulty').value,
                language: document.getElementById('language').value,
                description: document.getElementById('description').value,
                rules: document.getElementById('rules').value.split('\n').filter(rule => rule.trim()),
                prizes: {
                    first: parseInt(document.getElementById('firstPrize').value),
                    second: parseInt(document.getElementById('secondPrize').value),
                    third: parseInt(document.getElementById('thirdPrize').value)
                }
            };

            console.log('Form data collected:', formData);
            console.log('Database reference:', this.db);

            if (editId) {
                console.log('Updating existing tournament:', editId);
                // Edit existing tournament
                const tournamentRef = doc(this.db, 'tournaments', editId);
                await updateDoc(tournamentRef, {
                    ...formData,
                    updatedAt: serverTimestamp()
                });
                this.showNotification('Tournament updated successfully!', 'success');
            } else {
                console.log('Creating new tournament');
                // Add new tournament
                const docRef = await addDoc(collection(this.db, 'tournaments'), {
                    ...formData,
                    participants: 0,
                    status: 'open',
                    subscribers: [],
                    createdAt: serverTimestamp()
                });
                console.log('Tournament created with ID:', docRef.id);
                this.showNotification('Tournament created successfully!', 'success');
            }

            await this.loadTournaments();
            this.closeTournamentModal();
            delete form.dataset.editId;

        } catch (error) {
            console.error('Detailed error saving tournament:', error);
            console.error('Error code:', error.code);
            console.error('Error message:', error.message);
            this.showNotification(`Failed to save tournament: ${error.message}`, 'error');
        } finally {
            // Re-enable submit button
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.textContent = editId ? 'Update Tournament' : 'Save Tournament';
            }
        }
    }

    editTournament(id) {
        const tournament = this.tournaments.find(t => t.id === id);
        if (tournament) {
            this.openTournamentModal(tournament);
        }
    }

    async deleteTournament(id) {
        const tournament = this.tournaments.find(t => t.id === id);
        if (!tournament) return;

        this.showConfirmModal(
            'Delete Tournament',
            `Are you sure you want to delete "${tournament.title}"? This action cannot be undone.`,
            async () => {
                try {
                    await deleteDoc(doc(this.db, 'tournaments', id));
                    await this.loadTournaments();
                    this.showNotification('Tournament deleted successfully!', 'success');
                } catch (error) {
                    console.error('Error deleting tournament:', error);
                    this.showNotification('Failed to delete tournament', 'error');
                }
            }
        );
    }

    showConfirmModal(title, message, onConfirm) {
        const modal = document.getElementById('confirmModal');
        document.getElementById('confirmTitle').textContent = title;
        document.getElementById('confirmMessage').textContent = message;

        const confirmBtn = document.getElementById('confirmDelete');
        const cancelBtn = document.getElementById('confirmCancel');

        // Remove existing event listeners
        confirmBtn.replaceWith(confirmBtn.cloneNode(true));
        cancelBtn.replaceWith(cancelBtn.cloneNode(true));

        // Add new event listeners
        document.getElementById('confirmDelete').addEventListener('click', () => {
            onConfirm();
            this.closeConfirmModal();
        });

        document.getElementById('confirmCancel').addEventListener('click', () => {
            this.closeConfirmModal();
        });

        modal.classList.add('active');
    }

    closeConfirmModal() {
        document.getElementById('confirmModal').classList.remove('active');
    }

    updateDashboardStats() {
        const totalTournaments = this.tournaments.length;
        const totalParticipants = this.tournaments.reduce((sum, t) => sum + (t.participants || 0), 0);
        const totalPrizePool = this.tournaments.reduce((sum, t) => sum + (t.prizePool || 0), 0);
        const activeTournaments = this.tournaments.filter(t => t.status === 'open').length;

        document.getElementById('totalTournaments').textContent = totalTournaments;
        document.getElementById('totalParticipants').textContent = totalParticipants;
        document.getElementById('totalPrizePool').textContent = `$${totalPrizePool.toLocaleString()}`;
        document.getElementById('activeTournaments').textContent = activeTournaments;

        this.renderRecentTournaments();
    }

    renderRecentTournaments() {
        const recentList = document.getElementById('recentTournamentsList');
        if (!recentList) return;

        const recent = this.tournaments.slice(0, 5);
        
        if (recent.length === 0) {
            recentList.innerHTML = '<p>No tournaments created yet.</p>';
            return;
        }

        recentList.innerHTML = recent.map(tournament => `
            <div class="tournament-item">
                <div class="tournament-info">
                    <h4>${tournament.title}</h4>
                    <p>${tournament.subtitle}</p>
                </div>
                <div class="tournament-meta">
                    <span class="status status-${tournament.status}">${tournament.status}</span>
                    <span class="participants">${tournament.participants || 0}/${tournament.maxParticipants}</span>
                </div>
            </div>
        `).join('');
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'times' : 'info'}-circle"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close">&times;</button>
        `;

        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#06b6d4'};
            color: white;
            padding: 16px 20px;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            z-index: 3000;
            display: flex;
            align-items: center;
            gap: 12px;
            max-width: 400px;
            animation: slideInRight 0.3s ease;
        `;

        // Add to document
        document.body.appendChild(notification);

        // Remove notification after 5 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => {
                notification.remove();
            }, 300);
        }, 5000);

        // Close button
        notification.querySelector('.notification-close').addEventListener('click', () => {
            notification.remove();
        });
    }

    // Utility functions
    formatDate(dateString) {
        if (!dateString) return 'TBD';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
}

// Initialize the admin panel when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.adminPanel = new FirebaseAdminPanel();
});

// CSS for notifications and animations
const notificationStyles = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 8px;
        flex: 1;
    }
    
    .notification-close {
        background: none;
        border: none;
        color: white;
        font-size: 18px;
        cursor: pointer;
        padding: 4px;
        border-radius: 4px;
        transition: background 0.3s ease;
    }
    
    .notification-close:hover {
        background: rgba(255,255,255,0.2);
    }
    
    .no-tournaments {
        grid-column: 1 / -1;
        text-align: center;
        padding: 60px 20px;
        color: rgba(255,255,255,0.6);
    }
    
    .no-tournaments i {
        font-size: 48px;
        margin-bottom: 16px;
        color: rgba(255,255,255,0.3);
    }
    
    .no-tournaments h3 {
        font-size: 24px;
        margin-bottom: 8px;
        color: rgba(255,255,255,0.8);
    }
    
    .prize-preview {
        margin-top: 12px;
        padding: 12px;
        background: rgba(255,255,255,0.05);
        border-radius: 8px;
    }
    
    .prize-preview small {
        color: rgba(255,255,255,0.6);
        font-size: 12px;
        display: block;
        margin-bottom: 8px;
    }
    
    .prize-amounts {
        display: flex;
        gap: 12px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .prize-amounts span {
        color: rgba(255,255,255,0.8);
    }
    
    .page-ellipsis {
        color: rgba(255,255,255,0.5);
        padding: 0 8px;
        font-weight: bold;
    }
    
    .tournament-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px;
        background: rgba(255,255,255,0.05);
        border-radius: 8px;
        margin-bottom: 8px;
    }
    
    .tournament-info h4 {
        margin: 0 0 4px 0;
        color: white;
    }
    
    .tournament-info p {
        margin: 0;
        color: rgba(255,255,255,0.7);
        font-size: 14px;
    }
    
    .tournament-meta {
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 4px;
    }
    
    .participants {
        font-size: 12px;
        color: rgba(255,255,255,0.6);
    }
`;

// Add styles to the document
const styleSheet = document.createElement('style');
styleSheet.textContent = notificationStyles;
document.head.appendChild(styleSheet);

// Initialize the admin panel only once
let adminPanelInitialized = false;

function initializeAdminPanel() {
    if (adminPanelInitialized) {
        console.log('Admin panel already initialized, skipping...');
        return;
    }
    console.log('Initializing admin panel for the first time...');
    adminPanelInitialized = true;
    window.adminPanel = new FirebaseAdminPanel();
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeAdminPanel);
} else {
    initializeAdminPanel();
}
